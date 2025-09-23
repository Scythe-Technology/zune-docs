--!strict

local fs = zune.fs;
local serde = zune.serde;

local writer = require("./utils/writer");
local visitor = require("./utils/visitor");

local prep = require("./utils/prep");

local types = prep.types;
local classes = prep.classes;
local libraries = prep.libraries;
local declarations = prep.declarations;
local documentations = prep.documentations;
local summaries = prep.summaries;

local type_docs = {};
local docs_order = {};

local function addDoc(field: string, value: any)
    assert(type_docs[field] == nil, `Duplicate documentation field: {field}`);
    type_docs[field] = value;
    table.insert(docs_order, field);
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

local function preprocessTypes()
    for type_name, type in declarations do
        local v = visitor.createVisitor()

        v.visitTypeReference = function(node: any)
            local library_name;
            for lib_name, lib in libraries do
                if (lib.name == node.name.text) then
                    library_name = lib_name;
                    break;
                end
            end
            if (library_name) then
                node.name.text = `_zune_{library_name}`;
            end
            return true;
        end

        visitor.visitType(type, v);

    end
    for name, type in libraries do
        local new_name = `_zune_{name}`;
        documentations[new_name] = documentations[type.name];
        documentations[type.name] = nil;
        type.type.name.text = new_name;

        type.type.export = {
            text = "export",
            leadingTrivia = {},
            trailingTrivia = {},
        };

        types[new_name] = type.type;
        types[type.name] = nil;
        type.name = new_name;
        
        local documentation = table.clone(documentations[type.name] or {docs = {}, fields = {}});
        type.type.type = resolvedTypeReferences(type.type.type, documentation)
        documentations[type.name] = documentation;
        if (type.type.tag == "typealias" and type.type.type.tag == "table") then
            for _, entry in type.type.type.entries do
                if (entry.kind ~= "property") then
                    continue;
                end
                if (entry.value.tag == "table") then
                    local new_token = {
                        tag = "reference",
                        name = {
                            text = `{new_name}_{entry.key.text}`,
                        },
                    };
                    local new_statement = {
                        kind = "typealias",
                        name = {
                            text = `{new_name}_{entry.key.text}`,
                        },
                        export = {
                            text = "export",
                        },
                        typeToken = {
                            text = "type",
                        },
                        equals = {
                            text = "=",
                        },
                        type = entry.value,
                    };
                    documentations[new_statement.name.text] = documentation.fields[entry.key.text] or {docs = {}, fields = {}};
                    types[new_statement.name.text] = new_statement;
                    entry.value = new_token;
                end
            end
        end
    end
end

preprocessTypes();

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
            value = doc:match("%-%-%-%s(.+)") or doc:match("%-%-%-%s*(.+)") :: any;
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

local function generateTypeDoc(name: string, type: any, docs: any): ()
    local writtenDocs = parseDocumentation(docs.docs);
    local doc = {
        documentation = writtenDocs["@base"] or docs.raw or "",
        code_sample = "",
    };
    addDoc(`@roblox/{name}`, doc);

    if (writtenDocs["example"]) then
        local existing_code = writtenDocs["example"]:find("```") ~= nil;
        doc.documentation ..= "\n";
        if (not existing_code) then
            doc.documentation ..= "```luau\n";
        end
        doc.documentation ..= writtenDocs["example"];
        if (not existing_code) then
            doc.documentation ..= "\n```";
        end
        doc.documentation ..= "\n";
    end
    if (type.tag == "table") then
        local keys = {};
        for _, entry in type.entries do
            if (entry.kind ~= "property") then
                continue;
            end
            local key = entry.key.text;
            local sub_docs = docs.fields and docs.fields[key] or {docs = {}, fields = {}};
            if (entry.value.tag == "reference") then
                if (types[entry.value.name.text]) then
                    keys[key] = `@roblox/globaltype/{entry.value.name.text}`;
                    continue;
                end
            end
            generateTypeDoc(`{name}.{key}`, entry.value, sub_docs);
            keys[key] = `@roblox/{name}.{key}`;
        end
        doc.keys = keys;
    elseif (type.tag == "function") then
        local params = {};
        local params_doc = {};
        for i, param in type.parameters do
            local param_name = if (param.node.name) then param.node.name.text else nil;
            local param_docs = writtenDocs[`param+{param_name}`];
            if (param_docs) then
                table.insert(params_doc, {
                    name = param_name,
                    docs = param_docs,
                    default = writtenDocs[`default_param+{param_name}`],
                });
            end
            generateTypeDoc(`{name}/param/{i - 1}`, param.node.type, {docs = {}, raw = param_docs, fields = {}});
            table.insert(params, {
                name = param_name,
                documentation = `@roblox/{name}/param/{i - 1}`,
            });
        end
        if (type.vararg) then
            local i = #type.parameters;
            local type_name = "";
            if (type.vararg.tag == "generic") then
                type_name ..= `{type.vararg.name.text}...`;
            else
                type_name ..= `...{writer.printType(type.vararg.type, nil, {})}`;
            end
            local param_docs = writtenDocs[`param+{type_name}`];
            generateTypeDoc(`{name}/param/{i}`, type.vararg, {docs = {}, raw = param_docs, fields = {}});
            table.insert(params, {
                name = "...",
                documentation = `@roblox/{name}/param/{i}`,
            });
        end
        if (#params_doc > 0) then
            doc.documentation ..= "\n\n**Parameters**\n";
            for _, param in params_doc do
                doc.documentation ..= `- \`{param.name}\`: {param.docs}\n`;
                if (param.default) then
                    doc.documentation ..= `  - default: \`{param.default}\`\n`;
                end
            end
        end
        doc.params = params;
        local returns = {};
        if (type.returnTypes.tag == "explicit") then
            for i, return_type in type.returnTypes.types do
                generateTypeDoc(`{name}/return/{i - 1}`, return_type.node, {docs = {}, fields = {}});
                table.insert(returns, `@roblox/{name}/return/{i - 1}`);
            end
        end
        doc.returns = returns;

        if (writtenDocs["throws"]) then
            doc.documentation ..= "\n\n**Throws**\n";
            for _, line in writtenDocs["throws"]:split("\n") do
                doc.documentation ..= `- {line}\n`;
            end
        end
    else
        if (doc.documentation == "" and doc.code_sample == "") then
            type_docs[`@roblox/{name}`] = nil;
        end
        return;
    end
end

local function generateTypeDocsFile(): string
    for decl, type in declarations do
        generateTypeDoc(`global/{decl}`, type, {docs = {}, fields = {}});
    end
    for name, type in types do
        local documentation = table.clone(documentations[name] or {docs = {}, fields = {}});
        if (not type.export) then
            continue
        end
        generateTypeDoc(`globaltype/{name}`, resolvedTypeReferences(type.type, documentation), documentation);
    end
    for name, type in classes do
        local documentation = table.clone(documentations[name] or {docs = {}, fields = {}});
        generateTypeDoc(`globaltype/{name}`, resolvedTypeReferences(type.type.type, documentation), documentation);
    end

    for library, summary in summaries do
        local lib_info = libraries[library];
        if (not lib_info) then
            continue;
        end
        local doc = type_docs[`@roblox/globaltype/{lib_info.type.name.text}`];
        local sum_docs = parseDocumentation(summary);
        doc.documentation = sum_docs["summary"] or ""
        doc.learn_more_link = `https://zune.sh/docs/v0.5.0/api/{library}`;
    end

    local result: {string} = {"{\n  "};
    local count = 1;
    for _, field in docs_order do
        local doc = type_docs[field];
        if (not doc) then
            continue;
        end
        if (count > 1) then
            table.insert(result, ",\n  ");
        end
        count += 1;
        local serialized_doc = serde.json.encode(doc, {
            pretty_indent = serde.json.indents.two_spaces,
        });
        table.insert(result, `"{field}": {serialized_doc:gsub("\n", "\n  ")}`);
    end
    table.insert(result, "\n}");

    return table.concat(result, "");
end

if (fs.stat("./tools/out").kind == "none") then
    fs.makeDir("./tools/out");
end
print("Generating zune.d.json...");
fs.writeFile("./tools/out/zune.d.json", generateTypeDocsFile());
print("Generated zune.d.json");
