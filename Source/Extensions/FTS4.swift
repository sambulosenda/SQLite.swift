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

    @warn_unused_result public func match(pattern: String) -> Expression<Bool> {
        return "MATCH".infix(tableName(), pattern)
    }

    @warn_unused_result public func match(pattern: Expression<String>) -> Expression<Bool> {
        return "MATCH".infix(tableName(), pattern)
    }

    @warn_unused_result public func match(pattern: Expression<String?>) -> Expression<Bool?> {
        return "MATCH".infix(tableName(), pattern)
    }

}

public enum Tokenizer {

    internal static let moduleName = "SQLite.swift"

    case Simple

    case Porter

    case Custom(String)

}

extension Tokenizer: CustomStringConvertible {

    public var description: String {
        switch self {
        case .Simple:
            return "simple"
        case .Porter:
            return "porter"
        case .Custom(let tokenizer):
            return " ".join([Tokenizer.moduleName.quote(), tokenizer.quote("'")])
        }
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
