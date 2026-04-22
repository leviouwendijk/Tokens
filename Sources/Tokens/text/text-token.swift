public struct TextToken: TokenProtocol, Sendable, Codable, Hashable {
    public let identifier: TokenIdentifier
    public let kind: TextTokenKind
    public let rawValue: String
    public let normalizedValue: String
    public let offsetRange: TokenOffsetRange

    public init(
        identifier: TokenIdentifier,
        kind: TextTokenKind,
        rawValue: String,
        normalizedValue: String,
        offsetRange: TokenOffsetRange
    ) {
        self.identifier = identifier
        self.kind = kind
        self.rawValue = rawValue
        self.normalizedValue = normalizedValue
        self.offsetRange = offsetRange
    }

    public func withKind(
        _ kind: TextTokenKind
    ) -> Self {
        .init(
            identifier: identifier,
            kind: kind,
            rawValue: rawValue,
            normalizedValue: normalizedValue,
            offsetRange: offsetRange
        )
    }
}
