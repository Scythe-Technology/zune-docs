--- @name SQLite3
--- @global `zune.sqlite`
--- @summary A library to interact with SQLite3 databases.

type __0__ = typeof(nil);

export type SQLite3Values = {[string]: number | string | buffer};
export type SQLite3Result = {
    last_insert_row_id: number,
    changes: number,
}

--- @class
type SQLite3Statement = {
    --- @param args The arguments to bind to the statement.
    --- @throws SQLite3 Error
    --- @throws Memory Error
    run: (self: SQLite3Statement, args: SQLite3Values?) -> SQLite3Result,
    --- @param args The arguments to bind to the statement.
    --- @throws SQLite3 Error
    --- @throws Memory Error
    get: (self: SQLite3Statement, args: SQLite3Values?) -> SQLite3Values?,
    --- @param args The arguments to bind to the statement.
    --- @throws SQLite3 Error
    --- @throws Memory Error
    all: (self: SQLite3Statement, args: SQLite3Values?) -> {SQLite3Values},
    --- Closes the statement and frees resources.
    finalize: (self: SQLite3Statement) -> (),
}

type TransactionKind = "deferred" | "immediate" | "exclusive";
type TransactionFn = <A..., R...>(self: SQLite3Database, callback: ((A...) -> R...), kind: TransactionKind?) -> ((A...) -> R...)

--- @class
type SQLite3Database = {
    --- Creates a transaction function.
    --- @param callback The callback to run inside the transaction.
    --- @param kind The transaction mode to use.
    --- @throws Luau Error
    transaction: TransactionFn,
    --- @param query The query to prepare.
    --- @throws SQLite3 Error
    --- @throws Memory Error
    query: (self: SQLite3Database, query: string | buffer) -> SQLite3Statement,
    --- @param query The query to execute.
    --- @param args The arguments to bind to the query.
    --- @throws SQLite3 Error
    --- @throws Memory Error
    exec: (self: SQLite3Database, query: string | buffer, args: SQLite3Values?) -> SQLite3Result,
    close: (self: SQLite3Database) -> (),
}

type SQLiteLib = {
    --- Opens a SQLite3 database.
    --- @param path The path to the database file.
    --- @default_param path ":memory:"
    --- @throws SQLite3 Error
    --- @throws Memory Error
    open: (path: string?) -> SQLite3Database,
}

return {} :: SQLiteLib;
