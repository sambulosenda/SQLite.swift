extension ExpressionType where UnderlyingType : Value {

    /// Builds a copy of the expression prefixed with the `DISTINCT` keyword.
    ///
    ///     let name = Expression<String>("name")
    ///     name.distinct
    ///     // DISTINCT "name"
    ///
    /// - Returns: A copy of the expression prefixed with the `DISTINCT`
    ///   keyword.
    public var distinct: Expression<UnderlyingType> {
        return Expression("DISTINCT \(template)", bindings)
    }

    /// Builds a copy of the expression wrapped with the `count` aggregate
    /// function.
    ///
    ///     let name = Expression<String?>("name")
    ///     name.count
    ///     // count("name")
    ///     name.distinct.count
    ///     // count(DISTINCT "name")
    ///
    /// - Returns: A copy of the expression wrapped with the `count` aggregate
    ///   function.
    public var count: Expression<Int> {
        return wrap(self)
    }

}

extension ExpressionType where UnderlyingType : _OptionalType, UnderlyingType.Wrapped : Value {

    /// Builds a copy of the expression prefixed with the `DISTINCT` keyword.
    ///
    ///     let name = Expression<String?>("name")
    ///     name.distinct
    ///     // DISTINCT "name"
    ///
    /// - Returns: A copy of the expression prefixed with the `DISTINCT`
    ///   keyword.
    public var distinct: Expression<UnderlyingType> {
        return Expression("DISTINCT \(template)", bindings)
    }

    /// Builds a copy of the expression wrapped with the `count` aggregate
    /// function.
    ///
    ///     let name = Expression<String?>("name")
    ///     name.count
    ///     // count("name")
    ///     name.distinct.count
    ///     // count(DISTINCT "name")
    ///
    /// - Returns: A copy of the expression wrapped with the `count` aggregate
    ///   function.
    public var count: Expression<Int> {
        return wrap(self)
    }

}

extension ExpressionType where UnderlyingType : protocol<Value, Comparable> {

    /// Builds a copy of the expression wrapped with the `max` aggregate
    /// function.
    ///
    ///     let age = Expression<Int>("age")
    ///     age.max
    ///     // max("age")
    ///
    /// - Returns: A copy of the expression wrapped with the `max` aggregate
    ///   function.
    public var max: Expression<UnderlyingType> {
        return wrap(self)
    }

    /// Builds a copy of the expression wrapped with the `min` aggregate
    /// function.
    ///
    ///     let age = Expression<Int>("age")
    ///     age.min
    ///     // min("age")
    ///
    /// - Returns: A copy of the expression wrapped with the `min` aggregate
    ///   function.
    public var min: Expression<UnderlyingType> {
        return wrap(self)
    }

}

extension ExpressionType where UnderlyingType : _OptionalType, UnderlyingType.Wrapped : protocol<Value, Comparable> {

    /// Builds a copy of the expression wrapped with the `max` aggregate
    /// function.
    ///
    ///     let age = Expression<Int?>("age")
    ///     age.max
    ///     // max("age")
    ///
    /// - Returns: A copy of the expression wrapped with the `max` aggregate
    ///   function.
    public var max: Expression<UnderlyingType> {
        return wrap(self)
    }

    /// Builds a copy of the expression wrapped with the `min` aggregate
    /// function.
    ///
    ///     let age = Expression<Int?>("age")
    ///     age.min
    ///     // min("age")
    ///
    /// - Returns: A copy of the expression wrapped with the `min` aggregate
    ///   function.
    public var min: Expression<UnderlyingType> {
        return wrap(self)
    }

}

extension ExpressionType where UnderlyingType : Value, UnderlyingType.Datatype : Number {

    /// Builds a copy of the expression wrapped with the `avg` aggregate
    /// function.
    ///
    ///     let salary = Expression<Double>("salary")
    ///     salary.average
    ///     // avg("salary")
    ///
    /// - Returns: A copy of the expression wrapped with the `min` aggregate
    ///   function.
    public var average: Expression<UnderlyingType> {
        return "avg".wrap(self)
    }

    /// Builds a copy of the expression wrapped with the `sum` aggregate
    /// function.
    ///
    ///     let salary = Expression<Double>("salary")
    ///     salary.sum
    ///     // sum("salary")
    ///
    /// - Returns: A copy of the expression wrapped with the `min` aggregate
    ///   function.
    public var sum: Expression<UnderlyingType> {
        return wrap(self)
    }

    /// Builds a copy of the expression wrapped with the `total` aggregate
    /// function.
    ///
    ///     let salary = Expression<Double>("salary")
    ///     salary.total
    ///     // total("salary")
    ///
    /// - Returns: A copy of the expression wrapped with the `min` aggregate
    ///   function.
    public var total: Expression<Double> {
        return wrap(self)
    }

}

extension ExpressionType where UnderlyingType : _OptionalType, UnderlyingType.Wrapped : Value, UnderlyingType.Wrapped.Datatype : Number {

    /// Builds a copy of the expression wrapped with the `avg` aggregate
    /// function.
    ///
    ///     let salary = Expression<Double?>("salary")
    ///     salary.average
    ///     // avg("salary")
    ///
    /// - Returns: A copy of the expression wrapped with the `min` aggregate
    ///   function.
    public var average: Expression<UnderlyingType> {
        return "avg".wrap(self)
    }

    /// Builds a copy of the expression wrapped with the `sum` aggregate
    /// function.
    ///
    ///     let salary = Expression<Double?>("salary")
    ///     salary.sum
    ///     // sum("salary")
    ///
    /// - Returns: A copy of the expression wrapped with the `min` aggregate
    ///   function.
    public var sum: Expression<UnderlyingType> {
        return wrap(self)
    }

    /// Builds a copy of the expression wrapped with the `total` aggregate
    /// function.
    ///
    ///     let salary = Expression<Double?>("salary")
    ///     salary.total
    ///     // total("salary")
    ///
    /// - Returns: A copy of the expression wrapped with the `min` aggregate
    ///   function.
    public var total: Expression<Double> {
        return wrap(self)
    }

}

/// Builds an expression representing `count(*)` (when called with the `*`
/// function literal).
///
///     count(*)
///     // count(*)
///
/// - Returns: An expression returning `count(*)` (when called with the `*`
///   function literal).
@warn_unused_result public func count(star: Star) -> Expression<Int> {
    return wrap(star(nil, nil))
}
