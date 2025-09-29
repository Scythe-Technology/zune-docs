--!strict
---!native

local fs = zune.fs;

local writer = require("./utils/writer");
local printer = require("./utils/printer");

local prep = require("./utils/prep");

local types = prep.types;
local libraries = prep.libraries;
local documentations = prep.documentations;
local summaries = prep.summaries;
local classes = prep.classes;

local function parseDocumentation(docs: { string }): any
    local result: {[string]: string} = {};
    local current: string = "@base";
    for _, doc in docs do
        local tag = doc:match("%-%-%-%s*@([%w_]+)");
        local value = "";
        if (tag) then
            local _, value2 = doc:match("%-%-%-%s*@([%w_]+)%s(.+)");
            if (not value2) then
                current = tag;
                continue;
            end
            value = value2;
            if (tag == "param" or tag == "default_param") then
                local param_name, real = value:match("^([%w_.]+)%s*(.*)");
                if (not param_name) then
                    error(`invalid {tag} tag`);
                end
                value = real :: string;
                tag = `{tag}+{param_name}`;
            end
            current = tag;
        else
            value = doc:match("%-%-%-%s*(.+)") :: any;
            if (not value) then
                if (doc:match("%-%-%-.*")) then
                    result[current] = (result[current] or "") .. `\n`;
                end
                continue;
            end
        end
        if (not result[current]) then
            result[current] = value :: string;
        else
            result[current] ..= `\n{value :: string}`;
        end
    end
    return result;
end

local function captureReferencedTypes(type_token: any, refs: {string}): ()
    if (type(type_token) ~= "table") then
        return;
    end
    if (type_token.tag == "reference") then
        if (not types[type_token.name.text] and not classes[type_token.name.text]) then
            return;
        end
        if (not table.find(refs, type_token.name.text)) then
            table.insert(refs, type_token.name.text);
            local defined = types[type_token.name.text];
            if (defined) then
                captureReferencedTypes(defined.type, refs);
            end
        end
        return;
    end
    for _, value in type_token do
        captureReferencedTypes(value, refs);
    end
end

local function captureFunctionTypes(type_token: any, types: {any}): ()
    if (type(type_token) ~= "table") then
        return;
    end
    if (type_token.tag == "function") then
        if (not table.find(types, type_token)) then
            table.insert(types, type_token);
        end
        return;
    end
    for _, value in type_token do
        captureFunctionTypes(value, types);
    end
end

local function generatePageProperty(name: string, type: any, docs: {[string]: string}, extension: string?): string
    local doc = {};

    if (docs["@base"]) then
        table.insert(doc, docs["@base"]);
    end
    if (docs["docs"]) then
        table.insert(doc, docs["docs"]);
    end

    if (type.tag == "table") then
        local index = `{if (extension) then `{extension}.` else ""}{name}`;
        table.insert(doc, "```luau tooltips");

        local referenced = {};
        captureReferencedTypes(type.entries, referenced);
        local value = writer.printType(type, nil, {});
        local hover = `-- @hover: ({#index + 4},{#index + 9})[`;
        for _, ref in referenced do
            if (not types[ref]) then
                continue;
            end
            hover ..= `{writer.printStatement(types[ref], nil, {})}\n\n`;
        end
        hover ..= `<table> = {value}]`
        table.insert(doc, hover);
        table.insert(doc, `{index}: <table>`);
        table.insert(doc, "```");
    else
        local index = `{if (extension) then `{extension}.` else ""}{name}`;
        table.insert(doc, "```luau tooltips");
        local link_data = {};

        local capture = {
            visitTypeReference = function(node: any, printer: any)
                local type_name = node.name.text;
                local start = printer.opts.offset + printer.cursor + 1;
                if (classes[type_name]) then
                    link_data[start] = type_name
                end
                return true;
            end,
        };

        local type_str = writer.printType(type, capture, {offset = #index + 2});
        for start, type_name in link_data do
            local link = `-- @link: ({start},{start + #type_name})[../objects/{type_name}]`;
            table.insert(doc, link);
        end
        table.insert(doc, `{index}: {type_str}`);

        table.insert(doc, "```");
    end

    return table.concat(doc, "\n");
end

local function generatePageFunction(library: any, name: string, fn_types: {any}, docs: {[string]: string}, extension: string?): string
    local doc = {};

    if (docs["@base"]) then
        table.insert(doc, docs["@base"]);
    end
    if (docs["docs"]) then
        table.insert(doc, docs["docs"]);
    end
    table.insert(doc, "```luau tooltips");

    local ordered_params = {};
    local vararg;

    for overload, type in fn_types do
        local index = `{if (extension) then `{extension}.` else ""}{name}`;
        local func = `{index}(`;
        local hover_data = {};
        local link_data = {};

        local capture = {
            visitTypeReference = function(node: any, printer: any)
                local type_name = node.name.text;
                local start = printer.opts.offset + printer.cursor + 1;
                if (not classes[type_name]) then
                    local referenced = {};
                    captureReferencedTypes(node, referenced);
                    hover_data[start] = {
                        type = type_name,
                        referenced = referenced,
                    }
                else
                    link_data[start] = type_name
                end
                return true;
            end,
        };

        local self = false;
        for i, param in type.parameters do
            if (i > (if (self) then 2 else 1)) then
                func ..= `, `;
            end
            local param_type = param.node.type;
            if (i == 1 and param.node.name and param.node.name.text == "self" and library.kind == "class") then
                self = true;
                func = ':' .. func;
                continue;
            end
            local ordered_param = ordered_params[i - if (self) then 1 else 0] or {
                name = if (param.node.name) then param.node.name.text else ``,
                types = {},
            };
            table.insert(ordered_param.types, param_type);
            ordered_params[i - if (self) then 1 else 0] = ordered_param;
            if (param.node.name) then
                func ..= `{param.node.name.text}: `;
            end
            func ..= `{writer.printType(param_type, capture, {offset = #func, params_depth = 1})}`;
        end
        if type.vararg then
            vararg = type.vararg;
            if (#type.parameters > if (self) then 1 else 0) then
                func ..= `, `;
            end
            if (type.vararg.tag == "generic") then
                func ..= `{type.vararg.name.text}...`;
            else
                func ..= `...{writer.printType(type.vararg.type, capture, {offset = #func + 3, params_depth = 1})}`
            end
        end
        func ..= `)`;
        func ..= `: {writer.printTypePack(type.returnTypes, capture, {offset = #func + 2, params_depth = 1})}`;

        for start, type_data in hover_data do
            local tname = type_data.type;
            if (not types[tname]) then
                continue;
            end
            local hover = `-- @hover: ({start},{start + #tname})[`;
            local classes_refs = {};
            for _, ref in type_data.referenced do
                if (not classes[ref]) then
                    continue;
                end
                table.insert(classes_refs, ref);
            end
            if (#classes_refs > 0) then
                hover ..= `-- references:\n`;
                for i, ref in classes_refs do
                    local idx = `-- ({i}) `;
                    hover ..= `-- @link: ({#idx + 1},{#idx + #ref + 1})[../objects/{ref}]\n`;
                    hover ..= `{idx}{ref}\n`;
                end
                hover ..= `\n`;
            end
            for _, ref in type_data.referenced do
                if (not types[ref] or ref == tname) then
                    continue;
                end
                hover ..= `{writer.printStatement(types[ref], nil, {})}\n\n`;
            end
            hover ..= `{writer.printStatement(types[tname], nil, {})}]`;
            table.insert(doc, hover);
        end
    
        for start, type_name in link_data do
            if (not classes[type_name]) then
                continue;
            end
            local link = `-- @link: ({start},{start + #type_name})[../objects/{type_name}]`;
            table.insert(doc, link);
        end
    
        table.insert(doc, func);
    end
    table.insert(doc, "```");
    
    if (#ordered_params > 0 or vararg) then
        local function combinedTypeName(types: {any})
            local type_name = "";
            local raw_type: string? = nil;
            local optional = false;
            local unique = false;
            for i, type in types do
                local type_text = "";
                if (type.tag == "reference") then
                    type_text = type.name.text;
                    raw_type = type_text;
                elseif (type.tag == "union") then
                    if (
                        type.types[1].node.tag ~= "reference"
                        or type.types[1].seperator
                        or type.types[2].node.tag ~= "optional"
                    ) then
                        type_text = printer.printType(type):gsub("^%s+", "");
                        optional = type_text:find("?$") ~= nil;
                    else
                        raw_type = type.types[1].node.name.text;
                        type_text = `{raw_type}?`;
                        optional = true;
                    end
                else
                    type_text = printer.printType(type):gsub("^%s+", "");
                    optional = type_text:find("?$") ~= nil;
                end
                if (type_text == type_name) then
                    continue;
                end
                if (i > 1) then
                    unique = true;
                    type_name ..= ` | `;
                end
                type_name ..= type_text;
            end
            if (#types == 0 or unique) then
                raw_type = nil;
            end
            return type_name, raw_type, optional;
        end

        if (docs["warning"]) then
            for _, warning in docs["warning"]:split("\n") do
                table.insert(doc, `<Callout type="warning">{warning}</Callout>`);
            end
        end

        table.insert(doc, `<details open>`);
        table.insert(doc, `<summary>Parameters</summary>`);
        for _, param in ordered_params do
            local type_name, raw_type, optional = combinedTypeName(param.types);
            table.insert(doc, `- \`{if (#param.name > 0) then `{param.name}: ` else ''}{type_name}{if (#fn_types ~= #param.types and not optional) then "?" else ""}\{:luau}\`{
                if (docs[`param+{param.name}`]) then
                    ` - {docs[`param+{param.name}`]}`
                else
                    ""
            }`);
            if (docs[`default_param+{param.name}`]) then
                table.insert(doc, `  - default: \`{docs[`default_param+{param.name}`]}\{:luau}\``);
                continue;
            end
            if (not raw_type) then
                continue;
            end
            local ref_type = types[raw_type];
            if (not ref_type or ref_type.type.tag ~= "table" or not documentations[raw_type]) then
                continue;
            end
            local d = documentations[raw_type] :: any;
            for _, entry in ref_type.type.entries do
                if (entry.kind ~= "property") then
                    continue;
                end
                local key = entry.key.text;
                local sub_docs = d.fields[key] or {};
                local parsed = if (sub_docs.docs) then parseDocumentation(sub_docs.docs) else {};
                table.insert(doc, `  - \`{key}: {writer.printType(entry.value, nil, {params_depth = 1})}\{:luau}\`{
                    if (parsed["@base"]) then
                        ` - {parsed["@base"]:gsub("\n", "\n    ")}`
                    else
                        ""
                }`);
                for tag, value in parsed do
                    if (tag == "@base") then
                        continue;
                    end
                    table.insert(doc, `    - {tag}: \`{value}\{:luau}\``);
                end
            end
        end
        if (vararg) then
            local type_name = "";
            local raw_type = nil;
            if (vararg.tag == "generic") then
                type_name ..= `{vararg.name.text}...`;
            else
                local res_type_name, res_raw_type, _ = combinedTypeName({vararg.type});
                type_name ..= `...{res_type_name}`;
                raw_type = res_raw_type;
            end
            table.insert(doc, `- \`{type_name}\{:luau}\`{
                if (docs[`param+{type_name}`]) then
                    ` - {docs[`param+{type_name}`]}`
                else
                    ""
            }`);
            if (raw_type) then
                local ref_type = types[raw_type];
                if (ref_type and ref_type.type.tag == "table" and documentations[raw_type]) then
                    local d = documentations[raw_type] :: any;
                    for _, entry in ref_type.type.entries do
                        if (entry.kind ~= "property") then
                            continue;
                        end
                        local key = entry.key.text;
                        local sub_docs = d.fields[key] or {};
                        local parsed = if (sub_docs.docs) then parseDocumentation(sub_docs.docs) else {};
                        table.insert(doc, `  - \`{key}: {printer.printType(entry.value)}\{:luau}\`{
                            if (parsed["@base"]) then
                                ` - {parsed["@base"]}`
                            else
                                ""
                        }`);
                        for tag, value in parsed do
                            if (tag == "@base") then
                                continue;
                            end
                            table.insert(doc, `    - {tag}: \`{value}\{:luau}\``);
                        end
                    end
                end
            end
        end
        table.insert(doc, `</details>`);
    end

    if (docs["throws"]) then
        table.insert(doc, `<details>`);
        table.insert(doc, `<summary>Throws</summary>`);
        for _, throw in docs["throws"]:split("\n") do
            table.insert(doc, `- {throw}`);
        end
        table.insert(doc, `</details>`);
    end

    table.insert(doc, '');

    return table.concat(doc, "\n");
end

local function resolvedTypeReferences(type: any, docs: any): any
    if (type.tag ~= "table") then
        return type;
    end
    local copy = table.clone(type);
    local copy_entries = table.clone(type.entries);
    local docs_fields = if (docs.fields) then table.clone(docs.fields) else {};
    for i, entry in copy_entries :: any do
        if (entry.kind ~= "property") then
            continue;
        end
        if (entry.value.tag == "reference") then
            local real_type = types[entry.value.name.text];
            if (not real_type) then
                continue;
            end
            local resolved_docs = documentations[entry.value.name.text];
            local copy_entry = table.clone(entry);
            copy_entry.value = resolvedTypeReferences(real_type.type, resolved_docs or {});
            copy_entries[i] = copy_entry;
            if (resolved_docs) then
                if (docs_fields[entry.key.text]) then
                    continue;
                end
                docs_fields[entry.key.text] = resolved_docs;
            end
        elseif (entry.value.tag == "table") then
            local copy_entry = table.clone(entry);
            local resolved_docs = docs_fields[entry.key.text];
            copy_entry.value = resolvedTypeReferences(entry.value, resolved_docs or {});
            copy_entries[i] = copy_entry;
            if (resolved_docs) then
                if (docs_fields[entry.key.text]) then
                    continue;
                end
                docs_fields[entry.key.text] = resolved_docs;
            end
        end
    end
    if (docs.fields) then
        docs.fields = docs_fields;
    end
    copy.entries = copy_entries;
    return copy;
end

local function captureDefinedLibrary(type: any): ({any}, {any}, {any})
    local functions = {};
    local namespaces = {};
    local properties = {};

    for _, entry in type.entries do
        if (entry.kind ~= "property") then
            continue;
        end
        if (entry.value.tag == "function") then
            table.insert(functions, {value = {entry.value}, key = entry.key});
        elseif (entry.value.tag == "table") then
            local fns = {};
            captureFunctionTypes(entry.value, fns);
            if (#fns > 0) then
                table.insert(namespaces, entry);
            else
                table.insert(properties, entry);
            end
        elseif (entry.value.tag == "intersection") then
            local fns = {};
            captureFunctionTypes(entry.value, fns);
            if (#fns > 0) then
                table.insert(functions, {value = fns, key = entry.key});
            else
                table.insert(properties, entry);
            end
        else
            table.insert(properties, entry);
        end
    end
    return functions, namespaces, properties;
end

local function generatePage(library: any, summary: any)
    local type_name = library.name;
    assert(documentations[type_name]);
    local documentation = table.clone(documentations[type_name]);
    assert(documentation.fields)
    local type = resolvedTypeReferences(library.type.type, documentation);
    assert(type.tag == "table", "Type must be a table");
    local page_info = parseDocumentation(summary);
    
    local page = {`\{/* This file was auto-generated with "zune-docs" */\}`, ``};

    table.insert(page, `# {page_info.name or type_name}`);
    if (page_info.global) then
        table.insert(page, `{page_info.global}`);
    end
    if (library.kind == "class") then
        local class_info = classes[type_name];
        assert(class_info)
        if (class_info.extends) then
            table.insert(page, `extends [\`{class_info.extends}\{:luau}\`](../objects/{class_info.extends})`);
        end
    end
    table.insert(page, `\n---\n{"import { Callout, Tabs } from 'nextra/components'"}\n`);
    if (page_info.summary) then
        table.insert(page, `{page_info.summary}\n`);
    end

    local functions, namespaces, properties = captureDefinedLibrary(type);

    if (#properties > 0) then
        table.insert(page, `## Properties`);
        for _, entry in properties do
            local key = entry.key.text;
            table.insert(page, `### {key}`);
            table.insert(page, `{generatePageProperty(
                key, entry.value, parseDocumentation((documentation.fields[key] or {docs = {}, fields = {}} :: any).docs)
            )}`);
        end
    end

    if (#functions > 0) then
        table.insert(page, `## {if (library.kind == "class") then "Methods" else "Functions"}`);
        for _, entry in functions do
            local key = entry.key.text;
            table.insert(page, `### {key}`);
            table.insert(page, `{generatePageFunction(
                library, key, entry.value, parseDocumentation((documentation.fields[key] or {docs = {}, fields = {}} :: any).docs)
            )}`);
        end
    end

    if (#namespaces > 0 and library.kind ~= "class") then
        table.insert(page, `## Namespaces`);
        for _, ns_entry in namespaces do
            local ns_functions, ns_namespaces, ns_properties = captureDefinedLibrary(ns_entry.value);

            table.insert(page, `### {ns_entry.key.text}`);
            local namespace_docs = (documentation.fields[ns_entry.key.text] or {docs = {}, fields = {}} :: any);
            
            local ns_docs = parseDocumentation(namespace_docs.docs);
            if (ns_docs["@base"]) then
                table.insert(page, ns_docs["@base"]);
                table.insert(page, "");
            end

            if (#ns_properties > 0) then
                table.insert(page, `---`);
                table.insert(page, `<h4 className="x:text-slate-900 x:dark:text-slate-100 x:mt-8 x:text-xl"><u>\`PROPERTIES\`</u></h4>`);
                for _, prop in ns_properties do
                    local key = prop.key.text;
                    table.insert(page, `#### {key}`);
                    table.insert(page, `{generatePageProperty(
                        key, prop.value, parseDocumentation((namespace_docs.fields[key] or {docs = {}, fields = {}} :: any).docs), ns_entry.key.text
                    )}`);
                end
            end
                
            if (#ns_functions > 0) then
                table.insert(page, `---`);
                table.insert(page, `<h4 className="x:text-slate-900 x:dark:text-slate-100 x:mt-8 x:text-xl"><u>\`FUNCTIONS\`</u></h4>`);
                for _, fn in ns_functions do
                    local key = fn.key.text;
                    table.insert(page, `#### {key}`);
                    table.insert(page, `{generatePageFunction(
                        library, key, fn.value, parseDocumentation((namespace_docs.fields[key] or {docs = {}, fields = {}} :: any).docs), ns_entry.key.text
                    )}`);
                end
            end

            if (#ns_namespaces > 0) then
                table.insert(page, `---`);
                table.insert(page, `<h4 className="x:text-slate-900 x:dark:text-slate-100 x:mt-8 x:text-xl"><u>\`NAMESPACES\`</u></h4>`);
                for _, entry in ns_namespaces do
                    local key = entry.key.text;
                    table.insert(page, `#### {key}`);
                    table.insert(page, `{generatePageProperty(
                        key, entry.value, parseDocumentation((documentation.fields[key] or {docs = {}, fields = {}} :: any).docs), `{ns_entry.key.text}.{key}`
                    )}`);
                end
            end
        end
    end

    return table.concat(page, "\n");
end

for library, type in libraries do
    print(`Generating page for {library}...`);
    fs.writeFile(`./src/content/docs/v0.5.0/api/{library}.mdx`, generatePage(type, assert(summaries[library])));
end

for class, type in classes do
    print(`Generating page for object {class}...`);
    fs.writeFile(`./src/content/docs/v0.5.0/objects/{class}.mdx`, generatePage({name = class, type = type.type, kind = "class"}, assert(documentations[class].docs)));
end

print("Pages Generated!");
