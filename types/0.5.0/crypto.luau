--- @name Cryptography
--- @global `zune.crypto`
--- @summary A library to do cryptographic operations in luau. Provides functions for hashing, aead, tls, and secure random number generation.

type __0__ = typeof(nil);
type NetworkSocket = typeof(nil :: any);

type Input = string | buffer;

--- @class
type CryptoHash = {
    --- Returns the finalized hash value.
    ---
    --- If the hash object was created with a key, this would close the object.
    --- @param encoding The encoding of the output.
    --- @default_param encoding "binary"
    --- @throws Memory Error
    digest:
        & ((self: CryptoHash) -> buffer)
        & ((self: CryptoHash, encoding: "binary") -> buffer)
        & ((self: CryptoHash, encoding: "hex" | "base64") -> string)
        & ((self: CryptoHash, encoding: string) -> string | buffer),
    --- @param value The value to update the hash with.
    --- @throws Crypto Error
    update: (self: CryptoHash, value: string | buffer) -> (),
    --- Copies the current hash state.
    ---
    --- If the hash object was created with a key, the object must still be opened.
    --- @throws Crypto Error
    --- @throws Memory Error
    copy: (self: CryptoHash) -> CryptoHash,
}

--- @class
type TlsCertBundle = {}

--- @class
type TlsCertKeyPair = {}

export type CryptoHashAlgorithms =
    | "sha1"
    | "md5"
    | "blake3"
    | "sha224"
    | "sha256"
    | "sha384"
    | "sha512"
    | "sha3_224"
    | "sha3_256"
    | "sha3_384"
    | "sha3_512"
    | "blake2b128"
    | "blake2b160"
    | "blake2b256"
    | "blake2b384"
    | "blake2b512"
    | "blake2s128"
    | "blake2s160"
    | "blake2s224"
    | "blake2s256"

type BcryptPasswordOptions = {
    --- The algorithm to use.
    algorithm: "bcrypt"?,
    --- The cost to use.
    --- @default 4
    cost: number?,
}

type Argon2PasswordOptions = {
    --- The algorithm to use.
    --- @default "argon2id"
    algorithm: ("argon2d" | "argon2i" | "argon2id")?,
    --- The time cost to use.
    --- @default 2
    time_cost: number?,
    --- The memory cost to use.
    --- @default 65536
    memory_cost: number?,
    --- The number of threads to use.
    --- @default 1
    threads: number?,
}

export type CryptoPasswordOptions = BcryptPasswordOptions | Argon2PasswordOptions

type EncryptedData = {
    cipher: buffer,
    tag: buffer,
}

type Aead = {
    encrypt: (data: Input, key: Input, nonce: Input, ad: Input?) -> EncryptedData,
    decrypt: (cipher: Input, tag: Input, key: Input, nonce: Input, ad: Input?) -> string,
}

export type CryptoTlsClientConfig = {
    --- The host.
    host: string,
    --- The CA bundle to use for verification.
    ca: TlsCertBundle,
}

export type CryptoTlsServerConfig = {
    --- The certificate and key pair to use for the server.
    auth: TlsCertKeyPair,
}

type CryptoLib = {
    createHash: (algorithm: CryptoHashAlgorithms, secret: string?) -> CryptoHash,
    password: {
        --- @param password The password to hash.
        --- @param opts The options for the password hashing.
        --- @throws Crypto Error
        --- @throws Memory Error
        hash: (password: string | buffer, opts: CryptoPasswordOptions?) -> string,
        --- @param password The password to verify.
        --- @param hash The hash to verify against.
        --- @throws Crypto Error
        verify: (password: string | buffer, hash: string | buffer) -> boolean,
    },
    uuid: {
        v4: () -> string,
        v7: () -> string,
    },
    --- Cryptographically secure random number generator.
    random: {
        --- Generates a random number (f64).
        ---
        --- If no arguments are provided, the function will generate a number between 0 and 1.
        --- @param min The minimum value (inclusive).
        --- @param max The maximum value (inclusive).
        --- @throws Range Error
        nextNumber:
            & (() -> number)
            & ((min: number, max: number) -> number),
        --- Generates a random integer.
        ---
        --- If no arguments are provided, the function will generate a number between the limits of a signed 32-bit integer.
        --- @param min The minimum value (inclusive).
        --- @param max The maximum value (inclusive).
        --- @throws Range Error
        nextInteger:
            & (() -> number)
            & ((min: number, max: number) -> number),
        --- Generates a random boolean.
        nextBoolean: () -> boolean,
        --- Write random bytes to the buffer.
        --- @param buffer The buffer to write to.
        --- @param offset The offset to start writing at.
        --- @param length The number of bytes to write.
        --- @throws Range Error
        --- @throws Crypto Error
        --- @throws Buffer Error
        fill: (buffer: buffer, offset: number, length: number) -> (),
    },
    aead: {
        aes_gcm: {
            Aes128Gcm: Aead,
            Aes256Gcm: Aead,
        },
        aes_ocb: {
            Aes128Ocb: Aead,
            Aes256Ocb: Aead,
        },
        aegis: {
            Aegis128X4: Aead,
            Aegis128X2: Aead,
            Aegis128L: Aead,
            Aegis256X4: Aead,
            Aegis256X2: Aead,
            Aegis256: Aead,
            Aegis128X4_256: Aead,
            Aegis128X2_256: Aead,
            Aegis128L_256: Aead,
            Aegis256X4_256: Aead,
            Aegis256X2_256: Aead,
            Aegis256_256: Aead,
        },
        chacha_poly: {
            ChaCha8Poly1305: Aead,
            ChaCha12Poly1305: Aead,
            ChaCha20Poly1305: Aead,
            XChaCha8Poly1305: Aead,
            XChaCha12Poly1305: Aead,
            XChaCha20Poly1305: Aead,
        },
        salsa_poly: {
            XSalsa20Poly1305: Aead,
        },
        isap: {
            IsapA128A: Aead,
        },
    },

    tls: {
        --- @throws IO Error
        --- @throws Tls Error
        bundleFromSystem: () -> TlsCertBundle,
        --- @param file The file to load the bundle from.
        --- @throws IO Error
        bundleFromFile: (file: string) -> TlsCertBundle,
        --- @param certFile The certificate file.
        --- @param keyFile The key file.
        --- @throws IO Error
        --- @throws Tls Error
        keyPairFromFile: (certFile: string, keyFile: string) -> TlsCertKeyPair,
        --- @param socket The socket to setup the client on.
        --- @param config The configuration for the client.
        --- @throws Tls Error
        --- @throws Memory Error
        setupClient: (socket: NetworkSocket, config: CryptoTlsClientConfig) -> (),
        --- @param socket The socket to setup the server on.
        --- @param config The configuration for the server.
        --- @throws Tls Error
        --- @throws Memory Error
        setupServer: (socket: NetworkSocket, config: CryptoTlsServerConfig) -> (),
    },
}

return {} :: CryptoLib;
