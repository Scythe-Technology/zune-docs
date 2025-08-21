--!strict

local visitor = require("./visitor")

type PrinterOptions = {
	comments: boolean?,
}

local function exhaustiveMatch(value: never): never
	error(`Unknown value in exhaustive match: {value}`)
end

local function printTrivia(trivia: any, opts: PrinterOptions): string
	if trivia.tag == "whitespace" then
		return trivia.text
	elseif trivia.tag == "comment" or trivia.tag == "blockcomment" then
		if opts.comments then
			return trivia.text
		else
			return ""
		end
	else
		return exhaustiveMatch(trivia.tag)
	end
end

local function printTriviaList(trivias: { any }, opts: PrinterOptions): string
	local result = {}
	for _, trivia in trivias do
		if (not opts.comments and (trivia.tag == "comment" or trivia.tag == "blockcomment")) then
			local last_trivia = trivias[#trivias]
			local last_comment;
			for _, t in trivias do
				if (t.tag ~= "whitespace") then
					last_comment = t;
				end
			end
			local trailing = if (trivia.tag == "comment") then
				"\n"
				elseif (last_comment) then
					last_comment.text:match("([%s]*)$") or ""
				else
					""
			return trailing .. (if (last_trivia and last_trivia ~= last_comment) then 
				last_trivia.text:match("([%s]*)$") or ""
			else "")
		end
		table.insert(result, printTrivia(trivia, opts))
	end
	return table.concat(result, "")
end

local function printToken(token: any, opts: PrinterOptions): string
	return printTriviaList(token.leadingTrivia, opts) .. token.text .. printTriviaList(token.trailingTrivia, opts)
end

local function printString(expr: any, opts: PrinterOptions): string
	local result = printTriviaList(expr.leadingTrivia, opts)

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

	result ..= printTriviaList(expr.trailingTrivia, opts)
	return result
end

local function printInterpolatedString(expr: any, opts: PrinterOptions): string
	local result = ""

	for i = 1, #expr.strings do
		result ..= printTriviaList(expr.strings[i].leadingTrivia, opts)
		if i == 1 then
			result ..= "`"
		else
			result ..= "}"
		end
		result ..= expr.strings[i].text

		if i == #expr.strings then
			result ..= "`"
			result ..= printTriviaList(expr.strings[i].trailingTrivia, opts)
		else
			result ..= "{"
			result ..= printTriviaList(expr.strings[i].trailingTrivia, opts)
			result ..= printExpr(expr.expressions[i])
		end
	end

	return result
end

local function printVisitor(overlap: any?, opts: PrinterOptions?)
	opts = opts or { comments = true }
	local printer = visitor.createVisitor()

	printer.result = buffer.create(1024)
	printer.cursor = 0

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
	printer.visitToken = function(node: any)
		write(printToken(node, opts :: PrinterOptions))
		return false
	end
	printer.visitString = function(node: any)
		write(printString(node, opts :: PrinterOptions))
		return false
	end
	printer.visitTypeString = function(node: any)
		write(printString(node, opts :: PrinterOptions))
		return false
	end
	printer.visitInterpolatedString = function(node: any)
		write(printInterpolatedString(node, opts :: PrinterOptions))
		return false
	end
	if (overlap) then
		for overlap, fn in overlap do
			printer[overlap] = function(node)
				return fn(node, printer)
			end;
		end
	end
	return printer
end

function printBlock(block: any, overlap: any?, opts: PrinterOptions?): string
	local printer = printVisitor(overlap, opts)
	visitor.visitBlock(block, printer)
	return buffer.readstring(printer.result, 0, printer.cursor)
end


function printExpr(block: any, overlap: any?, opts: PrinterOptions?): string
	local printer = printVisitor(overlap, opts)
	visitor.visitExpression(block, printer)
	return buffer.readstring(printer.result, 0, printer.cursor)
end

function printStatement(block: any, overlap: any?, opts: PrinterOptions?): string
	local printer = printVisitor(overlap, opts)
	visitor.visitStatement(block, printer)
	return buffer.readstring(printer.result, 0, printer.cursor)
end

function printType(block: any, overlap: any?, opts: PrinterOptions?): string
	local printer = printVisitor(overlap, opts)
	visitor.visitType(block, printer)
	return buffer.readstring(printer.result, 0, printer.cursor)
end

function printTypePack(block: any, overlap: any?, opts: PrinterOptions?): string
	local printer = printVisitor(overlap, opts)
	visitor.visitTypePack(block, printer)
	return buffer.readstring(printer.result, 0, printer.cursor)
end

return {
	printVisitor = printVisitor,
    printBlock = printBlock,
    printExpr = printExpr,
    printStatement = printStatement,
    printType = printType,
    printTypePack = printTypePack,
    printToken = printToken,
    printString = printString,
    printInterpolatedString = printInterpolatedString,
}
