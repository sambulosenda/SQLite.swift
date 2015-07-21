public final class Statement {

    private var handle: COpaquePointer = nil

    private let connection: Connection

    init(_ connection: Connection, _ SQL: String) throws {
        self.connection = connection
        try connection.check(sqlite3_prepare_v2(connection.handle, SQL, -1, &handle, nil))
    }

    deinit {
        sqlite3_finalize(handle)
    }

    public lazy var columnCount: Int = Int(sqlite3_column_count(self.handle))

    public lazy var columnNames: [String] = (0..<Int32(self.columnCount)).map {
        String.fromCString(sqlite3_column_name(self.handle, $0))!
    }

    public lazy var row: Cursor = Cursor(self)

    public func bind(values: Binding?...) -> Statement {
        return bind(values)
    }

    public func bind(values: [Binding?]) -> Statement {
        if values.isEmpty { return self }
        reset()
        assert(values.count == Int(sqlite3_bind_parameter_count(handle)), "\(sqlite3_bind_parameter_count(handle)) values expected, \(values.count) passed")
        for idx in 1...values.count { bind(values[idx - 1], atIndex: idx) }
        return self
    }

    public func bind(values: [String: Binding?]) -> Statement {
        reset()
        for (name, value) in values {
            let idx = sqlite3_bind_parameter_index(handle, name)
            assert(idx > 0, "parameter not found: \(name)")
            bind(value, atIndex: Int(idx))
        }
        return self
    }

    private func bind(value: Binding?, atIndex idx: Int) {
        if value == nil {
            sqlite3_bind_null(handle, Int32(idx))
        } else if let value = value as? NSData {
            sqlite3_bind_blob(handle, Int32(idx), value.bytes, Int32(value.length), SQLITE_TRANSIENT)
        } else if let value = value as? Double {
            sqlite3_bind_double(handle, Int32(idx), value)
        } else if let value = value as? Int64 {
            sqlite3_bind_int64(handle, Int32(idx), value)
        } else if let value = value as? String {
            sqlite3_bind_text(handle, Int32(idx), value, -1, SQLITE_TRANSIENT)
        } else if let value = value as? Int {
            self.bind(value.datatypeValue, atIndex: idx)
        } else if let value = value as? Bool {
            self.bind(value.datatypeValue, atIndex: idx)
        } else if let value = value {
            fatalError("tried to bind unexpected value \(value)")
        }
    }

    public func run(bindings: Binding?...) throws -> Statement {
        guard bindings.isEmpty else {
            return try run(bindings)
        }

        reset(clearBindings: false)
        repeat {} while try step()
        return self
    }

    public func run(bindings: [Binding?]) throws -> Statement {
        return try bind(bindings).run()
    }

    public func run(bindings: [String: Binding?]) throws -> Statement {
        return try bind(bindings).run()
    }

    @warn_unused_result public func scalar(bindings: Binding?...) throws -> Binding? {
        guard bindings.isEmpty else {
            return try scalar(bindings)
        }

        reset(clearBindings: false)
        try step()
        return row[0]
    }

    @warn_unused_result public func scalar(bindings: [Binding?]) throws -> Binding? {
        return try bind(bindings).scalar()
    }

    @warn_unused_result public func scalar(bindings: [String: Binding?]) throws -> Binding? {
        return try bind(bindings).scalar()
    }

    public func step() throws -> Bool {
        return try check(sqlite3_step(handle)) == SQLITE_ROW
    }

    private func reset(clearBindings shouldClear: Bool = true) {
        sqlite3_reset(handle)
        if (shouldClear) { sqlite3_clear_bindings(handle) }
    }

}

extension Statement : SequenceType {

    public func generate() -> Statement {
        reset(clearBindings: false)
        return self
    }

}

extension Statement : GeneratorType {

    public func next() -> [Binding?]? {
        do {
            return try step() ? Array(row) : nil
        } catch {
            assertionFailure("failed to step: \(error)")
            return nil
        }
    }

}

extension Statement : CustomStringConvertible {

    public var description: String {
        return String.fromCString(sqlite3_sql(handle))!
    }

}

public struct Cursor {

    private let handle: COpaquePointer

    private let columnCount: Int

    private init(_ statement: Statement) {
        handle = statement.handle
        columnCount = statement.columnCount
    }

    public subscript(idx: Int) -> Double {
        return sqlite3_column_double(handle, Int32(idx))
    }

    public subscript(idx: Int) -> Int64 {
        return sqlite3_column_int64(handle, Int32(idx))
    }

    public subscript(idx: Int) -> String {
        return String.fromCString(UnsafePointer(sqlite3_column_text(handle, Int32(idx)))) ?? ""
    }

    public subscript(idx: Int) -> Data {
        let bytes = sqlite3_column_blob(handle, Int32(idx))
        let length = Int(sqlite3_column_bytes(handle, Int32(idx)))
        return Data(bytes: bytes, length: length)
    }

    // MARK: -

    public subscript(idx: Int) -> Bool {
        return Bool.fromDatatypeValue(self[idx])
    }

    public subscript(idx: Int) -> Int {
        return Int.fromDatatypeValue(self[idx])
    }

}

extension Cursor : SequenceType {

    public subscript(idx: Int) -> Binding? {
        switch sqlite3_column_type(handle, Int32(idx)) {
        case SQLITE_BLOB:
            return self[idx] as Data
        case SQLITE_FLOAT:
            return self[idx] as Double
        case SQLITE_INTEGER:
            return self[idx] as Int64
        case SQLITE_NULL:
            return nil
        case SQLITE_TEXT:
            return self[idx] as String
        case let type:
            fatalError("unsupported column type: \(type)")
        }
    }

    public func generate() -> AnyGenerator<Binding?> {
        var idx = 0
        return anyGenerator {
            idx >= self.columnCount ? Optional<Binding?>.None : self[idx++]
        }
    }

}
