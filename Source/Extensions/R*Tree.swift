extension Module {

    @warn_unused_result public static func RTree<T : Value, U : Value where T.Datatype == Int64, U.Datatype == Double>(primaryKey: Expression<T>, _ pairs: (Expression<U>, Expression<U>)...) -> Module {
        var arguments: [Expressible] = [primaryKey]

        for pair in pairs {
            arguments.extend([pair.0, pair.1] as [Expressible])
        }

        return Module(name: "rtree", arguments: arguments)
    }

}
