--- @name Require
--- @global `zune.require`
--- @summary A library to use zune's require resolver in luau.

type __0__ = typeof(nil);

export type RequireLib = {
    --- @param path The path to navigate to.
    --- @param from The path to navigate from. Defaults to the current file.
    --- @param config The configuration to use.
    --- @throws Require Error
    --- @throws Memory Error
    navigate: (path: string, from: string?, config: string?) -> string,
    --- @param path The resolved path to fetch cached require.
    --- @throws Require Error
    --- @throws Memory Error
    getCached: (resolvedPath: string) -> any?,
}

return {} :: RequireLib;
