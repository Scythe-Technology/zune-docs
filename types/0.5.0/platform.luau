--- @name Platform
--- @global `zune.platform`
--- @summary A library that provides information about the platform the runtime is running on, and some system information.

type __0__ = typeof(nil);
type FileHandle = typeof(nil :: any);

export type PlatformCPUArchitecture =
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
    | "powerpc64le"
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

export type PlatformOS =
    | "linux"
    | "windows"
    | "macos"
    -- | "freestanding"
    -- | "ananas"
    -- | "cloudabi"
    -- | "dragonfly"
    | "freebsd"
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

export type PlatformABI =
    | "none"
    | "gnu"
    | "gnuabin32"
    | "gnuabi64"
    | "gnueabi"
    | "gnueabihf"
    | "gnuf32"
    | "gnusf"
    | "gnux32"
    | "code16"
    | "eabi"
    | "eabihf"
    | "ilp32"
    | "android"
    | "androideabi"
    | "musl"
    | "muslabin32"
    | "muslabi64"
    | "musleabi"
    | "musleabihf"
    | "muslf32"
    | "muslsf"
    | "muslx32"
    | "msvc"
    | "itanium"
    | "cygnus"
    | "simulator"
    | "macabi"
    | "ohos"
    | "ohoseabi"

type PlatformLib = {
    --- The operating system the runtime was built for.
    os: PlatformOS,
    
    --- The ABI that the runtime was built for.
    abi: PlatformABI,
    
    --- The CPU architecture.
    cpu: {
        --- The architecture the runtime was built for.
        --- This property can have more possible values (Usually from a custom zune build for another architecture).
        --- Currently this is based on the official releases of zune.
        arch: PlatformCPUArchitecture,
        --- The endianness of the architecture the runtime was built for.
        endian: "big" | "little",
    },

    --- The async I/O backend that the runtime is currently using.
    async: "io_uring" | "epoll" | "kqueue" | "iocp",

    --- Gets the total amount of free memory available.
    --- @throws Platform Error
    getFreeMemory: () -> number,
    --- Gets the total amount of memory currently allocated by the runtime.
    --- @throws Platform Error
    getTotalMemory: () -> number,
    --- Gets the page size of the system.
    getPageSize: () -> number,
    --- Gets the kernel version of the operating system.
    --- @throws Memory Error
    --- @throws Platform Error
    getKernelVersion: () -> string,
    --- Gets the hostname of the current machine.
    --- @throws Memory Error
    --- @throws Platform Error
    getHostName: () -> string,
}

return {} :: PlatformLib;
