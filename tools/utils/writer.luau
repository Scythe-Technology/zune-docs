--!strict

local visitor = require("./visitor")

type WriterOptions = {
    exclude_brace: number?,
    params_depth: number?,
    [string]: any,
}

local function exhaustiveMatch(value: never): never
    error(`Unknown value in exhaustive match: {value}`)
end

local function printTrivia(trivia: any): string
    if trivia.tag == "whitespace" then
        return trivia.text
    elseif trivia.tag == "comment" or trivia.tag == "blockcomment" then
        return trivia.text
    else
        return exhaustiveMatch(trivia.tag)
    end
end

local function printTriviaList(trivias: { any }): string
    local result = {}
    for _, trivia in trivias do
        table.insert(result, printTrivia(trivia))
    end
    return table.concat(result, "")
end

local function printToken(token: any): string
    return printTriviaList(token.leadingTrivia) .. token.text .. printTriviaList(token.trailingTrivia)
end

local function printString(expr: any): string
    local result = "" -- printTriviaList(expr.leadingTrivia)

    if expr.quoteStyle == "single" then
        result ..= `'{expr.text}'`
    elseif expr.quoteStyle == "double" then
        result ..= `"{expr.text}"`
    elseif expr.quoteStyle == "block" then
        local equals = string.rep("=", expr.blockDepth)
        result ..= `[{equals}[{expr.text}]{equals}]`
    elseif expr.quoteStyle == "interp" then
        result ..= "`" .. expr.text .. "`"
    else
        return exhaustiveMatch(expr.quoteStyle)
    end

    -- result ..= printTriviaList(expr.trailingTrivia)
    return result
end

local function printInterpolatedString(expr: any, opts: WriterOptions): string
    local result = ""

    for i = 1, #expr.strings do
        -- result ..= printTriviaList(expr.strings[i].leadingTrivia)
        if i == 1 then
            result ..= "`"
        else
            result ..= "}"
        end
        result ..= expr.strings[i].text

        if i == #expr.strings then
            result ..= "`"
            -- result ..= printTriviaList(expr.strings[i].trailingTrivia)
        else
            result ..= "{"
            -- result ..= printTriviaList(expr.strings[i].trailingTrivia)
            result ..= printExpr(expr.expressions[i], nil, opts)
        end
    end

    return result
end

local function writeVisitor(overlap: any?, opts: WriterOptions)
    local printer = visitor.createVisitor()

    printer.result = buffer.create(1024)
    printer.cursor = 0
    printer.table_depth = 0;
    printer.params_depth = opts.params_depth or 0;
    printer.opts = opts;

    opts.exclude_brace = opts.exclude_brace or -100;

    local function write(str: string)
        local totalSize = printer.cursor + #str
        local bufferSize = buffer.len(printer.result)

        if totalSize >= bufferSize then
            repeat
                bufferSize *= 2
            until bufferSize >= totalSize

            local newBuffer = buffer.create(bufferSize)
            buffer.copy(newBuffer, 0, printer.result)
            printer.result = newBuffer
        end

        buffer.writestring(printer.result, printer.cursor, str)
        printer.cursor = totalSize
    end
    local doubleSpacePunctuation = {'|', '&'};
    local function visitPunctuated<T>(list: any, visitor: any, apply: (T, any) -> (), new_line: boolean?)
        for _, item in list do
            apply(item.node, visitor)
            if item.separator then
                write(`{
                    if (not new_line and table.find(doubleSpacePunctuation, item.separator.text)) then ' ' else ''
                }{
                    if (new_line) then `\n{string.rep("    ", printer.table_depth)}` else ""
                }{item.separator.text} `)
            end
        end
    end
    if (overlap) then
        for overlap, fn in overlap do
            printer[overlap] = function(node)
                return fn(node, printer)
            end;
        end
    end
    printer.visitToken = function(node: any)
        write(printToken(node))
        return false
    end
    printer.visitString = function(node: any)
        write(printString(node))
        return false
    end
    printer.visitTypeNil = function(node: any)
        write(node.text)
        return false
    end
    printer.visitTypeBoolean = function(node: any)
        write(node.text)
        return false
    end
    printer.visitTypeNumber = function(node: any)
        write(node.text)
        return false
    end
    printer.visitTypeString = function(node: any)
        write(printString(node))
        return false
    end
    printer.visitInterpolatedString = function(node: any)
        write(printInterpolatedString(node, opts))
        return false
    end
    printer.visitTypeReference = function(node: any)
        if (overlap) then
            if overlap.visitTypeReference and not overlap.visitTypeReference(node, printer) then
                return false
            end
        end
        if node.prefix then
            write(node.prefix.text)
        end
        if node.prefixPoint then
            write(node.prefixPoint.text)
        end
        write(node.name.text)
        if node.openParameters then
            write(node.openParameters.text)
        end
        if node.parameters then
            visitPunctuated(node.parameters, printer, visitor.visitTypeOrPack)
        end
        if node.closeParameters then
            write(node.closeParameters.text)
        end
        return false
    end
    printer.visitTypeReference = function(node: any)
        if (overlap) then
            if overlap.visitTypeReference and not overlap.visitTypeReference(node, printer) then
                return false
            end
        end
        if node.prefix then
            write(node.prefix.text)
        end
        if node.prefixPoint then
            write(node.prefixPoint.text)
        end
        write(node.name.text)
        if node.openParameters then
            write(node.openParameters.text)
        end
        if node.parameters then
            visitPunctuated(node.parameters, printer, visitor.visitTypeOrPack)
        end
        if node.closeParameters then
            write(node.closeParameters.text)
        end
        return false
    end
    printer.visitTypeAlias = function(node: any)
        if (overlap) then
            if overlap.visitTypeAlias and not overlap.visitTypeAlias(node, printer) then
                return false
            end
        end
        if node.export then
            write(`{node.export.text} `)
        end
        write(`{node.typeToken.text} `)
        write(node.name.text)
        if node.openGenerics then
            write(node.openGenerics.text)
        end
        if node.generics then
            visitPunctuated(node.generics, printer, visitor.visitGeneric)
        end
        if node.genericPacks then
            visitPunctuated(node.genericPacks, printer, visitor.visitGenericPack)
        end
        if node.closeGenerics then
            write(node.closeGenerics.text)
        end
        write(` {node.equals.text} `)
        visitor.visitType(node.type, printer)
        return false
    end
    local function visitTypeFunctionParameter(node: any)
        if node.name then
            write(node.name.text)
        end
        if node.colon then
            write(`{node.colon.text} `)
        end
        visitor.visitType(node.type, printer)
    end
    printer.visitTypeFunction = function(node: any)
        if (overlap) then
            if overlap.visitTypeFunction and not overlap.visitTypeFunction(node, printer) then
                return false
            end
        end
        if node.openGenerics then
            write(node.openGenerics.text);
        end
        if node.generics then
            visitPunctuated(node.generics, printer, visitor.visitGeneric)
        end
        if node.genericPacks then
            visitPunctuated(node.genericPacks, printer, visitor.visitGenericPack)
        end
        if node.closeGenerics then
            write(node.closeGenerics.text)
        end
        write(node.openParens.text)
        printer.params_depth += 1;
        visitPunctuated(node.parameters, printer, visitTypeFunctionParameter)
        if node.vararg then
            visitor.visitTypePack(node.vararg, printer)
        end
        write(node.closeParens.text)
        write(` {node.returnArrow.text} `)
        visitor.visitTypePack(node.returnTypes, printer)
        printer.params_depth -= 1;
        return false
    end
    printer.visitTypePackExplicit = function(node: any)
        if (overlap) then
            if overlap.visitTypePackExplicit and not overlap.visitTypePackExplicit(node, printer) then
                return false
            end
        end
        if node.openParens then
            write(node.openParens.text)
        end
        visitPunctuated(node.types, printer, visitor.visitType)
        if node.tailType then
            visitor.visitTypePack(node.tailType, printer)
        end
        if node.closeParens then
            write(node.closeParens.text)
        end
        return false
    end
    printer.visitTypePackVariadic = function(node: any)
        if (overlap) then
            if overlap.visitTypePackVariadic and not overlap.visitTypePackVariadic(node, printer) then
                return false
            end
        end
        if node.ellipsis then
            write(node.ellipsis.text)
        end
        visitor.visitType(node.type, printer)
        return false
    end
    printer.visitTypeGroup = function(node: any)
        if (overlap) then
            if overlap.visitTypeGroup and not overlap.visitTypeGroup(node, printer) then
                return false
            end
        end
        write(node.openParens.text)
        visitor.visitType(node.type, printer)
        write(node.closeParens.text)
        return false
    end
    printer.visitTypeUnion = function(node: any)
        if (overlap) then
            if overlap.visitTypeUnion and not overlap.visitTypeUnion(node, printer) then
                return false
            end
        end
        if node.leading then
            printer.table_depth += 1;
            write(`\n{string.rep("    ", printer.table_depth)}{node.leading.text} `)
        end
        visitPunctuated(node.types, printer, visitor.visitType, node.leading ~= nil)
        if node.leading then
            printer.table_depth -= 1;
        end
        return false
    end
    printer.visitTypeIntersection = function(node: any)
        if (overlap) then
            if overlap.visitTypeIntersection and not overlap.visitTypeIntersection(node, printer) then
                return false
            end
        end
        if node.leading then
            printer.table_depth += 1;
            write(`\n{string.rep("    ", printer.table_depth)}{node.leading.text} `)
        end
        visitPunctuated(node.types, printer, visitor.visitType, node.leading ~= nil)
        if node.leading then
            printer.table_depth -= 1;
        end
        return false
    end
    printer.visitTableItem = function(node: any)
        if (overlap) then
            if overlap.visitTableItem and not overlap.visitTableItem(node, printer) then
                return false
            end
        end
        if node.kind == "list" then
            visitor.visitExpression(node.value, printer)
        elseif node.kind == "record" then
            write(`{string.rep("    ", printer.table_depth)}{node.key.text} = `)
            visitor.visitExpression(node.value, printer)
        elseif node.kind == "general" then
            write(node.indexerOpen.text)
            visitor.visitExpression(node.key, printer)
            write(node.indexerClose.text)
            write(node.equals.text)
            visitor.visitExpression(node.value, visitor)
        else
            exhaustiveMatch(node.kind)
        end
        if node.separator then
            write(`{node.separator.text}`)
        end
        return false
    end
    printer.visitTypeTable = function(node: any)
        if (overlap) then
            if overlap.visitTypeTable and not overlap.visitTypeTable(node, printer) then
                return false
            end
        end
        if (opts.exclude_brace and printer.table_depth > opts.exclude_brace) then
            write(node.openBrace.text)
            if (#node.entries > 0) then
                write(if (printer.params_depth == 0) then "\n" else "");
            end
        end
        printer.table_depth += 1;
        for i, entry in node.entries do
            if (printer.params_depth == 0) then
                write(string.rep("    ", printer.table_depth))
            end
            if entry.access then
                write(entry.access.text)
            end
            if entry.kind == "indexer" then
                write(entry.indexerOpen.text)
                visitor.visitType(entry.key, printer)
                write(entry.indexerClose.text)
            elseif entry.kind == "stringproperty" then
                write(entry.indexerOpen.text)
                printer.visitTypeString(entry.key)
                write(entry.indexerClose.text)
            else
                write(entry.key.text)
            end
            write(`{entry.colon.text} `)
            visitor.visitType(entry.value, printer)
            if entry.separator then
                if (opts.exclude_brace and printer.table_depth - 1 > opts.exclude_brace) then
                    write(`{entry.separator.text}`)
                end
                write(if (i < #node.entries and printer.params_depth == 0) then "\n" else " ");
            end
        end
        printer.table_depth -= 1;
        if (opts.exclude_brace and printer.table_depth > opts.exclude_brace) then
            if (#node.entries > 0) then
                write(if (printer.params_depth == 0) then "\n" else "")
            end
            if (printer.table_depth > 0 and printer.params_depth == 0) then
                write(`{string.rep("    ", printer.table_depth)}`)
            end
            write(`{node.closeBrace.text}`)
        end
        return false
    end
    printer.visitTypeArray = function(node: any)
        if (overlap) then
            if overlap.visitTypeArray and not overlap.visitTypeArray(node, printer) then
                return false
            end
        end
        write(node.openBrace.text)
        if node.access then
            write(node.access.text)
        end
        visitor.visitType(node.type, printer)
        write(node.closeBrace.text)
        return false
    end
    return printer
end

function printBlock(block: any, overlap: any?, opts: WriterOptions): string
    local printer = writeVisitor(overlap, opts)
    visitor.visitBlock(block, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end


function printExpr(block: any, overlap: any?, opts: WriterOptions): string
    local printer = writeVisitor(overlap, opts)
    visitor.visitExpression(block, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

function printStatement(block: any, overlap: any?, opts: WriterOptions): string
    local printer = writeVisitor(overlap, opts)
    visitor.visitStatement(block, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

function printType(block: any, overlap: any?, opts: WriterOptions): string
    local printer = writeVisitor(overlap, opts)
    visitor.visitType(block, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

function printTypePack(block: any, overlap: any?, opts: WriterOptions): string
    local printer = writeVisitor(overlap, opts)
    visitor.visitTypePack(block, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

return {
    writeVisitor = writeVisitor,
    printBlock = printBlock,
    printExpr = printExpr,
    printStatement = printStatement,
    printType = printType,
    printTypePack = printTypePack,
    printToken = printToken,
    printString = printString,
    printInterpolatedString = printInterpolatedString,
}
