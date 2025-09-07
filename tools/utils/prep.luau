---!strict
---!native
local fs = zune.fs;
local luau = zune.luau;
local process = zune.process;

local docs_path = process.args[2] or error("No documentation path provided");

assert(fs.stat(docs_path).kind == "directory", "The provided path is not a directory");

local type_paths = {};
for _, entry in fs.entries(docs_path) do
    if (entry.kind == "file") then
        table.insert(type_paths, fs.path.join(docs_path, entry.name));
    end
end

local function extractComments(token: any): { string }
    local comments = {};
    for _, trivia in token.leadingTrivia do
        if trivia.tag == "comment" or trivia.tag == "blockcomment" then
            table.insert(comments, trivia.text);
        end
    end
    return comments;
end

local function extractDocs(token: any, type_docs: any)
    local stat_docs = {};
    local docs = {
        docs = type_docs,
        fields = if (token.tag == "table") then stat_docs else nil,
    };

    if (token.tag == "table") then
         for _, entry in token.entries do
            if (entry.kind ~= "property") then
                continue;
            end
            local key = entry.key.text;
            local sub_docs = extractComments(entry.key);
            if (#sub_docs > 0) then
                stat_docs[key] = {
                    docs = sub_docs,
                };
            end
            local value = entry.value;
            if (value.tag == "table") then
                stat_docs[key] = extractDocs(value, sub_docs);
            end
        end
    end

    return docs;
end

local types = {};
local libraries = {};
local declarations = {};
local documentations = {}
local summaries = {};
local ordered_types = {};

for _, type_path in type_paths do
    local library_name = fs.path.stem(type_path);
    local contents = fs.readFile(type_path);
    local result: any = luau.parse(contents);
    if (result.errors) then
        error(result.errors);
    end
    if (result.root.statements[1]) then
        for _, value in result.root.statements[1] do
            if (type(value) == "table" and value.leadingTrivia) then
                local summary = extractComments(value);
                if (#summary > 0) then
                    summaries[library_name] = summary;
                end
            end
        end
    end
    local ordered = {};
    ordered_types[library_name] = ordered;
    local type_library: string?;
    for _, statement in result.root.statements do
        if (statement.tag == "local") then
            local var = statement.variables[1];
            local type = var.node.annotation;
            declarations[var.node.name.text] = type;
        elseif (statement.tag == "typealias") then
            if (statement.type.tag == "typeof") then
                continue;
            end
            if (types[statement.name.text]) then
                error(`Type {statement.name.text} is already defined`);
            end
            types[statement.name.text] = statement;
            if (not table.find(ordered, statement.name.text)) then
                table.insert(ordered, statement.name.text);
            end
            local type_docs = if (statement.export) then extractComments(statement.export) else extractComments(statement.typeToken);
            documentations[statement.name.text] = extractDocs(statement.type, type_docs);
        elseif (statement.tag == "return") then
            type_library = statement.expressions[1].node.annotation.name.text;
        end
    end
    if (type_library) then
        libraries[library_name] = {
            name = type_library,
            type = types[type_library],
            kind = "library",
        };
    end
    if (#ordered == 0) then
        ordered_types[library_name] = nil;
    end
end

local classes = {};

for type_name, type_value in types do
    local docs = documentations[type_name];
    if (docs.docs[1] and docs.docs[1]:find("%-%-%-[%s*]@class")) then
        types[type_name] = nil;
        local extends = docs.docs[1]:match("%-%-%-[%s*]@class%s*([%w_]+)");
        classes[type_name] = {
            type = type_value,
            extends = extends,
        };
    end
end

return {
    types = types,
    libraries = libraries,
    declarations = declarations,
    documentations = documentations,
    summaries = summaries,
    ordered_types = ordered_types,
    classes = classes,
}
