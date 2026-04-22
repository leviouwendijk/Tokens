public protocol TokenProtocol: Sendable, Codable, Hashable {
    var identifier: TokenIdentifier { get }
    var rawValue: String { get }
    var normalizedValue: String { get }
    var offsetRange: TokenOffsetRange { get }
}

public extension TokenProtocol {
    var isEmpty: Bool {
        normalizedValue.isEmpty
    }

    var span: TokenSpan {
        TokenSpan(
            identifier: identifier,
            range: offsetRange
        )
    }
}
