public struct TokenCaseOptions: Sendable, Codable, Hashable {
    public var sensitivity: TokenCaseSensitivity
    
    public init(
        sensitivity: TokenCaseSensitivity = .insensitive
    ) {
        self.sensitivity = sensitivity
    }

    public static let defaults: Self = .init(
        sensitivity: .insensitive
    )
}
