/// A collating function used to compare to strings.
///
/// - SeeAlso: <https://www.sqlite.org/datatype3.html#collation>
public enum Collation {

    /// Compares string by raw data.
    case Binary

    /// Like binary, but folds uppercase ASCII letters into their lowercase
    /// equivalents.
    case Nocase

    /// Like binary, but strips trailing space.
    case Rtrim

    /// A custom collating sequence identified by the given string, registered
    /// using `Database.create(collation:…)`
    case Custom(String)

}

extension Collation : Expressible {

    public var expression: Expression<Void> {
        return Expression(literal: description)
    }

}

extension Collation : CustomStringConvertible {

    public var description : String {
        switch self {
        case Binary:
            return "BINARY"
        case Nocase:
            return "NOCASE"
        case Rtrim:
            return "RTRIM"
        case Custom(let collation):
            return collation.quote()
        }
    }

}
