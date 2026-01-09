--- @name Standard I/O
--- @global `zune.io`
--- @summary A library to use standard input/output in luau.

type __0__ = typeof(nil);
type FileHandle = typeof(nil :: any);

--- @class
type IoReadable = {
    --- @param amount The amount of bytes to read. If nil, reads until EOF or luau limit.
    --- @param bytes If false, the function will return a `string` instead of a `buffer`.
    --- @default_param bytes true
    --- @throws Reader Error
    read:
        & ((self: IoReadable, amount: number?, bytes: nil) -> buffer)
        & ((self: IoReadable, amount: number?, bytes: true) -> buffer)
        & ((self: IoReadable, amount: number?, bytes: false) -> string)
        & ((self: IoReadable, amount: number?, bytes: boolean) -> string | buffer),
    readu8: (self: IoReadable) -> number,
    readu16: (self: IoReadable) -> number,
    readu32: (self: IoReadable) -> number,
    readi8: (self: IoReadable) -> number,
    readi16: (self: IoReadable) -> number,
    readi32: (self: IoReadable) -> number,
    readf32: (self: IoReadable) -> number,
    readf64: (self: IoReadable) -> number,
}

--- @class
type IoWritable = {
    --- @param data The data to write to the stream.
    --- @throws Writer Error
    write: (self: IoWritable, data: string | buffer) -> (),
    --- @throws Writer Error
    writeu8: (self: IoWritable, value: number) -> (),
    --- @throws Writer Error
    writeu16: (self: IoWritable, value: number) -> (),
    --- @throws Writer Error
    writeu32: (self: IoWritable, value: number) -> (),
    --- @throws Writer Error
    writei8: (self: IoWritable, value: number) -> (),
    --- @throws Writer Error
    writei16: (self: IoWritable, value: number) -> (),
    --- @throws Writer Error
    writei32: (self: IoWritable, value: number) -> (),
    --- @throws Writer Error
    writef32: (self: IoWritable, value: number) -> (),
    --- @throws Writer Error
    writef64: (self: IoWritable, value: number) -> (),
}

--- @class
type BufferStream = {
    --- @param amount The amount of bytes to read, if not provided, it will read until EOF or luau limit.
    --- @param bytes If false, the function will return a `string` instead of a `buffer`.
    --- @default_param bytes true
    --- @throws Reader Error
    read:
        & ((self: BufferStream, amount: number?, bytes: nil) -> buffer)
        & ((self: BufferStream, amount: number?, bytes: true) -> buffer)
        & ((self: BufferStream, amount: number?, bytes: false) -> string)
        & ((self: BufferStream, amount: number?, bytes: boolean) -> string | buffer),
    --- @param data The data to write to the stream.
    --- @throws Writer Error
    write: (self: BufferStream, data: string | buffer) -> (),
    pos: (self: BufferStream) -> number,
    size: (self: BufferStream) -> number,
    --- @param pos The position to seek to.
    seekTo: (self: BufferStream, pos: number) -> (),
    --- @param offset The offset to seek by.
    seekBy: (self: BufferStream, offset: number) -> (),
    --- @param amount The amount of bytes to check for reading availability.
    --- @default_param amount 0
    canRead: (self: BufferStream, amount: number?) -> boolean,
    --- @throws Memory Error
    writer: (self: BufferStream) -> IoWritable,
    --- @throws Memory Error
    reader: (self: BufferStream) -> IoReadable,
}

--- @class
type BufferSink = {
    len: number,
    closed: boolean,

    --- @params bytes If true, the function will return a `buffer` instead of a `string`.
    --- @default_param bytes true
    --- @throws Memory Error
    flush:
        & ((self: BufferSink, bytes: nil) -> buffer)
        & ((self: BufferSink, bytes: true) -> buffer)
        & ((self: BufferSink, bytes: false) -> string)
        & ((self: BufferSink, bytes: boolean) -> string | buffer),
    --- @param data The data to write to write.
    --- @throws Memory Error
    write: (self: BufferSink, data: string | buffer) -> (),
    --- @throws Memory Error
    writer: (self: BufferSink) -> IoWritable,
    close: (self: BufferSink) -> (),
}

type Terminal = {
    --- Whether the terminal is a TTY.
    isTTY: boolean,
    --- Get current saved mode.
    getCurrentMode: () -> "normal" | "raw",
    --- Enable raw mode.
    ---
    --- On unix: Will attempt to change terminal mode.
    --- On windows: Will attempt to change console mode.
    ---
    --- returns `true` if the operation was successful.
    enableRawMode: () -> boolean,
    --- Restores the terminal to the original mode.
    ---
    --- On unix: Will attempt to restore the original terminal mode.
    --- On windows: Will attempt to restore the original console mode.
    ---
    --- returns `true` if the operation was successful.
    restoreMode: () -> boolean,
    --- Gets the terminal size.
    ---
    --- Returns a tuple of `(width, height)`. Otherwise returns `(nil, nil)` if current terminal is not a TTY.
    --- @throws Terminal Error
    getSize: () -> (number?, number?),
}

export type BufferSinkOptions = {
    --- The maximum amount of bytes allowed to be written to the buffer.
    --- @default 1073741824
    limit: number?,
    --- The initial size of the buffer.
    --- @default 0
    size: number?,
}

type IoLib = {
    --- Formats input to a readable string.
    --- @param ...any The values to format.
    --- @throws Memory Error
    format: (...any) -> string,
    --- Creates a buffer sink.
    --- @param opts The options for the buffer sink.
    --- @throws Memory Error
    createBufferSink: (opts: BufferSinkOptions?) -> BufferSink,
    --- Creates a buffer stream.
    --- @param buffer The buffer to create the stream with.
    --- @throws Memory Error
    createFixedBufferStream: (buffer: buffer) -> BufferStream,
    terminal: Terminal,
    stdout: FileHandle,
    stderr: FileHandle,
    stdin: FileHandle,
}

return {} :: IoLib;
