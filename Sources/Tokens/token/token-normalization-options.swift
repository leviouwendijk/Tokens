public struct TokenNormalizationOptions: Sendable, Codable, Hashable {
    public var `case`: TokenCaseOptions
    public var whitespace: TokenWhitespaceOptions

    public init(
        `case`: TokenCaseOptions = .defaults,
        whitespace: TokenWhitespaceOptions = .defaults
    ) {
        self.case = `case`
        self.whitespace = whitespace
    }

    public static let defaults: Self = .init()
}
