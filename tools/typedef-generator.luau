--!strict

local fs = zune.fs;

local writer = require("./utils/writer");

local prep = require("./utils/prep");

local types = prep.types;
local declarations = prep.declarations;
local ordered_types = prep.ordered_types;
local classes = prep.classes;

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

if (fs.stat("./tools/out").kind == "none") then
    fs.writeDir("./tools/out");
end
fs.writeFile("./tools/out/zune.d.luau", generateDefintionFile());
