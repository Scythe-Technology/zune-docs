--- @name Globals
--- @summary Globals are available in every module. The listed globals are modified by the zune backend, refer to the [luau globals](https://luau.org/library#global-functions)
--- for the rest of the globals.


type FileSystemLib = typeof(require("./fs"));
type ProcessLib = typeof(require("./process"));
type TestingLib = typeof(require("./testing"));
type TaskLib = typeof(require("./task"));
type NetworkLib = typeof(require("./net"));
type LuauLib = typeof(require("./luau"));
type SerdeLib = typeof(require("./serde"));
type IoLib = typeof(require("./io"));
type CryptoLib = typeof(require("./crypto"));
type RegexLib = typeof(require("./regex"));
type DatetimeLib = typeof(require("./datetime"));
type FFILib = typeof(require("./ffi"));
type SQLiteLib = typeof(require("./sqlite"));
type RequireLib = typeof(require("./require"));
type RandomLib = typeof(require("./random"));
type ThreadLib = typeof(require("./thread"));
type MemLib = typeof(require("./mem"));

local _FILE: {
    source: string?,
    main: boolean,
}

local zune: {
    compiled: {
        optimize: number,
        debug: number,
        mode: "debug" | "release",
    }?,
    fs: FileSystemLib,
    process: ProcessLib,
    testing: TestingLib,
    task: TaskLib,
    net: NetworkLib,
    luau: LuauLib,
    serde: SerdeLib,
    io: IoLib,
    crypto: CryptoLib,
    regex: RegexLib,
    datetime: DatetimeLib,
    ffi: FFILib,
    sqlite: SQLiteLib,
    require: RequireLib,
    random: RandomLib,
    thread: ThreadLib,
    mem: MemLib,
}
