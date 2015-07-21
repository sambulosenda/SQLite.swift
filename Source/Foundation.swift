extension NSData : Value {

    public class var declaredDatatype: String {
        return Data.declaredDatatype
    }

    public class func fromDatatypeValue(dataValue: Data) -> NSData {
        return NSData(bytes: dataValue.bytes, length: dataValue.length)
    }

    public var datatypeValue: Data {
        return Data(bytes: bytes, length: length)
    }

}

extension NSDate : Value {

    public class var declaredDatatype: String {
        return String.declaredDatatype
    }

    public class func fromDatatypeValue(stringValue: String) -> NSDate {
        return dateFormatter.dateFromString(stringValue)!
    }

    public var datatypeValue: String {
        return dateFormatter.stringFromDate(self)
    }

}

/// A global date formatter used to serialize and deserialize `NSDate` objects.
/// If multiple date formats are used in an application’s database(s), use a
/// custom `Value` type per additional format.
public var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    return formatter
}()

// FIXME: rdar://problem/18673897 // subscript<T>…

extension QueryType {

    public subscript(column: Expression<NSData>) -> Expression<NSData> {
        return namespace(column)
    }
    public subscript(column: Expression<NSData?>) -> Expression<NSData?> {
        return namespace(column)
    }

    public subscript(column: Expression<NSDate>) -> Expression<NSDate> {
        return namespace(column)
    }
    public subscript(column: Expression<NSDate?>) -> Expression<NSDate?> {
        return namespace(column)
    }

}

extension Row {

    public subscript(column: Expression<NSData>) -> NSData {
        return get(column)
    }
    public subscript(column: Expression<NSData?>) -> NSData? {
        return get(column)
    }

    public subscript(column: Expression<NSDate>) -> NSDate {
        return get(column)
    }
    public subscript(column: Expression<NSDate?>) -> NSDate? {
        return get(column)
    }

}