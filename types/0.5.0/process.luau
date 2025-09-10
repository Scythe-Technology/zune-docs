--- @name Process
--- @global `zune.process`
--- @summary A library that interacts with the system process.

type __0__ = typeof(nil);
type FileHandle = typeof(nil :: any);

export type ProcessOptions = {
    --- The current working directory of the process.
    cwd: string?,
    --- The environment variables to set for the process.
    env: { [string]: string }?,
    --- The shell to use, `true` would use the common shell for your os.
    shell: (boolean | string)?,
    --- The stdin configuration for the process.
    stdin: ("inherit" | "pipe" | "ignore")?,
    --- The stdout configuration for the process.
    stdout: ("inherit" | "pipe" | "ignore")?,
    --- The stderr configuration for the process.
    stderr: ("inherit" | "pipe" | "ignore")?,
}

export type ProcessResult = {
    ok: boolean,
    code: number,
}

export type ProcessRunResult<T> = ProcessResult & {
    stdout: T,
    stderr: T,
}

--- @class
type ProcessChild = {
    pid: number,
    stdin: FileHandle?,
    stdout: FileHandle?,
    stderr: FileHandle?,
    --- Kills the process and yields until the process exits.
    --- @throws Process Error
    wait: (self: ProcessChild) -> ProcessResult,
    --- Yields until the process exits.
    --- @throws Process Error
    kill: (self: ProcessChild) -> ProcessResult,
}

type ProcessLib = {
    --- The arguments passed to the process.
    args: { string },
    --- The process enviroment table.
    ---
    --- (Loaded from top to bottom)
    --- - Includes `.env` file in the current working directory.
    --- - Includes `.env.production` file in the current working directory. When `LUAU_ENV` is set to `PRODUCTION`.
    --- - Includes `.env.development` file in the current working directory. When `LUAU_ENV` is set to `DEVELOPMENT`.
    --- - Includes `.env.test` file in the current working directory. When `LUAU_ENV` is set to `TEST`.
    --- - Includes `.env.local` file in the current working directory.
    env: { [string]: string },
    --- Same behavior as `process.env`, does not update `process.env`.
    --- @throws IO Error
    --- @throws Memory Error
    loadEnv: () -> { [string]: string },
    --- Get the current working directory (absolute path).
    --- @throws IO Error
    --- @throws Memory Error
    cwd: () -> string,
    --- Get the current process ID.
    pid: () -> number,
    --- Creates a new process.
    --- @param exec The executable to run.
    --- @param args The arguments to pass to the executable.
    --- @param opts The options for the process.
    --- @throws Process Error
    create: (exec: string, args: {string}?, opts: ProcessOptions?) -> ProcessChild,
    --- Runs a new process, and yields for the result.
    --- @param exec The executable to run.
    --- @param args The arguments to pass to the executable.
    --- @param opts The options for the process.
    --- @throws Process Error
    run: 
        & ((exec: string) -> ProcessRunResult<string>)
        & ((exec: string, args: {string}?) -> ProcessRunResult<string>)
        & ((exec: string, args: {string}?, opts: ProcessOptions?, bytes: false?) -> ProcessRunResult<string?>)
        & ((exec: string, args: {string}?, opts: ProcessOptions?, bytes: true) -> ProcessRunResult<buffer?>)
        & ((exec: string, args: {string}?, opts: ProcessOptions?, bytes: boolean?) -> ProcessRunResult<string | buffer?>),
    --- Exits the process with the given code.
    --- @param code The exit code.
    exit: (code: number) -> never,
    --- Registers a signal handler.
    ---
    --- Supported signals:
    --- - `INT` - Interrupt signal (SIGINT).
    --- @param signal The signal to handle.
    --- @param callback The callback to call when the signal is received.
    --- @throws Process Error
    --- @throws Thread Error
    onSignal: (signal: "INT", callback: () -> ()) -> (),
}

return {} :: ProcessLib;
