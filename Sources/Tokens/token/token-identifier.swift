import Foundation

public struct TokenIdentifier: Sendable, Codable, Hashable, CustomStringConvertible {
    public var namespace: String?
    public var source: String?
    public var ordinal: Int?

    public init(
        namespace: String? = nil,
        source: String? = nil,
        ordinal: Int? = nil
    ) {
        self.namespace = namespace
        self.source = source
        self.ordinal = ordinal
    }

    public static func source(
        _ source: String?,
        ordinal: Int? = nil,
        namespace: String? = nil
    ) -> Self {
        .init(
            namespace: namespace,
            source: source,
            ordinal: ordinal
        )
    }

    public var description: String {
        var parts: [String] = []

        if let namespace {
            parts.append(namespace)
        }

        if let source {
            parts.append(source)
        }

        if let ordinal {
            parts.append("#\(ordinal)")
        }

        guard !parts.isEmpty else {
            return "token"
        }

        return parts.joined(separator: ":")
    }
}
