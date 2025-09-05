--- @name Regular Expression
--- @global `zune.regex`
--- @summary A library to do regular expressions in Luau.
---
--- Powered by [PCRE2](https://pcre2project.github.io/pcre2/).

type __0__ = typeof(nil);

export type RegexMatch = {
    string: string,
    index: number,
}

--- @class
type Regex = {
    --- @param input The input to match against the regex.
    --- @throws Regex Error
    --- @throws Memory Error
    match: (self: Regex, input: string | buffer) -> {RegexMatch}?,
    --- @throws Regex Error
    --- @throws Memory Error
    search: (self: Regex, input: string | buffer) -> {RegexMatch}?,
    --- @param global If true, the function will return all captures instead of just the first
    --- @default_param global false
    --- @throws Regex Error
    --- @throws Memory Error
    captures: (self: Regex, input: string | buffer, global: boolean?) -> {{RegexMatch}},
    --- @param input The input to split against the regex.
    --- @param global If true, the function will return all splits instead of just the first
    --- @default_param global false
    --- @throws Regex Error
    --- @throws Memory Error
    split: (self: Regex, input: string | buffer, global: boolean?) -> {string},
    --- Returns if a string matches the pattern.
    --- @throws Regex Error
    isMatch: (self: Regex, input: string | buffer) -> boolean,
    --- Format a string.
    --- @param str The string to replace.
    --- @param replacement The replacement string.
    --- @throws Regex Error
    --- @throws Memory Error
    format: (self: Regex, str: string, format: string) -> string,
    --- Replace the first occurrence of a string.
    --- @param str The string to replace.
    --- @param replacement The replacement string.
    --- @throws Regex Error
    --- @throws Memory Error
    replace: (self: Regex, str: string, replacement: string) -> string,
    --- Replace all occurrences of a string.
    --- @param str The string to replace.
    --- @param replacement The replacement string.
    --- @throws Regex Error
    --- @throws Memory Error
    replaceAll: (self: Regex, str: string, replacement: string) -> string,
}

type RegexLib = {
    --- Compiles a regular expression pattern.
    --- @docs
    --- Supported flags:
    --- - `'i'{:luau}`: Case insensitive
    --- - `'m'{:luau}`: Multiline
    --- - `'u'{:luau}`: Unicode
    --- @param pattern The pattern to compile.
    --- @param flags The flags to use.
    --- @throws Regex Error
    --- @throws Memory Error
    create: (pattern: string | buffer, flags: string?) -> Regex,
}

return {} :: RegexLib;
