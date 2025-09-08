--- @name File System
--- @global `zune.fs`
--- @summary A library that provides access to the file system.

type __0__ = typeof(nil);

export type MetadataKind =
    | "file"
    | "directory"
    | "sym_link"
    | "door"
    | "character_device"
    | "unix_domain_socket"
    | "block_device"
    | "event_port"
    | "named_pipe"
    | "whiteout"
    | "unknown"

export type Metadata = {
    kind: MetadataKind,
    symlink: boolean,
    created_at: number,
    modified_at: number,
    accessed_at: number,
    size: number,
    permissions: {
        read_only: boolean,
    },
}

export type FileStat = {
    kind: MetadataKind,
    changed_at: number,
    modified_at: number,
    accessed_at: number,
    size: number,
    mode: number,
} | {
    kind: "none",
}

--- @class
--- @summary A FileHandle is an object that represents an open file. 
--- It provides methods to read, write, and manipulate the file.
type FileHandle = {
    --- read from the file
    --- @param amount The amount of bytes to read, if not provided, it will read until EOF or luau limit
    --- @param bytes If true, the function will return a `buffer` instead of a `string`.
    --- @throws IO Error
    read:
        & ((self: FileHandle, amount: number?) -> string)
        & ((self: FileHandle, amount: number?, bytes: false?) -> string)
        & ((self: FileHandle, amount: number?, bytes: true) -> buffer)
        & ((self: FileHandle, amount: number?, bytes: boolean?) -> string | buffer),
    --- Read the contents of the file synchronously.
    --- @param amount The amount of bytes to read, if not provided, it will read until EOF or luau limit
    --- @param bytes If true, the function will return a `buffer` instead of a `string`.
    --- @throws IO Error
    readSync:
        & ((self: FileHandle, amount: number?) -> string)
        & ((self: FileHandle, amount: number?, bytes: false?) -> string)
        & ((self: FileHandle, amount: number?, bytes: true) -> buffer)
        & ((self: FileHandle, amount: number?, bytes: boolean?) -> string | buffer),
    --- Write the contents to the file.
    --- @param contents The contents to write to the file.
    --- @throws IO Error
    write: (self: FileHandle, contents: string | buffer) -> (),
    --- Write the contents to the file synchronously.
    --- @param contents The contents to write to the file.
    --- @throws IO Error
    writeSync: (self: FileHandle, contents: string | buffer) -> (),
    --- Append the contents to the file.
    --- @param contents The contents to append to the file.
    --- @throws IO Error
    append: (self: FileHandle, contents: string | buffer) -> (),
    --- Append the contents to the file synchronously.
    --- @param contents The contents to append to the file.
    --- @throws IO Error
    appendSync: (self: FileHandle, contents: string | buffer) -> (),
    --- Returns the size of the file in bytes.
    --- @throws IO Error
    getSize: (self: FileHandle) -> number,
    --- Returns the current seek position of the file.
    --- @throws IO Error
    getSeekPosition: (self: FileHandle) -> number,
    --- Seeks the file from the end.
    --- @param amount The amount of bytes to seek from the end of the file.
    --- @default_param amount 0
    --- @throws IO Error
    seekFromEnd: (self: FileHandle, amount: number?) -> (),
    --- Seeks the file to a specific position.
    --- @param amount The amount of bytes to seek from the beginning of the file.
    --- @default_param amount 0
    --- @throws IO Error
    seekTo: (self: FileHandle, amount: number?) -> (),
    --- Seeks the file by relative to the current position.
    --- @param amount The amount of bytes to seek from the current seek.
    --- @default_param amount 0
    --- @throws IO Error
    seekBy: (self: FileHandle, amount: number?) -> (),
    --- Locks the file for reading or writing.
    --- @param lockMode The mode to lock the file.
    --- @default_param lockMode "exclusive"
    --- @throws IO Error
    lock: (self: FileHandle, lockMode: ("shared" | "exclusive" | "none")?) -> boolean,
    --- Unlocks from the current lock mode.
    --- @throws IO Error
    unlock: (self: FileHandle) -> (),
    --- Flushes the file. Writes the contents to the disk. This does not yield, it would block the process until the file is flushed.
    --- @throws IO Error
    sync: (self: FileHandle) -> (),
    --- Get readonly state or set the file to readonly.
    --- @param enabled Whether to set the file to readonly, if nil, returns the current state.
    --- @throws IO Error
    readonly:
        & ((self: FileHandle) -> boolean)
        & ((self: FileHandle, enabled: boolean) -> ()),
    --- Close the file handle.
    --- @throws IO Error
    close: (self: FileHandle) -> (),
}

--- @class
type FileWatcher = {
    --- This will stop the watcher from watching the file or directory.
    stop: (self: FileWatcher) -> (),
}

export type FileCreateOptions = {
    --- If true, the function will fail if the file already exists.
    --- @default false
    exclusive: boolean?,
    --- If true, the file will be truncated if it already exists.
    --- @default true
    truncate: boolean?,
}

export type FileOpenOptions = {
    --- If provided, the file will be opened in the specified mode.
    --- @modes "r" | "w" | "rw"
    --- @default "rw"
    mode: string?,
}

type DirectoryEntry = {
    name: string,
    kind: MetadataKind,
}

type WatchEvent = "created" | "modified" | "moved" | "renamed" | "deleted" | "metadata"

type FileSystemLib = {
    --- Creates a file. If the file already exists, the function will throw an error only when `exclusive` is `true`.
    --- @param path The path to the file to open/create.
    --- @param opts The create options.
    --- @throws IO Error
    createFile: (path: string, opts: FileCreateOptions?) -> FileHandle,
    --- Opens a file. If the file does not exists, the function will throw an error.
    --- @param path The path to the file to open.
    --- @param opts The open options.
    --- @throws IO Error
    openFile: (path: string, opts: FileOpenOptions?) -> FileHandle,
    --- Read the contents of a file from the provided path.
    --- @param path The path to the file to read.
    --- @param bytes If true, returns a `buffer` instead of a `string`.
    --- @default_param bytes false
    --- @throws IO Error
    readFile:
        & ((path: string) -> string)
        & ((path: string, bytes: false?) -> string)
        & ((path: string, bytes: true) -> buffer)
        & ((path: string, bytes: boolean) -> string | buffer),
    --- Read the contents of a file from the provided path synchronously.
    --- @param path The path to the file to read.
    --- @param bytes If true, returns a `buffer` instead of a `string`.
    --- @default_param bytes false
    --- @throws IO Error
    readFileSync:
        & ((path: string) -> string)
        & ((path: string, bytes: false?) -> string)
        & ((path: string, bytes: true) -> buffer)
        & ((path: string, bytes: boolean) -> string | buffer),
    --- Get directory entries from the provided path.
    --- @param path The path to the directory to read.
    --- @throws IO Error
    entries: (path: string) -> { DirectoryEntry },
    --- Write the contents to a file at the provided path.
    --- @param path The path to the file to write.
    --- @param contents The contents to write to the file. (This may be limited to the max luau `string`).
    --- @throws IO Error
    writeFile: (path: string, contents: string | buffer) -> (),
    --- Write the contents to a file at the provided path synchronously.
    --- @param path The path to the file to write.
    --- @param contents The contents to write to the file. (This may be limited to the max luau `string`).
    --- @throws IO Error
    writeFileSync: (path: string, contents: string | buffer) -> (),
    --- Creates a directory at the provided path.
    --- @param path The path to the directory to create.
    --- @param recursive If true, the function will create all parent directories if they do not
    --- @default_param recursive false
    --- @throws IO Error
    makeDir:  (path: string, recursive: boolean?) -> (),
    --- Removes a file at the provided path.
    --- @param path The path to the file to remove.
    --- @throws IO Error
    deleteFile: (path: string) -> (),
    --- Removes a directory at the provided path.
    --- @param path The path to the directory to remove.
    --- @param recursive If true, the function will remove all files and directories inside the directory.
    --- @default_param recursive false
    --- @throws IO Error
    deleteDir: (path: string, recursive: boolean?) -> (),
    --- Get metadata of a file or directory at the provided path.
    --- @param path The path to the file or directory to get metadata from.
    --- @throws IO Error
    metadata: (path: string) -> Metadata,
    --- Get stats of the provided path.
    --- This should not error, as if a path does not exist, it will always return
    --- a `FileStat` with `kind` set to `"none"`.
    --- @param path The path to the file or directory to get stats from.
    stat: (path: string) -> FileStat,
    --- Moves a file or directory from one path to another path.
    --- @param from The path to the file or directory to move.
    --- @param to The path to move the file or directory to.
    --- @param overwrite If true, the function will overwrite the file if `to` exists.
    --- @default_param overwrite false
    --- @throws IO Error
    move: (from: string, to: string, overwrite: boolean?) -> (),
    --- Copies a file or directory from one path to another path.
    --- @param from The path to the file or directory to copy.
    --- @param to The path to copy the file or directory to.
    --- @param overwrite If true, the function will overwrite the file if it exists.
    --- @default_param overwrite false
    --- @throws IO Error
    copy: (from: string, to: string, overwrite: boolean?) -> (),
    --- Create a symbolic link from one path to another path.
    --- @warning Windows: must have developer mode enabled
    --- @param from The path to the file or directory to link.
    --- @param to The path to link the file or directory to.
    --- @throws IO Error
    --- @throws Not Supported (`Windows`)
    symlink: (from: string, to: string) -> (),
    --- Get the path to the current executable.
    --- @throws IO Error
    getExePath: () -> string,
    --- Get absolute path to the file or directory.
    --- @param path The path to resolve.
    realPath: (path: string) -> string,
    --- Watches a directory for changes.
    ---
    --- *Does not watch subdirectories.*
    --- *Windows: Can watch changes in first child subdirectories.*
    --- @param path The path to the directory to watch.
    --- @param callback The function to call when a change is detected.
    --- @throws IO Error
    watch: (path: string, callback: (path: string, events: {WatchEvent}) -> ()) -> FileWatcher,
    --- When called from a bundled context, this would get and load the contents of the embedded file.
    --- Otherwise would synchronously read a file relative to the calling script.
    --- @param path The file path relative to calling script.
    --- @throws IO Error
    embedFile: (path: string) -> buffer,
    --- Will return the list of all embedded files, the table will always be empty when called from an unbundled context.
    --- @throws Memory Error
    embeddedFiles: () -> { string },
    --- Will return the list of all embedded scripts, the table will always be empty when called from an unbundled context.
    --- @throws Memory Error
    embeddedScripts: () -> { string },

    path: {
        --- Joins multiple paths into a single path with OS specific separator.
        --- @example
        --- - (`lib`, `main.luau`) -> `lib/main.luau`
        --- - (`lib`, `lib/main.luau`) -> `lib/lib/main.luau`
        --- @param ...string The paths to join. if no arguments are provided, the result will be `nil`.
        --- @docs <Tabs items={['Unix', 'Windows']}>
        ---   <Tabs.Tab>
        ---   - (`lib`, `main.luau`) -> `lib/main.luau`
        ---   - (`lib`, `lib/main.luau`) -> `lib/lib/main.luau`
        ---   </Tabs.Tab>
        ---   <Tabs.Tab>
        ---   - (`lib`, `main.luau`) -> `lib\main.luau`
        ---   - (`lib`, `lib\main.luau`) -> `lib\lib\main.luau`
        ---   </Tabs.Tab>
        --- </Tabs>
        join: (...string) -> string,
        --- Gets the relative path from one path to another.
        --- @example
        --- - (`lib`, `lib/main.luau`) -> `main.luau`
        --- - (`lib`, `main.luau`) -> `../main.luau`
        --- @param from The path to resolve from.
        --- @param to The path to resolve to.
        --- @docs <Tabs items={['Unix', 'Windows']}>
        ---   <Tabs.Tab>
        ---   - (`lib`, `lib/main.luau`) -> `main.luau`
        ---   - (`lib`, `main.luau`) -> `../main.luau`
        ---   </Tabs.Tab>
        ---   <Tabs.Tab>
        ---   - (`lib`, `lib/main.luau`) -> `main.luau`
        ---   - (`lib`, `main.luau`) -> `..\main.luau`
        ---   </Tabs.Tab>
        --- </Tabs>
        relative: (from: string, to: string) -> string,
        --- Resolves relatives and parent paths combined.
        --- @example
        --- - (`lib`, `main.luau`) -> `lib/main.luau`
        --- - (`lib`, `../main.luau`) -> `main.luau`
        --- @param ...string The paths to resolve.
        --- @docs <Tabs items={['Unix', 'Windows']}>
        ---   <Tabs.Tab>
        ---   - (`lib`, `main.luau`) -> `lib/main.luau`
        ---   - (`lib`, `../main.luau`) -> `main.luau`
        ---   </Tabs.Tab>
        ---   <Tabs.Tab>
        ---   - (`lib`, `main.luau`) -> `lib\main.luau`
        ---   - (`lib`, `../main.luau`) -> `main.luau`
        ---   </Tabs.Tab>
        --- </Tabs>
        resolve: (...string) -> string,
        --- Returns the directory name of the provided path, will return nil if there are no more directories.
        --- - `lib/main.luau` -> `lib`
        --- - `lib` -> nil
        --- @param path The path to get the directory name from.
        dirname: (path: string) -> string?,
        --- Returns the base name of the provided path.
        --- - `/lib/main.test.luau` -> `main.test.luau`
        --- - `/lib/main.luau` -> `main.luau`
        --- @param path The path to get the base name from.
        basename: (path: string) -> string,
        --- Returns the name of file without extension of the provided path.
        --- - `/lib/main.test.luau` -> `main.test`
        --- - `/lib/main.luau` -> `main`
        --- @param path The path to get the stem from.
        stem: (path: string) -> string,
        --- Returns the extension of the provided path.
        --- - `/lib/main.test.luau` -> `.luau`
        --- - `/lib/main.luau` -> `.luau`
        --- - `/lib/main.` -> `.`
        --- - `/lib/main` -> ``
        --- @param path The path to get the extension from.
        extension: (path: string) -> string,
        --- Checks if the provided path is an absolute path based on OS.
        --- @param path The path to check if it is absolute.
        isAbsolute: (path: string) -> boolean,
        --- Checks if the provided path matches the glob pattern.
        --- @param path The path to check.
        --- @param pattern The glob pattern to match against.
        globMatch: (path: string, pattern: string) -> boolean,
    },
}

return {} :: FileSystemLib;
