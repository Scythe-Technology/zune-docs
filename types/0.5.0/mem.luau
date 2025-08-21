--- @name Byte/Buffer Manipulation
--- @global `zune.mem`
--- @summary A library to manipulate/interact with bytes and buffers.

type __0__ = typeof(nil);
type FFIPointer = typeof(nil :: any);

type WritableSlice = buffer | FFIPointer;
type ReadableSlice = string | buffer | FFIPointer;

type MemLib = {
    --- The maximum amount of bytes luau can hold.
    MAX_SIZE: number,
    --- Gets the length of a slice.
    --- This is similar to `buffer.len` but this supports strings and FFI pointers as well.
    --- @param src The source to get the length of.
    len: (src: ReadableSlice) -> number?,
    --- Copies data from one slice to another.
    --- This is similar to `buffer.copy` but this supports strings and FFI pointers as well.
    --- @param dest The destination to copy to.
    --- @param destOffset The offset to start copying to in the destination.
    --- @param src The source to copy from.
    --- @param srcOffset The offset to start copying from in the source.
    --- @param count The number of bytes to copy. If not provided, will copy until the end of the source.
    --- @throws Memory Error
    copy: (dest: WritableSlice, destOffset: number, src: ReadableSlice, srcOffset: number, count: number?) -> (),
    --- Slices a portion of a source and returns it as a new buffer.
    ---
    --- This does allocate memory for the new buffer.
    --- @param src The source to slice from.
    --- @param offset The offset to start the slice from.
    --- @param count The number of bytes to include in the slice. If not provided,
    --- @throws Memory Error
    slice: (src: ReadableSlice, offset: number, count: number?) -> buffer,
    --- Compares two slices for equality.
    --- @param a The first slice to compare.
    --- @param aOffset The offset to start the comparison from in the first slice.
    --- @param b The second slice to compare.
    --- @param bOffset The offset to start the comparison from in the second slice.
    --- @param count The number of bytes to compare.
    eqlSlice: (a: ReadableSlice, aOffset: number, b: ReadableSlice, bOffset: number, count: number?) -> boolean,
    --- Compares two slices for equality.
    --- A shortcut for `eqlSlice(a, 0, b, 0, nil)`.
    --- @param a The first slice to compare.
    --- @param b The second slice to compare.
    eql: (a: ReadableSlice, b: ReadableSlice) -> boolean,
    --- Checks if a slice starts with a given needle.
    --- @param slice The slice to check.
    --- @param needle The needle to check for.
    startsWith: (slice: ReadableSlice, needle: ReadableSlice) -> boolean,
    --- Checks if a slice ends with a given needle.
    --- @param slice The slice to check.
    --- @param needle The needle to check for.
    endsWith: (slice: ReadableSlice, needle: ReadableSlice) -> boolean,
    --- Trims the given values from both ends of the buffer.
    --- @param src The source to trim.
    --- @param values_to_strip The values to trim from the source.
    --- @throws Memory Error
    trim: (src: ReadableSlice, values_to_strip: ReadableSlice) -> buffer,
    --- Trims the given values from the left end of the buffer.
    --- @param src The source to trim.
    --- @param values_to_strip The values to trim from the source.
    --- @throws Memory Error
    trimLeft: (src: ReadableSlice, values_to_strip: ReadableSlice) -> buffer,
    --- Trims the given values from the right end of the buffer.
    --- @param src The source to trim.
    --- @param values_to_strip The values to trim from the source.
    --- @throws Memory Error
    trimRight: (src: ReadableSlice, values_to_strip: ReadableSlice) -> buffer,
    --- Find the index of a needle in the buffer.
    --- @param src The source to search in.
    --- @param needle The needle to search for.
    indexOf: (src: ReadableSlice, needle: ReadableSlice) -> number?,
    --- Find the index of a needle in the buffer, starting from the given offset.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param needle The needle to search for.
    indexOfPos: (src: ReadableSlice, offset: number, needle: ReadableSlice) -> number?,
    --- Find the last index of a needle in the buffer.
    --- @param src The source to search in.
    --- @param needle The needle to search for.
    lastIndexOf: (src: ReadableSlice, needle: ReadableSlice) -> number?,
    --- Find the index of a scalar/char in the buffer.
    --- @param src The source to search in.
    --- @param char The byte to search for.
    indexOfScalar: (src: ReadableSlice, char: number) -> number?,
    --- Find the index of a scalar/char in the buffer, starting from the given offset.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param char The byte to search for.
    indexOfScalarPos: (src: ReadableSlice, offset: number, char: number) -> number?,
    --- Find the last index of a scalar/char in the buffer.
    --- @param src The source to search in.
    --- @param char The byte to search for.
    lastIndexOfScalar: (src: ReadableSlice, char: number) -> number?,
    --- Find the index of the first byte that is in the given `needle`.
    --- @param src The source to search in.
    --- @param needle The bytes to search for.
    indexOfAny: (src: ReadableSlice, needle: ReadableSlice) -> number?,
    --- Find the index of the first byte that is in the given `needle`, starting from the given `offset`.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param needle The bytes to search for.
    indexOfAnyPos: (src: ReadableSlice, offset: number, needle: ReadableSlice) -> number?,
    --- Find the last index of a byte that is in the given `needle`.
    --- @param src The source to search in.
    --- @param needle The bytes to search for.
    lastIndexOfAny: (src: ReadableSlice, needle: ReadableSlice) -> number?,
    --- Find the index of the first byte that is not in the given `needle`.
    --- @param src The source to search in.
    --- @param needle The bytes to not search for.
    indexOfNone: (src: ReadableSlice, needle: ReadableSlice) -> number?,
    --- Find the index of the first byte that is not in the given `needle`, starting from the given `offset`.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param needle The bytes to not search for.
    indexOfNonePos: (src: ReadableSlice, offset: number, needle: ReadableSlice) -> number?,
    --- Find the last index of a byte that is not in the given `needle`.
    --- @param src The source to search in.
    --- @param needle The bytes to not search for.
    lastIndexOfNone: (src: ReadableSlice, needle: ReadableSlice) -> number?,
    --- Find the index of the first difference between two buffers.
    --- @param src The source to search in.
    indexOfDiff: (src: ReadableSlice, needle: ReadableSlice) -> number?,
    --- Find the index of the maximum value in the buffer.
    ---
    --- Expects the buffer to be non-empty.
    --- @param src The source to search in.
    indexOfMax: (src: ReadableSlice) -> number,
    --- Find the index of the minimum value in the buffer.
    ---
    --- Expects the buffer to be non-empty.
    --- @param src The source to search in.
    indexOfMin: (src: ReadableSlice) -> number,
    --- Find both the index of the minimum and maximum values in the buffer.
    ---
    --- Expects the buffer to be non-empty.
    --- @param src The source to search in.
    indexOfMinMax: (src: ReadableSlice) -> (number, number),
    --- Replaces all occurrences of a scalar in the buffer with another scalar.
    --- - `[1, 2, 3, 2]` with (`2`, `4`) -> `[1, 4, 3, 4]`
    --- @param src The source to replace in.
    --- @param char The byte to replace.
    --- @param replacement The byte to replace with.
    replaceScalar: (src: WritableSlice, char: number, replacement: number) -> (),
    --- Finds the maximum value in the buffer.
    ---
    --- Expects the buffer to be non-empty.
    --- @param src The source to search in.
    max: (src: ReadableSlice) -> number,
    --- Finds the minimum value in the buffer.
    ---
    --- Expects the buffer to be non-empty.
    --- @param src The source to search in.
    min: (src: ReadableSlice) -> number,
    --- Reverses the buffer in place.
    --- - `[1, 2, 3]` -> `[3, 2, 1]`
    --- @param src The source to reverse in.
    reverse: (src: WritableSlice) -> (),
    --- Rotates the buffer to the left by the given amount.
    ---
    --- For example, rotating `[1, 2, 3, 4, 5]` by `2` would result in `[3, 4, 5, 1, 2]`.
    --- @param src The source to rotate in.
    --- @param amount The amount to rotate by.
    rotate: (src: WritableSlice, amount: number) -> (),
    --- Sets the value of the buffer at the given offset to the given value, for the given count of bytes.
    --- @param dest The source to write in.
    --- @param value The value to set.
    --- @param offset The offset to start writing at.
    --- @default_param offset 0
    --- @param count The number of bytes to write. If not provided, will write until the end of the buffer.
    set: (dest: WritableSlice, value: number, offset: number?, count: number?) -> (),
}

return {} :: MemLib;
