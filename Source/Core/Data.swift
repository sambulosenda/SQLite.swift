public struct Data {

    public var bytes: UnsafePointer<Void> {
        return UnsafePointer(implementation.bytes)
    }

    public var length: Int {
        return implementation.length
    }

    public init(bytes: UnsafePointer<Void>, length: Int) {
        self.implementation = Implementation(bytes: bytes, length: length)
    }

    // MARK: -

    private var implementation: Implementation

    private final class Implementation {

        let bytes: UnsafeMutablePointer<UInt8>
        let length: Int

        init(bytes: UnsafePointer<Void>, length: Int) {
            self.bytes = UnsafeMutablePointer.alloc(length + 1)
            self.length = length

            memcpy(self.bytes, bytes, length)
            self.bytes[length] = 0
        }

        deinit {
            bytes.dealloc(length + 1)
        }

    }

}
