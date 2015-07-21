import Dispatch

/// A connection to SQLite.
public final class Connection {

    /// The location of a SQLite database.
    public enum Location {

        /// An in-memory database (equivalent to `.URI(":memory:")`).
        ///
        /// See: <https://www.sqlite.org/inmemorydb.html#sharedmemdb>
        case InMemory

        /// A temporary, file-backed database (equivalent to `.URI("")`).
        ///
        /// See: <https://www.sqlite.org/inmemorydb.html#temp_db>
        case Temporary

        /// A database located at the given URI filename (or path).
        ///
        /// See: <https://www.sqlite.org/uri.html>
        ///
        /// - Parameter filename: A URI filename
        case URI(String)
    }

    var handle: COpaquePointer = nil

    /// Initializes a new SQLite connection.
    ///
    /// - Parameters:
    ///
    ///   - location: The location of the database. Creates a new database if it
    ///     doesn’t already exist (unless in read-only mode).
    ///
    ///     Default: `.InMemory`.
    ///
    ///   - readonly: Whether or not to open the database in a read-only state.
    ///
    ///     Default: `false`.
    ///
    /// - Returns: A new database connection.
    public init(_ location: Location = .InMemory, readonly: Bool = false) throws {
        let flags = readonly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        try check(sqlite3_open_v2(location.description, &handle, flags | SQLITE_OPEN_FULLMUTEX, nil))
    }

    // TODO: add 'Throws:' documentation here and so on
    /// Initializes a new connection to a database.
    ///
    /// - Parameters:
    ///
    ///   - filename: The location of the database. Creates a new database if
    ///     it doesn’t already exist (unless in read-only mode).
    ///
    ///   - readonly: Whether or not to open the database in a read-only state.
    ///
    ///     Default: `false`.
    ///
    /// - Returns: A new database connection.
    public convenience init(_ filename: String, readonly: Bool = false) throws {
        try self.init(.URI(filename), readonly: readonly)
    }

    deinit {
        sqlite3_close_v2(handle)
    }

    // MARK: -

    /// Whether or not the database was opened in a read-only state.
    public var readonly: Bool { return sqlite3_db_readonly(handle, nil) == 1 }

    /// The last rowid inserted into the database via this connection.
    public var lastInsertRowid: Int64? {
        let rowid = sqlite3_last_insert_rowid(handle)
        return rowid > 0 ? rowid : nil
    }

    /// The last number of changes (inserts, updates, or deletes) made to the
    /// database via this connection.
    public var changes: Int {
        return Int(sqlite3_changes(handle))
    }

    /// The total number of changes (inserts, updates, or deletes) made to the
    /// database via this connection.
    public var totalChanges: Int {
        return Int(sqlite3_total_changes(handle))
    }

    // MARK: - Execute

    /// Executes a batch of SQL statements.
    ///
    /// - Parameter SQL: A batch of zero or more semicolon-separated SQL
    ///   statements.
    public func execute(SQL: String) throws {
        try check(sqlite3_exec(self.handle, SQL, nil, nil, nil))
    }

    // MARK: - Prepare

    /// Prepares a single SQL statement (with optional parameter bindings).
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A list of parameters to bind to the statement.
    ///
    /// - Returns: A prepared statement.
    @warn_unused_result public func prepare(statement: String, _ bindings: Binding?...) throws -> Statement {
        if !bindings.isEmpty { return try prepare(statement, bindings) }
        return try Statement(self, statement)
    }

    /// Prepares a single SQL statement and binds parameters to it.
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A list of parameters to bind to the statement.
    ///
    /// - Returns: A prepared statement.
    @warn_unused_result public func prepare(statement: String, _ bindings: [Binding?]) throws -> Statement {
        return try prepare(statement).bind(bindings)
    }

    /// Prepares a single SQL statement and binds parameters to it.
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A dictionary of named parameters to bind to the statement.
    ///
    /// - Returns: A prepared statement.
    @warn_unused_result public func prepare(statement: String, _ bindings: [String: Binding?]) throws -> Statement {
        return try prepare(statement).bind(bindings)
    }

    // MARK: - Run

    /// Runs a single SQL statement (with optional parameter bindings).
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A list of parameters to bind to the statement.
    ///
    /// - Returns: The statement.
    public func run(statement: String, _ bindings: Binding?...) throws -> Statement {
        return try run(statement, bindings)
    }

    /// Prepares, binds, and runs a single SQL statement.
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A list of parameters to bind to the statement.
    ///
    /// - Returns: The statement.
    public func run(statement: String, _ bindings: [Binding?]) throws -> Statement {
        return try prepare(statement).run(bindings)
    }

    /// Prepares, binds, and runs a single SQL statement.
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A dictionary of named parameters to bind to the statement.
    ///
    /// - Returns: The statement.
    public func run(statement: String, _ bindings: [String: Binding?]) throws -> Statement {
        return try prepare(statement).run(bindings)
    }

    // MARK: - Scalar

    /// Runs a single SQL statement (with optional parameter bindings),
    /// returning the first value of the first row.
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A list of parameters to bind to the statement.
    ///
    /// - Returns: The first value of the first row returned.
    @warn_unused_result public func scalar(statement: String, _ bindings: Binding?...) throws -> Binding? {
        return try scalar(statement, bindings)
    }

    /// Runs a single SQL statement (with optional parameter bindings),
    /// returning the first value of the first row.
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A list of parameters to bind to the statement.
    ///
    /// - Returns: The first value of the first row returned.
    @warn_unused_result public func scalar(statement: String, _ bindings: [Binding?]) throws -> Binding? {
        return try prepare(statement).scalar(bindings)
    }

    /// Runs a single SQL statement (with optional parameter bindings),
    /// returning the first value of the first row.
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A dictionary of named parameters to bind to the statement.
    ///
    /// - Returns: The first value of the first row returned.
    @warn_unused_result public func scalar(statement: String, _ bindings: [String: Binding?]) throws -> Binding? {
        return try prepare(statement).scalar(bindings)
    }

    // MARK: - Transactions

    /// The mode in which a transaction acquires a lock.
    public enum TransactionMode : String {

        /// Defers locking the database till the first read/write executes.
        case Deferred = "DEFERRED"

        /// Immediately acquires a reserved lock on the database.
        case Immediate = "IMMEDIATE"

        /// Immediately acquires an exclusive lock on all databases.
        case Exclusive = "EXCLUSIVE"

    }

    /// Runs a transaction with the given mode.
    ///
    /// - Note: Transactions cannot be nested. To nest transactions, see
    ///   `savepoint()`, instead.
    ///
    /// - Parameters:
    ///
    ///   - mode: The mode in which a transaction acquires a lock.
    ///
    ///     Default: `.Deferred`
    ///
    ///   - block: A closure to run SQL statements within the transaction.
    ///     The transaction will be committed when the block returns. The block
    ///     must throw to roll the transaction back.
    // TODO: consider not requiring a throw to roll back?
    public func transaction(mode: TransactionMode = .Deferred, @noescape block: () throws -> Void) throws {
        try transaction("BEGIN \(mode.rawValue) TRANSACTION", block, "COMMIT TRANSACTION", or: "ROLLBACK TRANSACTION")
    }

    /// Runs a transaction with the given savepoint name (if omitted, it will
    /// generate a UUID).
    ///
    /// - SeeAlso: `transaction()`.
    ///
    /// - Parameters:
    ///
    ///   - savepointName: A unique identifier for the savepoint (optional).
    ///
    ///   - block: A closure to run SQL statements within the transaction.
    ///     The savepoint will be released (committed) when the block returns.
    ///     The block must throw to roll the savepoint back.
    // TODO: consider not requiring a throw to roll back?
    // TODO: consider removing ability to set a name?
    public func savepoint(name: String = NSUUID().UUIDString, @noescape block: () throws -> Void) throws {
        let savepoint = "SAVEPOINT \(name.quote())"
        try transaction(savepoint, block, "RELEASE \(savepoint)", or: "ROLLBACK TO \(savepoint)")
    }

    private func transaction(begin: String, @noescape _ block: () throws -> Void, _ commit: String, or rollback: String) throws {
        try run(begin)
        do {
            try block()
            try run(commit)
        } catch {
            try run(rollback)
            throw error
        }
    }

    // MARK: - Handlers

    /// The number of seconds a connection will attempt to retry a statement
    /// after encountering a busy signal (lock).
    public var busyTimeout: Double = 0 {
        didSet {
            sqlite3_busy_timeout(handle, Int32(busyTimeout * 1_000))
        }
    }

    /// Sets a handler to call after encountering a busy signal (lock).
    ///
    /// - Parameter callback: This block is executed during a lock in which a
    ///   busy error would otherwise be returned. It’s passed the number of
    ///   times it’s been called for this lock. If it returns `true`, it will
    ///   try again. If it returns `false`, no further attempts will be made.
    public func busyHandler(callback: ((tries: Int) -> Bool)?) {
        if let callback = callback {
            busyHandler = { callback(tries: Int($0)) ? 1 : 0 }
        } else {
            busyHandler = nil
        }
    }
    private var busyHandler: _SQLiteBusyHandlerCallback?

    /// Sets a handler to call when a statement is executed with the compiled
    /// SQL.
    ///
    /// - Parameter callback: This block is invoked when a statement is executed
    ///   with the compiled SQL as its argument. E.g., pass `print` to act as a
    ///   logger.
    ///
    ///       db.trace(print)
    public func trace(callback: (String -> Void)?) {
        if let callback = callback {
            trace = { callback(String.fromCString($0)!) }
        } else {
            trace = nil
        }
        _SQLiteTrace(handle, trace)
    }
    private var trace: _SQLiteTraceCallback?

    /// Registers a callback to be invoked whenever a row is inserted, updated,
    /// or deleted in a rowid table.
    ///
    /// - Parameter callback: A callback invoked with the `Operation` (one of
    ///   `.Insert`, `.Update`, or `.Delete`), database name, table name, and
    ///   rowid.
    public func updateHook(callback: ((operation: Operation, db: String, table: String, rowid: Int64) -> Void)?) {
        if let callback = callback {
            updateHook = { operation, db, table, rowid in
                callback(
                    operation: Operation(rawValue: operation),
                    db: String.fromCString(db)!,
                    table: String.fromCString(table)!,
                    rowid: rowid
                )
            }
        } else {
            updateHook = nil
        }
        _SQLiteUpdateHook(handle, updateHook)
    }
    private var updateHook: _SQLiteUpdateHookCallback?

    /// Registers a callback to be invoked whenever a transaction is committed.
    ///
    /// - Parameter callback: A callback invoked whenever a transaction is
    ///   committed. If this callback throws, the transaction will be rolled
    ///   back.
    public func commitHook(callback: (() throws -> Void)?) {
        if let callback = callback {
            commitHook = {
                do {
                    try callback()
                    return 0
                } catch {
                    return 1
                }
            }
        } else {
            commitHook = nil
        }
        _SQLiteCommitHook(handle, commitHook)
    }
    private var commitHook: _SQLiteCommitHookCallback?

    /// Registers a callback to be invoked whenever a transaction rolls back.
    ///
    /// - Parameter callback: A callback invoked when a transaction is rolled
    ///   back.
    public func rollbackHook(callback: (() -> Void)?) {
        rollbackHook = callback
        _SQLiteRollbackHook(handle, rollbackHook)
    }
    private var rollbackHook: (() -> Void)?

    /// Creates or redefines a custom SQL function.
    ///
    /// - Parameters:
    ///
    ///   - function: The name of the function to create or redefine.
    ///
    ///   - argumentCount: The number of arguments that the function takes. If
    ///     `nil`, the function may take any number of arguments.
    ///
    ///     Default: `nil`
    ///
    ///   - deterministic: Whether or not the function is deterministic (_i.e._
    ///     the function always returns the same result for a given input).
    ///
    ///     Default: `false`
    ///
    ///   - block: A block of code to run when the function is called. The block
    ///     is called with an array of raw SQL values mapped to the function’s
    ///     parameters and should return a raw SQL value (or nil).
    public func createFunction(function: String, argumentCount: UInt? = nil, deterministic: Bool = false, _ block: (args: [Binding?]) -> Binding?) throws {
        let argc = argumentCount.map { Int($0) } ?? -1
        if functions[function] == nil { self.functions[function] = [:] }
        functions[function]?[argc] = { context, argc, argv in
            let arguments: [Binding?] = (0..<Int(argc)).map { idx in
                let value = argv[idx]
                switch sqlite3_value_type(value) {
                case SQLITE_BLOB:
                    return Data(bytes: sqlite3_value_blob(value), length: Int(sqlite3_value_bytes(value)))
                case SQLITE_FLOAT:
                    return sqlite3_value_double(value)
                case SQLITE_INTEGER:
                    return sqlite3_value_int64(value)
                case SQLITE_NULL:
                    return nil
                case SQLITE_TEXT:
                    return String.fromCString(UnsafePointer(sqlite3_value_text(value)))!
                case let type:
                    fatalError("unsupported value type: \(type)")
                }
            }
            let result = block(args: arguments)
            if let result = result as? Data {
                sqlite3_result_blob(context, result.bytes, Int32(result.length), nil)
            } else if let result = result as? Double {
                sqlite3_result_double(context, result)
            } else if let result = result as? Int64 {
                sqlite3_result_int64(context, result)
            } else if let result = result as? String {
                sqlite3_result_text(context, result, Int32(result.characters.count), SQLITE_TRANSIENT)
            } else if result == nil {
                sqlite3_result_null(context)
            } else {
                fatalError("unsupported result type: \(result)")
            }
        }
        try check(_SQLiteCreateFunction(handle, function, Int32(argc), deterministic ? 1 : 0, functions[function]?[argc]))
    }
    private var functions = [String: [Int: _SQLiteCreateFunctionCallback]]()


    /// The return type of a collation comparison function.
    public typealias ComparisonResult = NSComparisonResult

    /// Defines a new collating sequence.
    ///
    /// - Parameters:
    ///
    ///   - collation: The name of the collation added.
    ///
    ///   - block: A collation function that takes two strings and returns the
    ///     comparison result.
    public func createCollation(collation: String, _ block: (lhs: String, rhs: String) -> ComparisonResult) throws {
        collations[collation] = { lhs, rhs in
            Int32(block(lhs: String.fromCString(lhs)!, rhs: String.fromCString(rhs)!).rawValue)
        }
        try check(_SQLiteCreateCollation(handle, collation, collations[collation]))
    }
    private var collations = [String: _SQLiteCreateCollationCallback]()

    // MARK: - Error Handling

    func check(resultCode: Int32, statement: Statement? = nil) throws -> Int32 {
        if let error = Result(errorCode: resultCode, statement: statement) {
            throw error
        }

        return resultCode
    }

    private var queue = dispatch_queue_create("SQLite.Database", DISPATCH_QUEUE_SERIAL)

}

extension Connection : CustomStringConvertible {

    public var description: String {
        return String.fromCString(sqlite3_db_filename(handle, nil))!
    }

}

extension Connection.Location : CustomStringConvertible {

    public var description: String {
        switch self {
        case .InMemory:
            return ":memory:"
        case .Temporary:
            return ""
        case .URI(let URI):
            return URI
        }
    }

}

/// An SQL operation passed to update callbacks.
public enum Operation {

    /// An INSERT operation.
    case Insert

    /// An UPDATE operation.
    case Update

    /// A DELETE operation.
    case Delete

    private init(rawValue: Int32) {
        switch rawValue {
        case SQLITE_INSERT:
            self = .Insert
        case SQLITE_UPDATE:
            self = .Update
        case SQLITE_DELETE:
            self = .Delete
        default:
            fatalError("unhandled operation code: \(rawValue)")
        }
    }

}

public enum Result : ErrorType {

    private static let successCodes: Set = [SQLITE_OK, SQLITE_ROW, SQLITE_DONE]

    case Error(code: Int32, statement: Statement?)

    init?(errorCode: Int32, statement: Statement? = nil) {
        guard !Result.successCodes.contains(errorCode) else {
            return nil
        }
        self = Error(code: errorCode, statement: statement)
    }

}

extension Result : CustomStringConvertible {

    public var description: String {
        switch self {
        case .Error(let code, _):
            return String.fromCString(sqlite3_errstr(code))!
        }
    }

}
