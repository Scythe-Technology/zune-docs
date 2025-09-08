--- @name Testing
--- @global `zune.testing`
--- @summary A library to interact with the testing suite.

type __0__ = typeof(nil);

type BasicCases = {
    --- Expects the value to be equal to the expected value.
    --- @param expected The expected value.
    toBe: (expected: any) -> (),
    --- Expects the value to be defined.
    toBeDefined: () -> (),
    --- Expects the value to be close to the expected value.
    ---
    --- Formula: `abs(value - expected) < 10 ^ -precision`
    --- @example
    --- ```luau
    --- expect(1.1).toBeCloseTo(1, -1) -- Within 5
    --- expect(1.1).toBeCloseTo(1, 0) -- Within 0.5
    --- expect(1.1).toBeCloseTo(1, 1) -- Within 0.05
    --- expect(1.1).toBeCloseTo(1, 2) -- Within 0.005
    --- ```
    --- @param expected The expected value.
    --- @param precision The precision of the comparison.
    toBeCloseTo: (expected: number, precision: number) -> (),
    --- Expects the value to be greater than the expected value.
    --- @param expected The expected value.
    toBeGreaterThan: (expected: number) -> (),
    --- Expects the value to be greater than or equal to the expected value.
    --- @param expected The expected value.
    toBeGreaterThanOrEqual: (expected: number) -> (),
    --- Expects the value to be less than the expected value.
    --- @param expected The expected value.
    toBeLessThan: (expected: number) -> (),
    --- Expects the value to be less than or equal to the expected value.
    --- @param expected The expected value.
    toBeLessThanOrEqual: (expected: number) -> (),
    --- Expects the value to be nil.
    toBeNil: () -> (),
    --- Expects the value to be not a number.
    toBeNan: () -> (),
    --- Expect the length of the value to be equal to the expected length.
    --- - Tables
    --- - Strings
    --- @param expected The expected length
    toHaveLength: (expected: number) -> (),
    --- Expects the value to be falsy.
    --- 
    --- False or nil.
    toBeFalsy: () -> (),
    --- Expects the value to be truthy.
    ---
    --- True or non nil.
    toBeTruthy: () -> (),
}

type ExpectCases = BasicCases & {
    --- never
    ---
    --- Flipped expectations.
    never: BasicCases,
}

type FunctionalCases = ExpectCases & {
    --- toThrow
    ---
    --- Expects a function to throw an error.
    ---
    --- Optionally, the error message can be checked.
    ---
    --- @param expected The expected error message.
    toThrow: (expected: string?) -> (),
    --- never
    ---
    --- Flipped expectations.
    never: FunctionalCases,
}

type ExpectHandler = {
    --- [Jest compatibliity]: `expect.any(type)`
    ---
    --- Recommend using `expect.type` instead.
    ---
    --- Expects a value to be a type.
    any: (type: string) -> any,
    --- Expects a value to be a type.
    type: (type: "nil" | "boolean" | "number" | "string" | "function" | "table" | "userdata" | "thread" | "buffer" | "vector") -> any,
    --- Expects a value to be similar to the expected table.
    ---
    --- @param expected The expected table.
    similar: (expected: any) -> any,
}

type TestingLib = {
    --- Whether the testing suite is running.
    running: boolean,
    --- [Internal]
    ---
    --- The number of tests that have failed.
    _failed: number,
    --- [Internal]
    ---
    --- The number of tests conducted.
    _count: number,
    --- [Internal]
    ---
    --- The number of tests that have passed.
    _start: number,
    --- Conducts a test.
    ---
    ---*Will be ignored if the testing suite is not running.*
    ---
    --- @param name The name of the test.
    --- @param callback The callback to run the test.
    --- @param timeout The timeout on how long a test should last.
    test: (name: string, callback: () -> (), timeout: number?) -> (),
    --- Describes a test suite.
    ---
    --- *Will be ignored if the testing suite is not running.*
    ---
    --- @param name The name of the suite.
    --- @param callback The callback to run the suite.
    describe: (name: string, callback: () -> ()) -> (),
    --- Defers a function.
    ---
    --- Deferred function will be executed after a test completes.
    --- Useful for cleaning up resources.
    --- 
    --- @param callback The callback to defer.
    defer: (fn: () -> ()) -> (),
    --- Expects a value.
    ---
    --- @param value The value to expect.
    --- @return Handler for expectations.
    expect: ((value: (...any) -> ...any) -> FunctionalCases) & ((value: any) -> ExpectCases) & ExpectHandler,
    --- Expects a value to be true or non nil.
    ---
    --- Similar to `assert(value)`
    ---
    --- @param value The value to expect.
    expected: (value: any) -> (),
    --- Expects a value to equal another.
    ---
    --- Similar to `assert(value == expected, ...)`
    ---
    --- @param expected The expected value.
    --- @param value The value to test.
    expectEqual: ((expected: any, value: any) -> ()),
}

return {} :: TestingLib;
