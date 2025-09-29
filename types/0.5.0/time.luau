--- @name Time
--- @global `zune.time`
--- @summary A library to interact with date and time.

type __0__ = typeof(nil);

export type TimeDictionary = {
    year: number,
    month: number,
    day: number,
    hour: number,
    minute: number,
    second: number,
    millisecond: number,
}

--- @class
type DateTime = {
    timestamp: number,
    timestamp_millis: number,
    --- @throws DateTime Error
    toLocalTime: (self: DateTime) -> TimeDictionary,
    --- @throws DateTime Error
    toUniversalTime: (self: DateTime) -> TimeDictionary,
    --- Return the date in ISO8601 format, `YYYY-MM-DDTHH:MM:SSZ`
    --- @throws DateTime Error
    toIsoDate: (self: DateTime) -> string,
    --- @throws DateTime Error
    --- @throws Memory Error
    formatLocalTime: (self: DateTime, format: string) -> string,
    --- @throws DateTime Error
    --- @throws Memory Error
    formatUniversalTime: (self: DateTime, format: string) -> string,
}

type TimeLib = {
    date: {
        --- @throws DateTime Error
        --- @throws Memory Error
        now: () -> DateTime,
        --- Parse a string in ISO8601 format, `YYYY-MM-DDTHH:MM:SSZ`.
        --- @param date The date string to parse.
        --- @throws DateTime Error
        --- @throws Memory Error
        fromIsoDate: (date: string) -> DateTime,
        --- @param timestamp The unix timestamp in seconds.
        --- @throws DateTime Error
        --- @throws Memory Error
        fromUnixTimestamp: (timestamp: number) -> DateTime,
        --- @param timestamp The unix timestamp in milliseconds.
        --- @throws DateTime Error
        --- @throws Memory Error
        fromUnixTimestampMillis: (timestamp: number) -> DateTime,
        --- @throws DateTime Error
        --- @throws Memory Error
        fromLocalTime: (year: number, month: number, day: number, hour: number, minute: number, second: number, millisecond: number) -> DateTime,
        --- @throws DateTime Error
        --- @throws Memory Error
        fromUniversalTime: (year: number, month: number, day: number, hour: number, minute: number, second: number, millisecond: number) -> DateTime,
        --- Parse a date string.
        --- - Supports ISO8601 format, `YYYY-MM-DDTHH:MM:SSZ`.
        --- - Supports RFC3339 format, `YYYY-MM-DDTHH:MM:SS+00:00`.
        --- - Supports RFC2822 format, `Day, DD Mon YYYY HH:MM:SS GMT`.
        --- @param date The date string to parse.
        --- @throws DateTime Error
        --- @throws Memory Error
        parse: (date: string) -> DateTime,
    },
    instant: {
        --- Returns a timespec in a buffer form, first 8 bytes are seconds,
        --- next 4 bytes are nanoseconds.
        --- buffer should always be 12 bytes long.
        --- @throws Time Error
        --- @throws Memory Error
        now: () -> buffer,
    },
    --- Returns the current unix timestamp in seconds.
    timestamp: () -> number,
    --- Returns the current unix timestamp in milliseconds.
    timestampMillis: () -> number,
}

return {} :: TimeLib;
