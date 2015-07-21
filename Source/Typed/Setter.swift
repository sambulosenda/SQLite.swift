infix operator <- {
    associativity left
    precedence 135
    assignment
}

public struct Setter {

    let column: Expressible
    let value: Expressible

    private init<V : Value>(column: Expression<V>, value: Expression<V>) {
        self.column = column
        self.value = value
    }

    private init<V : Value>(column: Expression<V>, value: V) {
        self.column = column
        self.value = value
    }

    private init<V : Value>(column: Expression<V?>, value: Expression<V>) {
        self.column = column
        self.value = value
    }

    private init<V : Value>(column: Expression<V?>, value: Expression<V?>) {
        self.column = column
        self.value = value
    }

    private init<V : Value>(column: Expression<V?>, value: V?) {
        self.column = column
        self.value = Expression<V?>(value: value)
    }

}

extension Setter : Expressible {

    public var expression: Expression<Void> {
        return "=".infix(column, value, wrap: false)
    }

}

public func <-<V : Value>(column: Expression<V>, value: Expression<V>) -> Setter {
    return Setter(column: column, value: value)
}
public func <-<V : Value>(column: Expression<V>, value: V) -> Setter {
    return Setter(column: column, value: value)
}
public func <-<V : Value>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return Setter(column: column, value: value)
}
public func <-<V : Value>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return Setter(column: column, value: value)
}
public func <-<V : Value>(column: Expression<V?>, value: V?) -> Setter {
    return Setter(column: column, value: value)
}

public func +=(column: Expression<String>, value: Expression<String>) -> Setter {
    return column <- column + value
}
public func +=(column: Expression<String>, value: String) -> Setter {
    return column <- column + value
}
public func +=(column: Expression<String?>, value: Expression<String>) -> Setter {
    return column <- column + value
}
public func +=(column: Expression<String?>, value: Expression<String?>) -> Setter {
    return column <- column + value
}
public func +=(column: Expression<String?>, value: String) -> Setter {
    return column <- column + value
}

public func +=<V : Value where V.Datatype : Number>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- column + value
}
public func +=<V : Value where V.Datatype : Number>(column: Expression<V>, value: V) -> Setter {
    return column <- column + value
}
public func +=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- column + value
}
public func +=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- column + value
}
public func +=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: V) -> Setter {
    return column <- column + value
}

public func -=<V : Value where V.Datatype : Number>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- column - value
}
public func -=<V : Value where V.Datatype : Number>(column: Expression<V>, value: V) -> Setter {
    return column <- column - value
}
public func -=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- column - value
}
public func -=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- column - value
}
public func -=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: V) -> Setter {
    return column <- column - value
}

public func *=<V : Value where V.Datatype : Number>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- column * value
}
public func *=<V : Value where V.Datatype : Number>(column: Expression<V>, value: V) -> Setter {
    return column <- column * value
}
public func *=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- column * value
}
public func *=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- column * value
}
public func *=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: V) -> Setter {
    return column <- column * value
}

public func /=<V : Value where V.Datatype : Number>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- column / value
}
public func /=<V : Value where V.Datatype : Number>(column: Expression<V>, value: V) -> Setter {
    return column <- column / value
}
public func /=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- column / value
}
public func /=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- column / value
}
public func /=<V : Value where V.Datatype : Number>(column: Expression<V?>, value: V) -> Setter {
    return column <- column / value
}

public func %=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- column % value
}
public func %=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: V) -> Setter {
    return column <- column % value
}
public func %=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- column % value
}
public func %=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- column % value
}
public func %=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: V) -> Setter {
    return column <- column % value
}

public func <<=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- column << value
}
public func <<=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: V) -> Setter {
    return column <- column << value
}
public func <<=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- column << value
}
public func <<=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- column << value
}
public func <<=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: V) -> Setter {
    return column <- column << value
}

public func >>=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- column >> value
}
public func >>=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: V) -> Setter {
    return column <- column >> value
}
public func >>=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- column >> value
}
public func >>=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- column >> value
}
public func >>=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: V) -> Setter {
    return column <- column >> value
}

public func &=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- column & value
}
public func &=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: V) -> Setter {
    return column <- column & value
}
public func &=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- column & value
}
public func &=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- column & value
}
public func &=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: V) -> Setter {
    return column <- column & value
}

public func |=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- column | value
}
public func |=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: V) -> Setter {
    return column <- column | value
}
public func |=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- column | value
}
public func |=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- column | value
}
public func |=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: V) -> Setter {
    return column <- column | value
}

public func ^=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- column ^ value
}
public func ^=<V : Value where V.Datatype == Int64>(column: Expression<V>, value: V) -> Setter {
    return column <- column ^ value
}
public func ^=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- column ^ value
}
public func ^=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- column ^ value
}
public func ^=<V : Value where V.Datatype == Int64>(column: Expression<V?>, value: V) -> Setter {
    return column <- column ^ value
}

public postfix func ++<V : Value where V.Datatype == Int64>(column: Expression<V>) -> Setter {
    return Expression<Int>(column) += 1
}
public postfix func ++<V : Value where V.Datatype == Int64>(column: Expression<V?>) -> Setter {
    return Expression<Int>(column) += 1
}

public postfix func --<V : Value where V.Datatype == Int64>(column: Expression<V>) -> Setter {
    return Expression<Int>(column) -= 1
}
public postfix func --<V : Value where V.Datatype == Int64>(column: Expression<V?>) -> Setter {
    return Expression<Int>(column) -= 1
}
