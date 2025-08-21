--- @name Serializer/Deserializer
--- @global `zune.serde`
--- @summary A library to serialize and deserialize data in luau.

type __0__ = typeof(nil);

type JsonEncodeConfig = {
    --- The indentation level for pretty printing
    --- @default 0
    pretty_indent: number?,
}

type JsonDecodeConfig = {
    --- Whether to preserve null values
    --- @default false
    preserve_null: boolean?,
}

type JsonEncoder = {
    --- Encodes a value to JSON.
    --- @param value The value to encode.
    --- @param config The configuration for the encoding.
    --- @throws Memory Error
    encode: (value: any, config: JsonEncodeConfig?) -> string,
    --- Decodes JSON.
    --- @param json The JSON string to decode.
    --- @param config The configuration for the decoding.
    --- @throws Memory Error
    decode: (json: string, config: JsonDecodeConfig?) -> any,
    --- Indentation levels for JSON.
    indents: {
        none: number,
        two_spaces: number,
        four_spaces: number,
        tabs: number,
    },
    --- Special values for JSON.
    values: {
        null: any,
    }
}

type TomlEncoder = {
    --- Encodes a table to TOML.
    --- @param object The table to encode.
    --- @throws Memory Error
    encode: (object: {[string]: any}) -> string,
    --- Decodes TOML.
    --- @param toml The TOML string to decode.
    --- @throws Memory Error
    decode: (toml: string | buffer) -> {[string]: any},
}

type YamlInput = string | number | boolean | {[string]: YamlInput}
type YamlOuput = string | {[string]: YamlOuput}

type YamlEncoder = {
    --- Encodes a value to YAML.
    --- @param object The value to encode.
    --- @throws Memory Error
    encode: (object: YamlInput) -> string,
    --- Decodes YAML.
    --- @param yaml The YAML string to decode.
    --- @throws Memory Error
    decode: (yaml: string | buffer) -> YamlOuput,
}

type Base64Encoder = {
    --- Encodes a string to Base64.
    --- @param value The data to encode.
    --- @throws Memory Error
    encode:
        & ((value: string) -> string)
        & ((value: buffer) -> buffer),
    --- Decodes a Base64 string.
    --- @param base64 The Base64 value to decode.
    --- @throws Memory Error
    decode:
        & ((base64: string) -> string)
        & ((base64: buffer) -> buffer),
}

type GenericCompressionOptions = {
    --- The compression level
    level: number?,
}

type CompressionFn =
    & ((raw: string) -> string)
    & ((raw: buffer) -> buffer)


type AdvancedCompressionFn =
    & ((raw: string, opts: GenericCompressionOptions?) -> string)
    & ((raw: buffer, opts: GenericCompressionOptions?) -> buffer)

type DecompressionFn =
    & ((compressed: string) -> string)
    & ((compressed: buffer) -> buffer)

type GenericCompressor = {
    --- @param raw The data to compress. If `raw` is a `buffer`, the function will return a `buffer` instead of a `string`.
    --- @param opts The options for the compression.
    --- @throws Memory Error
    compress: AdvancedCompressionFn,
    --- @param compressed The compressed data to decompress.
    --- @throws Memory Error
    decompress: DecompressionFn,
}

type SerdeLib = {
    json: JsonEncoder,
    json5: JsonEncoder,
    toml: TomlEncoder,
    yaml: YamlEncoder,
    base64: Base64Encoder,
    gzip: GenericCompressor,
    zlib: GenericCompressor,
    lz4: {
        --- @param raw The data to compress. If `raw` is a `buffer`, the function will return a `buffer` instead of a `string`.
        --- @throws Memory Error
        compress: CompressionFn,
        --- @param raw The data to compress. If `raw` is a `buffer`, the function will return a `buffer` instead of a `string`.
        --- @param opts The options for the compression.
        --- @throws Memory Error
        compressFrame: AdvancedCompressionFn,
        --- @param compressed The compressed data to decompress.
        --- @param size The size of the expected data.
        --- @throws Memory Error
        decompress:
            & ((compressed: string, size: number) -> string)
            & ((compressed: buffer, size: number) -> buffer),
        --- @param compressed The compressed data to decompress.
        --- @throws Memory Error
        decompressFrame: DecompressionFn,
    },
    zstd: GenericCompressor,
}

return {} :: SerdeLib;
