public struct TokenEstimationOptions: Sendable, Codable, Hashable {
    public var mode: TokenCountMode
    public var normalization: TokenNormalizationOptions

    public var splitIdentifierComponents: Bool
    public var emitWhitespaceTokens: Bool
    public var coalesceAdjacentSeparators: Bool

    public var wordCharactersPerToken: Int
    public var numberCharactersPerToken: Int
    public var identifierCharactersPerToken: Int
    public var separatorCharactersPerToken: Int
    public var symbolCharactersPerToken: Int
    public var whitespaceCharactersPerToken: Int

    public var whitespaceRunMinimumTokens: Int
    public var newlineTokenCost: Int
    public var lineOverheadTokenEvery: Int
    public var framingOverheadTokens: Int
    public var safetyMarginPercent: Int
    public var minimumTokenCount: Int

    public var largeInputCharacterThreshold: Int
    public var manyLinesThreshold: Int
    public var manySymbolsRatioPercent: Int
    public var manySeparatorsRatioPercent: Int
    public var longTokenCharacterThreshold: Int

    public var nonASCIIScalarsPerExtraToken: Int
    public var cjkScalarTokenCost: Int
    public var emojiLikeScalarTokenCost: Int

    public init(
        mode: TokenCountMode = .balanced,
        normalization: TokenNormalizationOptions = .defaults,
        splitIdentifierComponents: Bool = true,
        emitWhitespaceTokens: Bool = true,
        coalesceAdjacentSeparators: Bool = true,
        wordCharactersPerToken: Int = 4,
        numberCharactersPerToken: Int = 3,
        identifierCharactersPerToken: Int = 4,
        separatorCharactersPerToken: Int = 2,
        symbolCharactersPerToken: Int = 1,
        whitespaceCharactersPerToken: Int = 24,
        whitespaceRunMinimumTokens: Int = 0,
        newlineTokenCost: Int = 1,
        lineOverheadTokenEvery: Int = 12,
        framingOverheadTokens: Int = 0,
        safetyMarginPercent: Int = 10,
        minimumTokenCount: Int = 0,
        largeInputCharacterThreshold: Int = 100_000,
        manyLinesThreshold: Int = 1_000,
        manySymbolsRatioPercent: Int = 35,
        manySeparatorsRatioPercent: Int = 45,
        longTokenCharacterThreshold: Int = 24,
        nonASCIIScalarsPerExtraToken: Int = 4,
        cjkScalarTokenCost: Int = 1,
        emojiLikeScalarTokenCost: Int = 2
    ) {
        self.mode = mode
        self.normalization = normalization
        self.splitIdentifierComponents = splitIdentifierComponents
        self.emitWhitespaceTokens = emitWhitespaceTokens
        self.coalesceAdjacentSeparators = coalesceAdjacentSeparators
        self.wordCharactersPerToken = max(1, wordCharactersPerToken)
        self.numberCharactersPerToken = max(1, numberCharactersPerToken)
        self.identifierCharactersPerToken = max(1, identifierCharactersPerToken)
        self.separatorCharactersPerToken = max(1, separatorCharactersPerToken)
        self.symbolCharactersPerToken = max(1, symbolCharactersPerToken)
        self.whitespaceCharactersPerToken = max(1, whitespaceCharactersPerToken)
        self.whitespaceRunMinimumTokens = max(0, whitespaceRunMinimumTokens)
        self.newlineTokenCost = max(0, newlineTokenCost)
        self.lineOverheadTokenEvery = max(1, lineOverheadTokenEvery)
        self.framingOverheadTokens = max(0, framingOverheadTokens)
        self.safetyMarginPercent = max(0, safetyMarginPercent)
        self.minimumTokenCount = max(0, minimumTokenCount)
        self.largeInputCharacterThreshold = max(1, largeInputCharacterThreshold)
        self.manyLinesThreshold = max(1, manyLinesThreshold)
        self.manySymbolsRatioPercent = max(1, manySymbolsRatioPercent)
        self.manySeparatorsRatioPercent = max(1, manySeparatorsRatioPercent)
        self.longTokenCharacterThreshold = max(1, longTokenCharacterThreshold)
        self.nonASCIIScalarsPerExtraToken = max(1, nonASCIIScalarsPerExtraToken)
        self.cjkScalarTokenCost = max(1, cjkScalarTokenCost)
        self.emojiLikeScalarTokenCost = max(1, emojiLikeScalarTokenCost)
    }

    public static let fast: Self = .init(
        mode: .fast,
        splitIdentifierComponents: false,
        emitWhitespaceTokens: false,
        coalesceAdjacentSeparators: true,
        wordCharactersPerToken: 4,
        numberCharactersPerToken: 4,
        identifierCharactersPerToken: 4,
        separatorCharactersPerToken: 4,
        symbolCharactersPerToken: 2,
        whitespaceCharactersPerToken: 64,
        whitespaceRunMinimumTokens: 0,
        newlineTokenCost: 0,
        lineOverheadTokenEvery: 40,
        framingOverheadTokens: 0,
        safetyMarginPercent: 8
    )

    public static let balanced: Self = .init(
        mode: .balanced,
        splitIdentifierComponents: true,
        emitWhitespaceTokens: true,
        coalesceAdjacentSeparators: true,
        wordCharactersPerToken: 4,
        numberCharactersPerToken: 3,
        identifierCharactersPerToken: 4,
        separatorCharactersPerToken: 2,
        symbolCharactersPerToken: 1,
        whitespaceCharactersPerToken: 24,
        whitespaceRunMinimumTokens: 0,
        newlineTokenCost: 1,
        lineOverheadTokenEvery: 12,
        framingOverheadTokens: 0,
        safetyMarginPercent: 10
    )

    public static let conservative: Self = .init(
        mode: .conservative,
        splitIdentifierComponents: true,
        emitWhitespaceTokens: true,
        coalesceAdjacentSeparators: true,
        wordCharactersPerToken: 4,
        numberCharactersPerToken: 3,
        identifierCharactersPerToken: 3,
        separatorCharactersPerToken: 1,
        symbolCharactersPerToken: 1,
        whitespaceCharactersPerToken: 12,
        whitespaceRunMinimumTokens: 1,
        newlineTokenCost: 1,
        lineOverheadTokenEvery: 8,
        framingOverheadTokens: 0,
        safetyMarginPercent: 18
    )

    public static let agenticContext: Self = .init(
        mode: .conservative,
        splitIdentifierComponents: true,
        emitWhitespaceTokens: true,
        coalesceAdjacentSeparators: true,
        wordCharactersPerToken: 4,
        numberCharactersPerToken: 3,
        identifierCharactersPerToken: 3,
        separatorCharactersPerToken: 1,
        symbolCharactersPerToken: 1,
        whitespaceCharactersPerToken: 12,
        whitespaceRunMinimumTokens: 1,
        newlineTokenCost: 1,
        lineOverheadTokenEvery: 8,
        framingOverheadTokens: 12,
        safetyMarginPercent: 22
    )

    public static let defaults: Self = .balanced
}
