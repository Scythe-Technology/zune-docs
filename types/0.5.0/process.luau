--- @name Process
--- @global `zune.process`
--- @summary A library that interacts with the system process.

type __0__ = typeof(nil);
type FileHandle = typeof(nil :: any);

export type CPUArchitecture =
    | "aarch64"
    | "x86_64"
    -- | "x86"
    -- | "arm"
    -- | "aarch64_be"
    -- | "aarch64_32"
    -- | "riscv32"
    | "riscv64"
    -- | "wasm32"
    -- | "wasm64"
    -- | "armeb"
    -- | "arc"
    -- | "avr"
    -- | "bpfel"
    -- | "bpfeb"
    -- | "csky"
    -- | "dxil"
    -- | "hexagon"
    -- | "loongarch32"
    -- | "loongarch64"
    -- | "m68k"
    -- | "mips"
    -- | "mipsel"
    -- | "mips64"
    -- | "mips64el"
    -- | "msp430"
    -- | "powerpc"
    -- | "powerpcle"
    -- | "powerpc64"
    -- | "powerpc64le"
    -- | "r600"
    -- | "amdgcn"
    -- | "sparc"
    -- | "sparc64"
    -- | "sparcel"
    -- | "s390x"
    -- | "tce"
    -- | "tcele"
    -- | "thumb"
    -- | "thumbeb"
    -- | "xcore"
    -- | "xtensa"
    -- | "nvptx"
    -- | "nvptx64"
    -- | "le32"
    -- | "le64"
    -- | "amdil"
    -- | "amdil64"
    -- | "hsail"
    -- | "hsail64"
    -- | "spir"
    -- | "spir64"
    -- | "spirv"
    -- | "spirv32"
    -- | "spirv64"
    -- | "kalimba"
    -- | "shave"
    -- | "lanai"
    -- | "renderscript32"
    -- | "renderscript64"
    -- | "ve"
    -- | "spu_2"

export type OS =
    | "linux"
    | "windows"
    | "macos"
    -- | "freestanding"
    -- | "ananas"
    -- | "cloudabi"
    -- | "dragonfly"
    -- | "freebsd"
    -- | "fuchsia"
    -- | "ios"
    -- | "kfreebsd"
    -- | "lv2"
    -- | "netbsd"
    -- | "openbsd"
    -- | "solaris"
    -- | "uefi"
    -- | "zos"
    -- | "haiku"
    -- | "minix"
    -- | "rtems"
    -- | "nacl"
    -- | "aix"
    -- | "cuda"
    -- | "nvcl"
    -- | "amdhsa"
    -- | "ps4"
    -- | "ps5"
    -- | "elfiamcu"
    -- | "tvos"
    -- | "watchos"
    -- | "driverkit"
    -- | "visionos"
    -- | "mesa3d"
    -- | "contiki"
    -- | "amdpal"
    -- | "hermit"
    -- | "hurd"
    -- | "wasi"
    -- | "emscripten"
    -- | "shadermodel"
    -- | "liteos"
    -- | "serenity"
    -- | "opencl"
    -- | "glsl450"
    -- | "vulkan"
    -- | "plan9"
    -- | "illumos"
    -- | "other"

export type ProcessOptions = {
    --- The current working directory of the process.
    cwd: string?,
    --- The environment variables to set for the process.
    env: { [string]: string }?,
    --- The shell to use, `true` would use the common shell for your os.
    shell: (boolean | string)?,
    --- The stdio configuration for the process.
    stdio: ("inherit" | "pipe" | "ignore")?,
}

export type ProcessResult = {
    ok: boolean,
    code: number,
}

export type ProcessRunResult = ProcessResult & {
    stdout: string,
    stderr: string,
}

--- @class
type ProcessChild = {
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
    --- The operating system that the process is running on.
    os: OS,
    --- The cpu architecture that the process is running on.
    --- This property can have more possible values (Usually from a custom zune build for another architecture).
    --- Currently this is based on the official releases of zune.
    arch: CPUArchitecture,
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
    run: (exec: string, args: {string}?, opts: ProcessOptions?) -> ProcessRunResult,
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
