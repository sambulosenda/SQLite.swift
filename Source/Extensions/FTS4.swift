extension Module {

    @warn_unused_result public static func FTS4(column: Expressible, _ more: Expressible...) -> Module {
        return FTS4([column] + more)
    }

    @warn_unused_result public static func FTS4(var columns: [Expressible] = [], tokenize tokenizer: Tokenizer? = nil) -> Module {
        if let tokenizer = tokenizer {
            columns.append("=".join([Expression<Void>(literal: "tokenize"), Expression<Void>(literal: tokenizer.description)]))
        }
        return Module(name: "fts4", arguments: columns)
    }

}

extension VirtualTable {

    /// Builds an expression appended with a `MATCH` query against the given
    /// pattern.
    ///
    ///     let emails = VirtualTable("emails")
    ///
    ///     emails.filter(emails.match("Hello"))
    ///     // SELECT * FROM "emails" WHERE "emails" MATCH 'Hello'
    ///
    /// - Parameter pattern: A pattern to match.
    ///
    /// - Returns: An expression appended with a `MATCH` query against the given
    ///   pattern.
    @warn_unused_result public func match(pattern: String) -> Expression<Bool> {
        return "MATCH".infix(tableName(), pattern)
    }

    @warn_unused_result public func match(pattern: Expression<String>) -> Expression<Bool> {
        return "MATCH".infix(tableName(), pattern)
    }

    @warn_unused_result public func match(pattern: Expression<String?>) -> Expression<Bool?> {
        return "MATCH".infix(tableName(), pattern)
    }

    /// Builds a copy of the query with a `WHERE … MATCH` clause.
    ///
    ///     let emails = VirtualTable("emails")
    ///
    ///     emails.match("Hello")
    ///     // SELECT * FROM "emails" WHERE "emails" MATCH 'Hello'
    ///
    /// - Parameter pattern: A pattern to match.
    ///
    /// - Returns: A query with the given `WHERE … MATCH` clause applied.
    @warn_unused_result public func match(pattern: String) -> QueryType {
        return filter(match(pattern))
    }

    @warn_unused_result public func match(pattern: Expression<String>) -> QueryType {
        return filter(match(pattern))
    }

    @warn_unused_result public func match(pattern: Expression<String?>) -> QueryType {
        return filter(match(pattern))
    }

}

public struct Tokenizer {

    public static let Simple = Tokenizer("simple")

    public static let Porter = Tokenizer("porter")

    @warn_unused_result public static func Unicode61(removeDiacritics removeDiacritics: Bool? = nil, tokenchars: Set<Character> = [], separators: Set<Character> = []) -> Tokenizer {
        var arguments = [String]()

        if let removeDiacritics = removeDiacritics {
            arguments.append("removeDiacritics=\(removeDiacritics ? 1 : 0)".quote())
        }

        if !tokenchars.isEmpty {
            let joined = "".join(tokenchars.map { String($0) })
            arguments.append("tokenchars=\(joined)".quote())
        }

        if !separators.isEmpty {
            let joined = "".join(separators.map { String($0) })
            arguments.append("separators=\(joined)".quote())
        }

        return Tokenizer("unicode61", arguments)
    }

    @warn_unused_result public static func Custom(name: String) -> Tokenizer {
        return Tokenizer(Tokenizer.moduleName.quote(), [name.quote()])
    }

    public let name: String

    public let arguments: [String]

    private init(_ name: String, _ arguments: [String] = []) {
        self.name = name
        self.arguments = arguments
    }

    private static let moduleName = "SQLite.swift"

}

extension Tokenizer : CustomStringConvertible {

    public var description: String {
        return " ".join([name] + arguments)
    }

}

extension Connection {

    public func registerTokenizer(submoduleName: String, next: String -> (String, Range<String.Index>)?) throws {
        try check(_SQLiteRegisterTokenizer(handle, Tokenizer.moduleName, submoduleName) { input, offset, length in
            let string = String.fromCString(input)!
            if let (token, range) = next(string) {
                let view = string.utf8
                offset.memory += string.substringToIndex(range.startIndex).utf8.count
                length.memory = Int32(distance(range.startIndex.samePositionIn(view), range.endIndex.samePositionIn(view)))
                return token
            }
            return nil
        })
    }

}
