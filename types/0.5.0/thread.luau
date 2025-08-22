--- @name Multi Threading
--- @global `zune.thread`
--- @summary A library to create multiple lua states and execute in parallel.

type __0__ = typeof(nil);

--- @class
type Thread = {
    --- Starts the thread.
    --- @throws Thread Error
    start: (self: Thread) -> (),
    --- Waits for the thread to finish.
    --- @throws Thread Error
    join: (self: Thread) -> (),
    --- Returns the status of the thread.
    --- @throws Memory Error
    status: (self: Thread) -> "ready" | "running" | "dead",
    --- Immediately receive or yields until a value is sent from the thread.
    --- @throws Thread Error
    --- @throws Memory Error
    receive: (self: Thread) -> (...any),
    --- Sends a value to the thread.
    --- @param ...any The values to send to the thread.
    --- @throws Thread Error
    --- @throws Memory Error
    send: (self: Thread, ...any) -> (),
}

export type ThreadLoadOptions = {
    --- @default "(thread)"
    chunk_name: string?,
    --- @default true
    native_code_gen: boolean?,
}

type ThreadLib = {
    --- Creates a new thread from a module. Resolves relative to the calling module.
    --- @param module The module to load in the new thread.
    --- @throws Luau Error
    --- @throws Require Error
    --- @throws Memory Error
    fromModule: (module: string) -> Thread,
    --- Creates a new thread from bytecode.
    --- @param bytecode The bytecode to load in the new thread.
    --- @param opts The options for loading the bytecode.
    --- @throws Luau Error
    --- @throws Memory Error
    fromBytecode: (bytecode: string | buffer, opts: ThreadLoadOptions?) -> Thread,
    --- Receives a message from the owner thread.
    ---
    --- Will error if called from the main thread.
    --- @throws Thread Error
    --- @throws Memory Error
    receive: () -> ...any,
    --- Sends a message to the owner thread.
    ---
    --- Will error if called from the main thread.
    --- @param ...any  The values to send to the owner thread.
    --- @throws Thread Error
    --- @throws Memory Error
    send: (...any) -> (),
    --- Gets the number of CPU cores available.
    --- If the number cannot be determined, it will return 1.
    getCpuCount: () -> number,
    --- The current context of running program.
    isThread: boolean,
}

return {} :: ThreadLib;
