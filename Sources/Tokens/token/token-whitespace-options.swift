public struct TokenWhitespaceOptions: Sendable, Codable, Hashable {
    public struct InnerWhitespaceOptions: Sendable, Codable, Hashable {
        public var collapse: Bool
        
        public init(
            collapse: Bool = false
        ) {
            self.collapse = collapse
        }

        public static let defaults: Self = .init()
    }

    public var trim: Bool
    public var inner: InnerWhitespaceOptions

    public init(
        trim: Bool = true,
        inner: InnerWhitespaceOptions = .init()
    ) {
        self.trim = trim
        self.inner = inner
    }

    public static let defaults: Self = .init()
}
