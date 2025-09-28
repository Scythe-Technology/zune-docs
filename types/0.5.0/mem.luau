--- @name Byte/Buffer Manipulation
--- @global `zune.mem`
--- @summary A library to manipulate/interact with bytes and buffers.

type __0__ = typeof(nil);
type FFIPointer = typeof(nil :: any);

export type MemWritableSlice = buffer | FFIPointer;
export type MemReadableSlice = string | buffer | FFIPointer;

type MemLib = {
    --- The maximum amount of bytes luau can hold.
    MAX_SIZE: number,
    --- Gets the length of a slice.
    --- This is similar to `buffer.len` but this supports strings and FFI pointers as well.
    --- @param src The source to get the length of.
    len: (src: MemReadableSlice) -> number?,
    --- Copies data from one slice to another.
    --- This is similar to `buffer.copy` but this supports strings and FFI pointers as well.
    --- @param dest The destination to copy to.
    --- @param destOffset The offset to start copying to in the destination.
    --- @param src The source to copy from.
    --- @param srcOffset The offset to start copying from in the source.
    --- @param count The number of bytes to copy. If not provided, will copy until the end of the source.
    --- @throws Memory Error
    copy: (dest: MemWritableSlice, destOffset: number, src: MemReadableSlice, srcOffset: number, count: number?) -> (),
    --- Slices a portion of a source and returns it as a new buffer.
    ---
    --- This does allocate memory for the new buffer.
    --- @param src The source to slice from.
    --- @param offset The offset to start the slice from.
    --- @param count The number of bytes to include in the slice. If not provided,
    --- @throws Memory Error
    slice: (src: MemReadableSlice, offset: number, count: number?) -> buffer,
    --- Compares two slices for equality.
    --- @param a The first slice to compare.
    --- @param aOffset The offset to start the comparison from in the first slice.
    --- @param b The second slice to compare.
    --- @param bOffset The offset to start the comparison from in the second slice.
    --- @param count The number of bytes to compare.
    eqlSlice: (a: MemReadableSlice, aOffset: number, b: MemReadableSlice, bOffset: number, count: number?) -> boolean,
    --- Compares two slices for equality.
    --- A shortcut for `eqlSlice(a, 0, b, 0, nil)`.
    --- @param a The first slice to compare.
    --- @param b The second slice to compare.
    eql: (a: MemReadableSlice, b: MemReadableSlice) -> boolean,
    --- Checks if a slice starts with a given needle.
    --- @param slice The slice to check.
    --- @param needle The needle to check for.
    startsWith: (slice: MemReadableSlice, needle: MemReadableSlice) -> boolean,
    --- Checks if a slice ends with a given needle.
    --- @param slice The slice to check.
    --- @param needle The needle to check for.
    endsWith: (slice: MemReadableSlice, needle: MemReadableSlice) -> boolean,
    --- Trims the given values from both ends of the buffer.
    --- @param src The source to trim.
    --- @param values_to_strip The values to trim from the source.
    --- @throws Memory Error
    trim: (src: MemReadableSlice, values_to_strip: MemReadableSlice) -> buffer,
    --- Trims the given values from the left end of the buffer.
    --- @param src The source to trim.
    --- @param values_to_strip The values to trim from the source.
    --- @throws Memory Error
    trimLeft: (src: MemReadableSlice, values_to_strip: MemReadableSlice) -> buffer,
    --- Trims the given values from the right end of the buffer.
    --- @param src The source to trim.
    --- @param values_to_strip The values to trim from the source.
    --- @throws Memory Error
    trimRight: (src: MemReadableSlice, values_to_strip: MemReadableSlice) -> buffer,
    --- Find the index of a needle in the buffer.
    --- @param src The source to search in.
    --- @param needle The needle to search for.
    find: (src: MemReadableSlice, needle: MemReadableSlice) -> number?,
    --- Find the index of a needle in the buffer, starting from the given offset.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param needle The needle to search for.
    findPos: (src: MemReadableSlice, offset: number, needle: MemReadableSlice) -> number?,
    --- Find the last index of a needle in the buffer.
    --- @param src The source to search in.
    --- @param needle The needle to search for.
    findLast: (src: MemReadableSlice, needle: MemReadableSlice) -> number?,
    --- Find the index of a scalar/char in the buffer.
    --- @param src The source to search in.
    --- @param char The byte to search for.
    findScalar: (src: MemReadableSlice, char: number) -> number?,
    --- Find the index of a scalar/char in the buffer, starting from the given offset.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param char The byte to search for.
    findScalarPos: (src: MemReadableSlice, offset: number, char: number) -> number?,
    --- Find the last index of a scalar/char in the buffer.
    --- @param src The source to search in.
    --- @param char The byte to search for.
    findScalarLast: (src: MemReadableSlice, char: number) -> number?,
    --- Find the index of the first byte that is in the given `needle`.
    --- @param src The source to search in.
    --- @param needle The bytes to search for.
    findAny: (src: MemReadableSlice, needle: MemReadableSlice) -> number?,
    --- Find the index of the first byte that is in the given `needle`, starting from the given `offset`.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param needle The bytes to search for.
    findAnyPos: (src: MemReadableSlice, offset: number, needle: MemReadableSlice) -> number?,
    --- Find the last index of a byte that is in the given `needle`.
    --- @param src The source to search in.
    --- @param needle The bytes to search for.
    findAnyLast: (src: MemReadableSlice, needle: MemReadableSlice) -> number?,
    --- Find the index of the first byte that is not in the given `needle`.
    --- @param src The source to search in.
    --- @param needle The bytes to not search for.
    findNone: (src: MemReadableSlice, needle: MemReadableSlice) -> number?,
    --- Find the index of the first byte that is not in the given `needle`, starting from the given `offset`.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param needle The bytes to not search for.
    findNonePos: (src: MemReadableSlice, offset: number, needle: MemReadableSlice) -> number?,
    --- Find the last index of a byte that is not in the given `needle`.
    --- @param src The source to search in.
    --- @param needle The bytes to not search for.
    findNoneLast: (src: MemReadableSlice, needle: MemReadableSlice) -> number?,
    --- Find the index of the first difference between two buffers.
    --- @param src The source to search in.
    findDiff: (src: MemReadableSlice, needle: MemReadableSlice) -> number?,
    --- Find the index of the first difference between two buffers, starting from the given offset.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    findDiffPos: (src: MemReadableSlice, offset: number, needle: MemReadableSlice) -> number?,
    --- Find the index of the maximum value in the buffer.
    ---
    --- Expects the buffer to be non-empty.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param count The number of bytes to search. If not provided, will search until the end of the buffer.
    findMax: (src: MemReadableSlice, offset: number?, count: number?) -> number,
    --- Find the index of the minimum value in the buffer.
    ---
    --- Expects the buffer to be non-empty.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param count The number of bytes to search. If not provided, will search until the end of the buffer.
    findMin: (src: MemReadableSlice, offset: number?, count: number?) -> number,
    --- Find both the index of the minimum and maximum values in the buffer.
    ---
    --- Expects the buffer to be non-empty.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param count The number of bytes to search. If not provided, will search until the end of the buffer.
    findMinMax: (src: MemReadableSlice, offset: number?, count: number?) -> (number, number),
    --- Cuts the buffer only if it starts with the given prefix. Returning the rest of the buffer.
    --- @param src The source to cut from.
    --- @param prefix The prefix to check for.
    --- @throws Memory Error
    cutPrefix: (src: MemReadableSlice, prefix: MemReadableSlice) -> buffer?,
    --- Cuts the buffer only if it ends with the given suffix. Returning the rest of the buffer.
    --- @param src The source to cut from.
    --- @param suffix The suffix to check for.
    --- @throws Memory Error
    cutSuffix: (src: MemReadableSlice, suffix: MemReadableSlice) -> buffer?,
    --- Cuts the buffer at the first occurrence of the needle, returning the part before and after the needle.
    --- If the needle is not found, returns nil.
    --- @param src The source to cut from.
    --- @param needle The needle to cut at.
    --- @throws Memory Error
    cut: (src: MemReadableSlice, needle: MemReadableSlice) -> (buffer?, buffer?),
    --- Cuts the buffer at the last occurrence of the needle, returning the part before and after the needle.
    --- If the needle is not found, returns nil.
    --- @param src The source to cut from.
    --- @param needle The needle to cut at.
    --- @throws Memory Error
    cutLast: (src: MemReadableSlice, needle: MemReadableSlice) -> (buffer?, buffer?),
    --- Cuts the buffer at the first occurrence of the scalar/char, returning the part before and after the char.
    --- If the char is not found, returns nil.
    --- @param src The source to cut from.
    --- @param char The byte to cut at.
    --- @throws Memory Error
    cutScalar: (src: MemReadableSlice, char: number) -> (buffer?, buffer?),
    --- Cuts the buffer at the last occurrence of the scalar/char, returning the part before and after the char.
    --- If the char is not found, returns nil.
    --- @param src The source to cut from.
    --- @param char The byte to cut at.
    --- @throws Memory Error
    cutScalarLast: (src: MemReadableSlice, char: number) -> (buffer?, buffer?),
    --- Replaces all occurrences of a scalar in the buffer with another scalar.
    --- - `[1, 2, 3, 2]` with (`2`, `4`) -> `[1, 4, 3, 4]`
    --- @param src The source to replace in.
    --- @param char The byte to replace.
    --- @param replacement The byte to replace with.
    --- @param offset The offset to start replacing from.
    --- @param count The number of bytes to replace. If not provided, will replace until the end of the buffer.
    replaceScalar: (src: MemWritableSlice, char: number, replacement: number, offset: number?, count: number?) -> (),
    --- Finds the maximum value in the buffer.
    ---
    --- Expects the buffer to be non-empty.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param count The number of bytes to search. If not provided, will search until the end of the buffer.
    max: (src: MemReadableSlice, offset: number?, count: number?) -> number,
    --- Finds the minimum value in the buffer.
    ---
    --- Expects the buffer to be non-empty.
    --- @param src The source to search in.
    --- @param offset The offset to start searching from.
    --- @param count The number of bytes to search. If not provided, will search until
    min: (src: MemReadableSlice, offset: number?, count: number?) -> number,
    --- Reverses the buffer in place.
    --- - `[1, 2, 3]` -> `[3, 2, 1]`
    --- @param src The source to reverse in.
    --- @param offset The offset to start reversing from.
    --- @param count The number of bytes to reverse. If not provided, will reverse until
    reverse: (src: MemWritableSlice, offset: number?, count: number?) -> (),
    --- Rotates the buffer to the left by the given amount.
    ---
    --- For example, rotating `[1, 2, 3, 4, 5]` by `2` would result in `[3, 4, 5, 1, 2]`.
    --- @param src The source to rotate in.
    --- @param amount The amount to rotate by.
    --- @param offset The offset to start rotating from.
    --- @param count The number of bytes to rotate. If not provided, will rotate up to the end of the buffer.
    rotate: (src: MemWritableSlice, amount: number, offset: number?, count: number?) -> (),
    --- Sets the value of the buffer at the given offset to the given value, for the given count of bytes.
    --- @param dest The source to write in.
    --- @param value The value to set.
    --- @param offset The offset to start writing at.
    --- @default_param offset 0
    --- @param count The number of bytes to write. If not provided, will write until the end of the buffer.
    set: (dest: MemWritableSlice, value: number, offset: number?, count: number?) -> (),
    --- Reads a vector with only 2 elements from a buffer.
    --- @param src The source to read from.
    --- @param offset The offset to start reading from.
    toVector2: (src: MemReadableSlice, offset: number?) -> vector,
    --- Reads a vector with only 3 elements from a buffer.
    --- @param src The source to read from.
    --- @param offset The offset to start reading from.
    toVector3: (src: MemReadableSlice, offset: number?) -> vector,
    --- Writes a vector with only 2 elements to a buffer.
    --- @param dest The destination to write to.
    --- @param offset The offset to start writing to.
    --- @param vec The vector to write.
    writeVector2: (dest: MemWritableSlice, offset: number?, vec: vector) -> (),
    --- Writes a vector with only 3 elements to a buffer.
    --- @param dest The destination to write to.
    --- @param offset The offset to start writing to.
    --- @param vec The vector to write.
    writeVector3: (dest: MemWritableSlice, offset: number?, vec: vector) -> (),
}

return {} :: MemLib;
