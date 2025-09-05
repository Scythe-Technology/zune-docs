--- @name Luau
--- @global `zune.luau`
--- @summary A library to parse, compile and run luau code.

type __0__ = typeof(nil);

export type LuauCompileOptions = {
    --- The debug level for the compilation.
    debug_level: number?,
    --- The optimization level for the compilation.
    optimization_level: number?,
    --- The coverage level for the compilation.
    coverage_level: number?,
}

export type LuauLoadOptions = {
    --- The environment to use for the loaded function.
    env: {[any]: any}?,
    --- The name of the chunk, used for debugging.
    --- @default "(load)"
    chunk_name: string?,
    --- Whether to enable native code generation.
    --- @default true
    native_code_gen: boolean?,
}

export type LuauCoverageData = {
    name: string,
    line: number,
    depth: number,
    [number]: number,
};

type Position = {
    line: number,
    column: number,
}

export type Location = {
    begin: Position,
    ["end"]: Position,
}

export type ParseResult = {
    errors: {
        {
            message: string,
            location: Location,
        }
    }?,
    root: {any},
    eof: { text: "", position: Position, tag: "eof" },
    lines: number,
    lineOffsets: {number},
    hotcomments: {
        {
            header: boolean,
            content: string,
            location: Location,
        }
    },
}

type LuauLib = {
    --- Compiles `Luau` source code.
    --- @param source The source code to compile.
    --- @param opts The options for the compiler.
    --- @throws Luau Error
    --- @throws Memory Error
    compile: (source: string | buffer, opts: LuauCompileOptions?) -> buffer,
    --- Loads `Luau` bytecode into a function.
    --- @param bytecode The bytecode to load.
    --- @param opts The options for loading the bytecode.
    --- @throws Luau Error
    load: (bytecode: string | buffer, opts: LuauLoadOptions?) -> ((...any) -> ...any),
    --- Get coverage data from a function.
    --- @param fn The function to get the coverage data from.
    coverage: (fn: (...any) -> ...any) -> {LuauCoverageData},
    --- Parses `Luau` source code.
    --- @param src The source code to parse.
    --- @throws Memory Error
    parse: (src: string | buffer) -> ParseResult,
    --- Parses a `Luau` expression.
    --- @param src The expression to parse.
    --- @throws Memory Error
    parseExpr: (src: string | buffer) -> any,
    --- Runs a full garbage collection cycle.
    garbagecollect: () -> (),
}

return {} :: LuauLib;
