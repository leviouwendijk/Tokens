public struct TokenEstimate: Sendable, Codable, Hashable {
    public var estimatedTokens: Int
    public var baseTokens: Int
    public var overheadTokens: Int
    public var marginTokens: Int

    public var characterCount: Int
    public var scalarCount: Int
    public var lineCount: Int
    public var textTokenCount: Int

    public var breakdown: TokenEstimateBreakdown
    public var confidence: TokenEstimateConfidence
    public var diagnostics: [TokenEstimateDiagnostic]

    public init(
        estimatedTokens: Int,
        baseTokens: Int,
        overheadTokens: Int,
        marginTokens: Int,
        characterCount: Int,
        scalarCount: Int,
        lineCount: Int,
        textTokenCount: Int,
        breakdown: TokenEstimateBreakdown = .init(),
        confidence: TokenEstimateConfidence = .estimated,
        diagnostics: [TokenEstimateDiagnostic] = []
    ) {
        self.estimatedTokens = estimatedTokens
        self.baseTokens = baseTokens
        self.overheadTokens = overheadTokens
        self.marginTokens = marginTokens
        self.characterCount = characterCount
        self.scalarCount = scalarCount
        self.lineCount = lineCount
        self.textTokenCount = textTokenCount
        self.breakdown = breakdown
        self.confidence = confidence
        self.diagnostics = diagnostics
    }

    public var totalBeforeMargin: Int {
        baseTokens + overheadTokens
    }
}
