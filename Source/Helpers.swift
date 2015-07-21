func check(resultCode: Int32, statement: Statement? = nil) throws -> Int32 {
    if let error = Result(errorCode: resultCode, statement: statement) {
        throw error
    }

    return resultCode
}

// let SQLITE_STATIC = unsafeBitCast(0, sqlite3_destructor_type.self)
let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self)

public typealias Star = (Expression<Binding>?, Expression<Binding>?) -> Expression<Void>

public func *(_: Expression<Binding>?, _: Expression<Binding>?) -> Expression<Void> {
    return Expression(literal: "*")
}

public protocol _OptionalType {

    typealias Wrapped

}

extension Optional : _OptionalType {

    public typealias Wrapped = T

}

extension String {

    @warn_unused_result func quote(mark: Character = "\"") -> String {
        let escaped = characters.reduce("") { string, character in
            string + (character == mark ? "\(mark)\(mark)" : "\(character)")
        }
        return "\(mark)\(escaped)\(mark)"
    }

    @warn_unused_result func join(expressions: [Expressible]) -> Expressible {
        var (template, bindings) = ([String](), [Binding?]())
        for expressible in expressions {
            let expression = expressible.expression
            template.append(expression.template)
            bindings.extend(expression.bindings)
        }
        return Expression<Void>(join(template), bindings)
    }

    @warn_unused_result func infix<T>(lhs: Expressible, _ rhs: Expressible, wrap: Bool = true) -> Expression<T> {
        let expression = Expression<T>(" \(self) ".join([lhs, rhs]).expression)
        guard wrap else {
            return expression
        }
        return "".wrap(expression)
    }

    @warn_unused_result func prefix(expressions: Expressible) -> Expressible {
        return "\(self) ".wrap(expressions) as Expression<Void>
    }

    @warn_unused_result func prefix(expressions: [Expressible]) -> Expressible {
        return "\(self) ".wrap(expressions) as Expression<Void>
    }

    @warn_unused_result func wrap<T>(expression: Expressible) -> Expression<T> {
        return Expression("\(self)(\(expression.expression.template))", expression.expression.bindings)
    }

    @warn_unused_result func wrap<T>(expressions: [Expressible]) -> Expression<T> {
        return wrap(", ".join(expressions))
    }

}

@warn_unused_result func infix<T>(lhs: Expressible, _ rhs: Expressible, wrap: Bool = true, function: String = __FUNCTION__) -> Expression<T> {
    return function.infix(lhs, rhs, wrap: wrap)
}

@warn_unused_result func wrap<T>(expression: Expressible, function: String = __FUNCTION__) -> Expression<T> {
    return function.wrap(expression)
}

@warn_unused_result func wrap<T>(expressions: [Expressible], function: String = __FUNCTION__) -> Expression<T> {
    return function.wrap(", ".join(expressions))
}

@warn_unused_result func transcode(literal: Binding?) -> String {
    if let literal = literal {
        if let literal = literal as? NSData {
            let buf = UnsafeBufferPointer(start: UnsafePointer<UInt8>(literal.bytes), count: literal.length)
            let hex = "".join(buf.map { String(format: "%02x", $0) })
            return "x'\(hex)'"
        }
        if let literal = literal as? String { return literal.quote("'") }
        return "\(literal)"
    }
    return "NULL"
}

@warn_unused_result func value<A: Value>(v: Binding) -> A {
    return A.fromDatatypeValue(v as! A.Datatype) as! A
}

@warn_unused_result func value<A: Value>(v: Binding?) -> A {
    return value(v!)
}
