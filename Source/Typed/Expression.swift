public protocol ExpressionType : Expressible { // extensions cannot have inheritance clauses

    typealias UnderlyingType = Void

    var template: String { get }
    var bindings: [Binding?] { get }

    init(_ template: String, _ bindings: [Binding?])

}

extension ExpressionType {

    public init(literal: String) {
        self.init(literal, [])
    }

    public init(_ identifier: String) {
        self.init(literal: identifier.quote())
    }

    public init<U : ExpressionType>(_ expression: U) {
        self.init(expression.template, expression.bindings)
    }

//    public init(_ expressible: Expressible) {
//        self.init(expressible.expression.template, expressible.expression.bindings)
//    }

}

/// An `Expression` represents a raw SQL fragment and any associated bindings.
public struct Expression<Datatype> : ExpressionType {

    public typealias UnderlyingType = Datatype

    public var template: String
    public var bindings: [Binding?]

    public var ascending: Bool?
    public var original: Expressible?

    public init(_ template: String, _ bindings: [Binding?]) {
        self.template = template
        self.bindings = bindings
    }

}

public protocol Expressible {

    var expression: Expression<Void> { get }

}

extension Expressible {

    // naïve compiler for statements that can’t be bound, e.g., CREATE TABLE
    // FIXME: use @testable and make internal
    public func asSQL() -> String {
        let expressed = expression
        var idx = 0
        return expressed.template.characters.reduce("") { template, character in
            return template + (character == "?" ? transcode(expressed.bindings[idx++]) : String(character))
        }
    }

}

extension ExpressionType {

    public var expression: Expression<Void> {
        return Expression(template, bindings)
    }

}

extension ExpressionType where UnderlyingType : Value {

    public init(value: UnderlyingType) {
        self.init("?", [value.datatypeValue])
    }

}

extension ExpressionType where UnderlyingType : _OptionalType, UnderlyingType.Wrapped : Value {

    public static var null: Self {
        return self.init(value: nil)
    }

    public init(value: UnderlyingType.Wrapped?) {
        self.init("?", [value?.datatypeValue])
    }

}

extension Value {

    public var expression: Expression<Void> {
        return Expression(value: self).expression
    }

}

public let rowid = Expression<Int64>("ROWID")

public func cast<T: Value, U: Value>(expression: Expression<T>) -> Expression<U> {
    return Expression("CAST (\(expression.template) AS \(U.declaredDatatype))", expression.bindings)
}

public func cast<T: Value, U: Value>(expression: Expression<T?>) -> Expression<U?> {
    return Expression("CAST (\(expression.template) AS \(U.declaredDatatype))", expression.bindings)
}
