--- @name Random
--- @global `zune.random`
--- @summary A library to create a pseudo random number generator in luau.

type __0__ = typeof(nil);

--- @class
type Random = {
    --- Generates a random number.
    ---
    --- If no arguments are provided, the function will generate a number between 0 and 1.
    --- @param min The minimum value (inclusive).
    --- @param max The maximum value (inclusive).
    --- @throws Range Error
    nextNumber:
        & ((self: Random) -> number)
        & ((self: Random, min: number, max: number) -> number),
    ---Generates a random integer.
    ---
    --- If no arguments are provided, the function will generate a number between the limits of a signed 32-bit integer.
    --- @param min The minimum value (inclusive).
    --- @param max The maximum value (inclusive).
    --- @throws Range Error
    nextInteger: (self: Random, min: number, max: number) -> number,
    --- Generates a random boolean.
    nextBoolean: (self: Random) -> boolean,
    --- Creates a new random number generator with the same state as the current one.
    clone: (self: Random) -> Random,
}

type RandomNewFn = (seed: number?) -> Random;
type RandomConstructor = {
    --- @throws Memory Error
    new: RandomNewFn,
}

type RandomLib = {
    --- Creates a new default random generator.
    ---
    --- PRNG: `LuauPcg32`
    --- @throws Memory Error
    new: RandomNewFn,
    LuauPcg32: RandomConstructor,
    Isaac64: RandomConstructor,
    Pcg32: RandomConstructor,
    Xoroshiro128: RandomConstructor,
    Xoshiro256: RandomConstructor,
    Sfc64: RandomConstructor,
    RomuTrio: RandomConstructor,
}

return {} :: RandomLib;
