public extension Connection {

    /// Creates or redefines a custom SQL function.
    ///
    /// - Parameters:
    ///
    ///   - function: The name of the function to create or redefine.
    ///
    ///   - deterministic: Whether or not the function is deterministic (_i.e._
    ///     the function always returns the same result for a given input).
    ///
    ///     Default: `false`
    ///
    ///   - block: A block of code to run when the function is called.
    ///     The assigned types must be explicit.
    ///
    /// - Returns: A closure returning an SQL expression to call the function.
    public func createFunction<Z : Value>(function: String, deterministic: Bool = false, _ block: () -> Z) throws -> (() -> Expression<Z>) {
        let fn = try createFunction(function, 0, deterministic) { _ in block() }
        return { fn([]) }
    }

    public func createFunction<Z : Value>(function: String, deterministic: Bool = false, _ block: () -> Z?) throws -> (() -> Expression<Z?>) {
        let fn = try createFunction(function, 0, deterministic) { _ in block() }
        return { fn([]) }
    }

    // MARK: -

    public func createFunction<Z : Value, A : Value>(function: String, deterministic: Bool = false, _ block: A -> Z) throws -> (Expression<A> -> Expression<Z>) {
        let fn = try createFunction(function, 1, deterministic) { args in block(value(args[0])) }
        return { arg in fn([arg]) }
    }

    public func createFunction<Z : Value, A : Value>(function function: String, deterministic: Bool = false, _ block: A? -> Z) throws -> (Expression<A?> -> Expression<Z>) {
        let fn = try createFunction(function, 1, deterministic) { args in block(args[0].map(value)) }
        return { arg in fn([arg]) }
    }

    public func createFunction<Z : Value, A : Value>(function function: String, deterministic: Bool = false, _ block: A -> Z?) throws -> (Expression<A> -> Expression<Z?>) {
        let fn = try createFunction(function, 1, deterministic) { args in block(value(args[0])) }
        return { arg in fn([arg]) }
    }

    public func createFunction<Z : Value, A : Value>(function function: String, deterministic: Bool = false, _ block: A? -> Z?) throws -> (Expression<A?> -> Expression<Z?>) {
        let fn = try createFunction(function, 1, deterministic) { args in block(args[0].map(value)) }
        return { arg in fn([arg]) }
    }

    // MARK: -

    public func createFunction<Z : Value, A : Value, B : Value>(function: String, deterministic: Bool = false, _ block: (A, B) -> Z) throws -> (Expression<A>, Expression<B>) -> Expression<Z> {
        let fn = try createFunction(function, 1, deterministic) { args in block(value(args[0]), value(args[1])) }
        return { a, b in fn([a, b]) }
    }

    public func createFunction<Z : Value, A : Value, B : Value>(function: String, deterministic: Bool = false, _ block: (A, B) -> Z?) throws -> (Expression<A>, Expression<B>) -> Expression<Z?> {
        let fn = try createFunction(function, 1, deterministic) { args in block(value(args[0]), value(args[1])) }
        return { a, b in fn([a, b]) }
    }

    public func createFunction<Z : Value, A : Value, B : Value>(function: String, deterministic: Bool = false, _ block: (A, B?) -> Z) throws -> (Expression<A>, Expression<B?>) -> Expression<Z> {
        let fn = try createFunction(function, 1, deterministic) { args in block(value(args[0]), args[1].map(value)) }
        return { a, b in fn([a, b]) }
    }

    public func createFunction<Z : Value, A : Value, B : Value>(function: String, deterministic: Bool = false, _ block: (A?, B) -> Z) throws -> (Expression<A?>, Expression<B>) -> Expression<Z> {
        let fn = try createFunction(function, 1, deterministic) { args in block(args[0].map(value), value(args[1])) }
        return { a, b in fn([a, b]) }
    }

    public func createFunction<Z : Value, A : Value, B : Value>(function: String, deterministic: Bool = false, _ block: (A, B?) -> Z?) throws -> (Expression<A>, Expression<B?>) -> Expression<Z?> {
        let fn = try createFunction(function, 1, deterministic) { args in block(value(args[0]), args[1].map(value)) }
        return { a, b in fn([a, b]) }
    }

    public func createFunction<Z : Value, A : Value, B : Value>(function: String, deterministic: Bool = false, _ block: (A?, B) -> Z?) throws -> (Expression<A?>, Expression<B>) -> Expression<Z?> {
        let fn = try createFunction(function, 1, deterministic) { args in block(args[0].map(value), value(args[1])) }
        return { a, b in fn([a, b]) }
    }

    public func createFunction<Z : Value, A : Value, B : Value>(function: String, deterministic: Bool = false, _ block: (A?, B?) -> Z?) throws -> (Expression<A?>, Expression<B?>) -> Expression<Z?> {
        let fn = try createFunction(function, 1, deterministic) { args in block(args[0].map(value), args[1].map(value)) }
        return { a, b in fn([a, b]) }
    }

    // TODO: complete the above

    // MARK: -

    private func createFunction<Z : Value>(function: String, _ argumentCount: UInt, _ deterministic: Bool, _ block: [Binding?] -> Z) throws -> ([Expressible] -> Expression<Z>) {
        try createFunction(function, argumentCount: argumentCount, deterministic: deterministic) { arguments in
            block(arguments).datatypeValue
        }
        return { arguments in
            function.quote().wrap(", ".join(arguments))
        }
    }

    private func createFunction<Z : Value>(function: String, _ argumentCount: UInt, _ deterministic: Bool, _ block: [Binding?] -> Z?) throws -> ([Expressible] -> Expression<Z?>) {
        try createFunction(function, argumentCount: argumentCount, deterministic: deterministic) { arguments in
            block(arguments)?.datatypeValue
        }
        return { arguments in
            function.quote().wrap(", ".join(arguments))
        }
    }

}
