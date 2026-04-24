public struct TokenEstimateBreakdown: Sendable, Codable, Hashable {
    public var wordCount: Int
    public var numberCount: Int
    public var symbolCount: Int
    public var separatorCount: Int
    public var whitespaceCount: Int
    public var identifierComponentCount: Int
    public var longTokenCount: Int

    public var nonASCIIScalarCount: Int
    public var cjkScalarCount: Int
    public var emojiLikeScalarCount: Int

    public var wordTokens: Int
    public var numberTokens: Int
    public var symbolTokens: Int
    public var separatorTokens: Int
    public var whitespaceTokens: Int
    public var identifierComponentTokens: Int
    public var unicodePenaltyTokens: Int

    public init(
        wordCount: Int = 0,
        numberCount: Int = 0,
        symbolCount: Int = 0,
        separatorCount: Int = 0,
        whitespaceCount: Int = 0,
        identifierComponentCount: Int = 0,
        longTokenCount: Int = 0,
        nonASCIIScalarCount: Int = 0,
        cjkScalarCount: Int = 0,
        emojiLikeScalarCount: Int = 0,
        wordTokens: Int = 0,
        numberTokens: Int = 0,
        symbolTokens: Int = 0,
        separatorTokens: Int = 0,
        whitespaceTokens: Int = 0,
        identifierComponentTokens: Int = 0,
        unicodePenaltyTokens: Int = 0
    ) {
        self.wordCount = wordCount
        self.numberCount = numberCount
        self.symbolCount = symbolCount
        self.separatorCount = separatorCount
        self.whitespaceCount = whitespaceCount
        self.identifierComponentCount = identifierComponentCount
        self.longTokenCount = longTokenCount
        self.nonASCIIScalarCount = nonASCIIScalarCount
        self.cjkScalarCount = cjkScalarCount
        self.emojiLikeScalarCount = emojiLikeScalarCount
        self.wordTokens = wordTokens
        self.numberTokens = numberTokens
        self.symbolTokens = symbolTokens
        self.separatorTokens = separatorTokens
        self.whitespaceTokens = whitespaceTokens
        self.identifierComponentTokens = identifierComponentTokens
        self.unicodePenaltyTokens = unicodePenaltyTokens
    }

    public var lexicalTokens: Int {
        wordTokens
            + numberTokens
            + symbolTokens
            + separatorTokens
            + whitespaceTokens
            + identifierComponentTokens
            + unicodePenaltyTokens
    }
}
