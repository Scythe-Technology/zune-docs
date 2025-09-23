--- @name Foreign Function Interface
--- @global `zune.ffi`
--- @summary A library to interact with foreign functions and libraries.

type __0__ = typeof(nil);

export type FFILibrary = {
    getSymbol: (self: FFILibrary, symbol: string) -> FFIPointer?,
    [string]: (...any) -> any,
}

--- @class
type FFICompiled = {
    --- @param symbol The symbol to get.
    --- @throws FFI Error
    --- @throws Memory Error
    getSymbol: (self: FFICompiled, symbol: string) -> FFIPointer?,
    --- Lists all symbols in the compiled object.
    --- @throws FFI Error
    --- @throws Memory Error
    listSymbols: (self: FFICompiled) -> {string},
}

--- @class
type FFIDataType = {
    --- Get the size of the data type.
    size: (self: FFIDataType) -> number,
    --- Get the alignment of the data type.
    alignment: (self: FFIDataType) -> number,
    --- Create an array data type of the given count.
    array: (self: FFIDataType, count: number) -> FFIArrayType,
}

--- @class FFIDataType
type FFIVectorType = {
    --- Get the offset of a index in the type.
    --- @param index The index to get the offset of.
    offset: (self: FFIVectorType, index: number) -> number,
}

--- @class FFIDataType
type FFIStructureType = {
    --- Get the offset of a field in the structure.
    --- @param field The field to get the offset of.
    offset: (self: FFIStructureType, field: string) -> number,
    --- Creates a new instance of the structure.
    --- @param fields The fields to set in the structure.
    --- @throws FFI Error
    --- @throws Memory Error
    new: (self: FFIStructureType, fields: { [string]: buffer | number | FFIPointer | vector }) -> buffer,
}

--- @class FFIVectorType
type FFIArrayType = {
    --- Creates a new instance of the array structure.
    --- @param values The values to set in the array.
    --- @throws FFI Error
    --- @throws Memory Error
    new: (self: FFIArrayType, values: { [number]: buffer | number | FFIPointer | vector }) -> buffer,
}

--- @class FFIDataType
type FFIPointerType = {
    --- Get the tag id of the pointer type.
    tag: (self: FFIPointerType) -> number,
    --- Creates a new pointer type with the given tag.
    --- @param tag The tag to set.
    --- @throws FFI Error
    --- @throws Memory Error
    newTag: (self: FFIPointerType, tag: string | buffer) -> FFIPointerType,
}

export type FFIAnyDataType = FFIDataType | FFIStructureType | FFIArrayType | FFIPointerType

export type FFIFunctionDefintion = {
    --- The return type of the function.
    returns: FFIAnyDataType,
    --- The argument types of the function.
    args: { FFIAnyDataType }
}

--- @class
type FFIPointer = {
    release: (self: FFIPointer) -> FFIPointer,
    retain: (self: FFIPointer) -> FFIPointer,
    tag: 
        & ((self: FFIPointer) -> number)
        & ((self: FFIPointer, tag: number) -> FFIPointer),
    drop: (self: FFIPointer) -> FFIPointer,
    offset: (self: FFIPointer, offset: number) -> FFIPointer,
    read: (self: FFIPointer, srcOffset: number, dest: buffer | FFIPointer, destOffset: number, count: number) -> buffer,
    write: (self: FFIPointer, destOffset: number, src: buffer | FFIPointer, srcOffset: number, count: number) -> (),
    readi8: (self: FFIPointer, offset: number?) -> number,
    readi16: (self: FFIPointer, offset: number?) -> number,
    readi32: (self: FFIPointer, offset: number?) -> number,
    readi64: (self: FFIPointer, offset: number?) -> buffer,
    readu8: (self: FFIPointer, offset: number?) -> number,
    readu16: (self: FFIPointer, offset: number?) -> number,
    readu32: (self: FFIPointer, offset: number?) -> number,
    readu64: (self: FFIPointer, offset: number?) -> buffer,
    readf32: (self: FFIPointer, offset: number?) -> number,
    readf64: (self: FFIPointer, offset: number?) -> number,
    readptr: (self: FFIPointer, offset: number?) -> FFIPointer,
    writei8: (self: FFIPointer, offset: number, value: number | buffer | boolean) -> (),
    writei16: (self: FFIPointer, offset: number, value: number | buffer | boolean) -> (),
    writei32: (self: FFIPointer, offset: number, value: number | buffer | boolean) -> (),
    writei64: (self: FFIPointer, offset: number, value: number | buffer | boolean) -> (),
    writeu8: (self: FFIPointer, offset: number, value: number | buffer | boolean) -> (),
    writeu16: (self: FFIPointer, offset: number, value: number | buffer | boolean) -> (),
    writeu32: (self: FFIPointer, offset: number, value: number | buffer | boolean) -> (),
    writeu64: (self: FFIPointer, offset: number, value: number | buffer | boolean) -> (),
    writef32: (self: FFIPointer, offset: number, value: number | buffer | boolean) -> (),
    writef64: (self: FFIPointer, offset: number, value: number | buffer | boolean) -> (),
    writeptr: (self: FFIPointer, offset: number, value: FFIPointer) -> (),
    size:
        & ((self: FFIPointer) -> number?)
        & ((self: FFIPointer, size: number) -> ()),
    alignment:
        & ((self: FFIPointer) -> number?)
        & ((self: FFIPointer, alignment: number) -> ()),
    span: (self: FFIPointer, offset: number?) -> buffer,
}

export type FFICompileOptions = {
    --- The compiler options to use.
    options: string?,
    --- The files to include in the compilation.
    files: {string}?,
    --- The libraries to link against.
    libraries: {string}?,
    --- The library paths to use.
    library_paths: {string}?,
    --- The include directories to use.
    includes: {string}?,
    --- The system include directories to use.
    sysincludes: {string}?,
    --- The symbols to define.
    symbols: {[string]: FFIPointer}?,
}

type FFILib = {
    --- The recommended prefix for the library file.
    ---
    --- Platforms:
    --- - Windows: none
    --- - Linux: `lib`
    --- - macOS: `lib`
    prefix: string,
    --- The recommended suffix for the library file.
    ---
    --- Platforms:
    --- - Windows: `dll`
    --- - Linux: `so`
    --- - macOS: `dylib`
    suffix: string,
    types: {
        void: FFIDataType,
        i8: FFIDataType,
        u8: FFIDataType,
        i16: FFIDataType,
        u16: FFIDataType,
        i32: FFIDataType,
        u32: FFIDataType,
        i64: FFIDataType,
        u64: FFIDataType,
        float: FFIDataType,
        double: FFIDataType,
        pointer: FFIPointerType,
        vector2_32: FFIVectorType,
        vector3_32: FFIVectorType,
    },
    c: {
        --- @param src The C source code to compile.
        --- @param opts The options for the compilation.
        compile: (src: string, opts: FFICompileOptions?) -> FFICompiled,
    },
    null: FFIPointer,
    --- @param src The pointer to reference.
    --- @throws Memory Error
    ptr: (src: FFIPointer) -> FFIPointer,
    --- @param src The address of the pointer.
    --- @throws Memory Error
    ptrFromAddress: (src: buffer) -> FFIPointer,
    --- Returns the lua state.
    --- @param mainthread Whether to get the main thread or the current thread.
    --- @default_param mainthread false
    --- @throws Memory Error
    getLuaState: (mainthread: boolean?) -> FFIPointer,
    --- @param size The size to allocate.
    --- @param alignment The alignment to allocate.
    --- @default_param alignment 1
    --- @throws FFI Error
    --- @throws Memory Error
    alloc: (size: number, alignment: number?) -> FFIPointer,
    --- @param type The data type to allocate.
    --- @throws FFI Error
    --- @throws Memory Error
    create: (type: FFIAnyDataType) -> FFIPointer,
    --- @param src The pointer to free. If the pointer is static, it must have a known size.
    --- @throws FFI Error
    --- @throws Memory Error
    free: (src: FFIPointer) -> (),
    --- @param src The pointer to duplicate. If the source is a static pointer, it must have a known size.
    --- @throws Memory Error
    dupe: (src: buffer | FFIPointer | vector) -> FFIPointer,
    --- @param tag The tag id to get the name of.
    tagName: (tag: number) -> string?,
    --- Creates a structure data type.
    --- - The order of the fields is the number index of the field table.
    ---   - There cannot be multiple fields in the same field table.
    ---   - Multiple fields with the same field name is not allowed.
    --- @example
    --- ```lua
    --- ffi.struct {
    ---     { age = ffi.types.u8 },
    ---     { height = ffi.types.f32 },
    --- }
    --- ```
    --- @param fields The fields of the structure.
    --- @throws FFI Error
    --- @throws Memory Error
    struct: (fields: {{ [string]: FFIAnyDataType }}) -> FFIStructureType,
    --- @param definition The function definition.
    --- @param srcPtr The pointer to the function.
    --- @throws FFI Error
    --- @throws Memory Error
    fn: (definition: FFIFunctionDefintion, srcPtr: FFIPointer) -> ((...any) -> any),
    --- @param definition The function definition.
    --- @param handler The lua function to call.
    --- @throws FFI Error
    --- @throws Memory Error
    closure: (definition: FFIFunctionDefintion, handler: (...any) -> any) -> FFIPointer,
    --- @param path The path to the library.
    --- @param functions The symbols to load from the library.
    --- @throws FFI Error
    --- @throws Memory Error
    dlopen: (path: string, functions: { [string]: FFIFunctionDefintion }) -> FFILibrary,
}

return {} :: FFILib;
