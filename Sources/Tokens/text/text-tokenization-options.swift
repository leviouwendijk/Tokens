public struct TextTokenizationOptions: Sendable, Codable, Hashable {
    public struct EmissionOptions: Sendable, Codable, Hashable {
        public var separators: Bool
        public var whitespace: Bool
        
        public init(
            separators: Bool = false,
            whitespace: Bool = false
        ) {
            self.separators = separators
            self.whitespace = whitespace
        }
    }

    public var normalization: TokenNormalizationOptions
    public var emission: EmissionOptions
    public var coalesceAdjacentSeparators: Bool
    public var classifyNumbers: Bool
    public var namespace: String?

    public init(
        normalization: TokenNormalizationOptions = .defaults,
        emission: EmissionOptions = .init(),
        coalesceAdjacentSeparators: Bool = true,
        classifyNumbers: Bool = true,
        namespace: String? = "text"
    ) {
        self.normalization = normalization
        self.emission = emission
        self.coalesceAdjacentSeparators = coalesceAdjacentSeparators
        self.classifyNumbers = classifyNumbers
        self.namespace = namespace
    }

    public static let defaults: Self = .init()
}
