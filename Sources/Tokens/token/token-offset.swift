public struct TokenOffsetRange: Sendable, Codable, Hashable, CustomStringConvertible {
    public let startoffset: Int
    public let endoffset: Int

    public init(
        startoffset: Int,
        endoffset: Int
    ) {
        precondition(
            startoffset >= 0,
            "TokenRange.startoffset must be >= 0"
        )
        precondition(
            endoffset >= startoffset,
            "TokenRange.endoffset must be >= startoffset"
        )

        self.startoffset = startoffset
        self.endoffset = endoffset
    }

    public init(
        uncheckedStart startoffset: Int,
        uncheckedEnd endoffset: Int
    ) {
        self.startoffset = startoffset
        self.endoffset = endoffset
    }

    public var isEmpty: Bool {
        startoffset == endoffset
    }

    public var length: Int {
        endoffset - startoffset
    }

    public func contains(
        _ offset: Int
    ) -> Bool {
        offset >= startoffset && offset < endoffset
    }

    public var description: String {
        "\(startoffset)..<\(endoffset)"
    }
}

public struct TokenSpan: Sendable, Codable, Hashable, CustomStringConvertible {
    public let identifier: TokenIdentifier
    public let range: TokenOffsetRange

    public init(
        identifier: TokenIdentifier,
        range: TokenOffsetRange
    ) {
        self.identifier = identifier
        self.range = range
    }

    public var description: String {
        "\(identifier)@\(range)"
    }
}
