--!strict

local fs = zune.fs;

local writer = require("./utils/writer");
local visitor = require("./utils/visitor");

local prep = require("./utils/prep");

local types = prep.types;
local declarations = prep.declarations;
local ordered_types = prep.ordered_types;
local classes = prep.classes;
local libraries = prep.libraries;

local garbage_types = {};

local function resolvedTypeReferences(type: any): any
    if (type.tag ~= "table") then
        return type;
    end
    local copy = table.clone(type);
    local copy_entries = table.clone(type.entries);
    for i, entry in copy_entries :: any do
        if (entry.kind ~= "property") then
            continue;
        end
        if (entry.value.tag == "reference") then
            local real_type = types[entry.value.name.text];
            if (not real_type or real_type.export) then
                continue;
            end
            garbage_types[entry.value.name.text] = true;
            local copy_entry = table.clone(entry);
            copy_entry.value = resolvedTypeReferences(real_type.type);
            copy_entries[i] = copy_entry;
        elseif (entry.value.tag == "table") then
            local copy_entry = table.clone(entry);
            copy_entry.value = resolvedTypeReferences(entry.value);
            copy_entries[i] = copy_entry;
        end
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
        local old_name = type.name;
        local new_name = `_zune_{name}`;
        type.type.name.text = new_name;

        type.type.export = {
            text = "export",
            leadingTrivia = {},
            trailingTrivia = {},
        };

        types[new_name] = type.type;
        types[type.name] = nil;
        type.name = new_name;

        local new_list = {};
        for _, type in ordered_types[name] do
            if (type == old_name) then
                table.insert(new_list, new_name);
            else
                table.insert(new_list, type);
            end
        end
        ordered_types[name] = new_list;
        type.type.type = resolvedTypeReferences(type.type.type)
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
                        tag = "typealias",
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
                    table.insert(new_list, math.max(1, #new_list - 1), new_statement.name.text);
                    types[new_statement.name.text] = new_statement;
                    entry.value = new_token;
                end
            end
        end
    end

    for type_name, type in types do
        if libraries[type_name:sub(#("_zune_") + 1, -1)] then
            continue;
        end
        local v = visitor.createVisitor()

        v.visitTypeReference = function(node: any)
            if (garbage_types[node.name.text]) then
                garbage_types[node.name.text] = nil;
            end
        end

        visitor.visitType(type.type, v);
    end

    for garbage_type_name, _ in garbage_types do
        types[garbage_type_name] = nil;
    end
end

local function generateDefintionFile(): string
    local def = {`-- This file was auto-generated with "zune-docs"`,``};
    for library, list in ordered_types do
        table.insert(def, `--[[ {library} ]]`);
        for _, type_name in list do
            local class = classes[type_name];
            if (class) then
                table.insert(def, `declare class {type_name}{if (class.extends) then ` extends {class.extends}` else ""}`);
                table.insert(def, `{writer.printType(class.type.type, nil, {exclude_brace = 0})}`);
                table.insert(def, `end`);
                continue;
            end
            local type = types[type_name];
            if (not type) then
                continue;
            end
            table.insert(def, writer.printStatement(type, nil, {}));
        end
    end

    for decl, type in declarations do
        table.insert(def, `declare {decl}: {writer.printType(type, nil, {comments = false})}`);
    end

    return table.concat(def, "\n");
end

preprocessTypes();

if (fs.stat("./tools/out").kind == "none") then
    fs.makeDir("./tools/out");
end
print("Generating zune.d.luau...");
fs.writeFile("./tools/out/zune.d.luau", generateDefintionFile());
print("Generated zune.d.luau");
