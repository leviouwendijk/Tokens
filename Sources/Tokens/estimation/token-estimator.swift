import Foundation

public enum TokenEstimator {
    public static func estimate(
        _ text: String,
        options: TokenEstimationOptions = .conservative,
        source: String? = nil
    ) -> TokenEstimate {
        switch options.mode {
        case .fast:
            return fastEstimate(
                text,
                options: options
            )

        case .balanced, .conservative:
            return detailedEstimate(
                text,
                options: options,
                source: source
            )
        }
    }
}

private extension TokenEstimator {
    struct ScalarProfile {
        var nonASCII: Int = 0
        var cjk: Int = 0
        var emojiLike: Int = 0
    }

    struct TokenContribution {
        var tokens: Int
        var unicodePenaltyTokens: Int
        var profile: ScalarProfile
        var identifierComponentCount: Int
        var longTokenCount: Int
    }

    static func fastEstimate(
        _ text: String,
        options: TokenEstimationOptions
    ) -> TokenEstimate {
        let characterCount = text.count
        let scalarCount = text.unicodeScalars.count
        let lineCount = countLines(
            in: text
        )
        let profile = scalarProfile(
            in: text
        )

        var breakdown = TokenEstimateBreakdown(
            nonASCIIScalarCount: profile.nonASCII,
            cjkScalarCount: profile.cjk,
            emojiLikeScalarCount: profile.emojiLike
        )

        if text.isEmpty {
            return TokenEstimate(
                estimatedTokens: 0,
                baseTokens: 0,
                overheadTokens: 0,
                marginTokens: 0,
                characterCount: 0,
                scalarCount: 0,
                lineCount: 0,
                textTokenCount: 0,
                breakdown: breakdown,
                confidence: .rough,
                diagnostics: [
                    .init(
                        kind: .emptyInput,
                        message: "Input is empty."
                    )
                ]
            )
        }

        var baseTokens = ceilDivide(
            characterCount,
            by: options.wordCharactersPerToken
        )

        if profile.cjk > 0 {
            baseTokens = max(
                baseTokens,
                profile.cjk * options.cjkScalarTokenCost
            )
        }

        let unicodePenalty = unicodePenaltyTokens(
            for: profile,
            options: options
        )

        breakdown.unicodePenaltyTokens = unicodePenalty
        baseTokens += unicodePenalty

        let overheadTokens = overheadTokens(
            lineCount: lineCount,
            options: options
        )
        let marginTokens = marginTokens(
            for: baseTokens + overheadTokens,
            options: options
        )
        let estimatedTokens = normalizedEstimatedTokens(
            baseTokens: baseTokens,
            overheadTokens: overheadTokens,
            marginTokens: marginTokens,
            options: options,
            isEmpty: text.isEmpty
        )

        let diagnostics = diagnostics(
            text: text,
            lineCount: lineCount,
            textTokenCount: 0,
            breakdown: breakdown,
            baseTokens: baseTokens,
            overheadTokens: overheadTokens,
            options: options
        )

        return TokenEstimate(
            estimatedTokens: estimatedTokens,
            baseTokens: baseTokens,
            overheadTokens: overheadTokens,
            marginTokens: marginTokens,
            characterCount: characterCount,
            scalarCount: scalarCount,
            lineCount: lineCount,
            textTokenCount: 0,
            breakdown: breakdown,
            confidence: .rough,
            diagnostics: diagnostics
        )
    }

    static func detailedEstimate(
        _ text: String,
        options: TokenEstimationOptions,
        source: String?
    ) -> TokenEstimate {
        let characterCount = text.count
        let scalarCount = text.unicodeScalars.count
        let lineCount = countLines(
            in: text
        )

        if text.isEmpty {
            return TokenEstimate(
                estimatedTokens: 0,
                baseTokens: 0,
                overheadTokens: 0,
                marginTokens: 0,
                characterCount: 0,
                scalarCount: 0,
                lineCount: 0,
                textTokenCount: 0,
                breakdown: .init(),
                confidence: confidence(
                    for: options
                ),
                diagnostics: [
                    .init(
                        kind: .emptyInput,
                        message: "Input is empty."
                    )
                ]
            )
        }

        let tokens = TextTokenizer.tokenize(
            text,
            options: .init(
                normalization: options.normalization,
                emission: .init(
                    separators: true,
                    whitespace: options.emitWhitespaceTokens
                ),
                coalesceAdjacentSeparators: options.coalesceAdjacentSeparators,
                classifyNumbers: true,
                namespace: "estimate"
            ),
            source: source
        )

        var breakdown = TokenEstimateBreakdown()
        var baseTokens = 0

        for token in tokens {
            let contribution = tokenContribution(
                token,
                options: options,
                source: source
            )

            baseTokens += contribution.tokens
            breakdown.unicodePenaltyTokens += contribution.unicodePenaltyTokens
            breakdown.nonASCIIScalarCount += contribution.profile.nonASCII
            breakdown.cjkScalarCount += contribution.profile.cjk
            breakdown.emojiLikeScalarCount += contribution.profile.emojiLike
            breakdown.identifierComponentCount += contribution.identifierComponentCount
            breakdown.longTokenCount += contribution.longTokenCount

            switch token.kind {
            case .word, .queryterm, .acronym:
                breakdown.wordCount += 1
                breakdown.wordTokens += contribution.tokens

            case .identifiercomponent:
                breakdown.identifierComponentCount += 1
                breakdown.identifierComponentTokens += contribution.tokens

            case .number:
                breakdown.numberCount += 1
                breakdown.numberTokens += contribution.tokens

            case .symbol:
                breakdown.symbolCount += 1
                breakdown.symbolTokens += contribution.tokens

            case .separator:
                if isWhitespaceOnly(
                    token.rawValue
                ) {
                    breakdown.whitespaceCount += 1
                    breakdown.whitespaceTokens += contribution.tokens
                } else {
                    breakdown.separatorCount += 1
                    breakdown.separatorTokens += contribution.tokens
                }
            }
        }

        let overheadTokens = overheadTokens(
            lineCount: lineCount,
            options: options
        )
        let marginTokens = marginTokens(
            for: baseTokens + overheadTokens,
            options: options
        )
        let estimatedTokens = normalizedEstimatedTokens(
            baseTokens: baseTokens,
            overheadTokens: overheadTokens,
            marginTokens: marginTokens,
            options: options,
            isEmpty: text.isEmpty
        )

        let diagnostics = diagnostics(
            text: text,
            lineCount: lineCount,
            textTokenCount: tokens.count,
            breakdown: breakdown,
            baseTokens: baseTokens,
            overheadTokens: overheadTokens,
            options: options
        )

        return TokenEstimate(
            estimatedTokens: estimatedTokens,
            baseTokens: baseTokens,
            overheadTokens: overheadTokens,
            marginTokens: marginTokens,
            characterCount: characterCount,
            scalarCount: scalarCount,
            lineCount: lineCount,
            textTokenCount: tokens.count,
            breakdown: breakdown,
            confidence: confidence(
                for: options
            ),
            diagnostics: diagnostics
        )
    }

    static func tokenContribution(
        _ token: TextToken,
        options: TokenEstimationOptions,
        source: String?
    ) -> TokenContribution {
        switch token.kind {
        case .word, .queryterm, .acronym, .identifiercomponent:
            return wordContribution(
                token.rawValue,
                options: options,
                source: source
            )

        case .number:
            let profile = scalarProfile(
                in: token.rawValue
            )
            return TokenContribution(
                tokens: ceilDivide(
                    token.rawValue.count,
                    by: options.numberCharactersPerToken
                ),
                unicodePenaltyTokens: 0,
                profile: profile,
                identifierComponentCount: 0,
                longTokenCount: longTokenCount(
                    token.rawValue,
                    options: options
                )
            )

        case .symbol:
            return symbolContribution(
                token.rawValue,
                options: options
            )

        case .separator:
            if isWhitespaceOnly(
                token.rawValue
            ) {
                return whitespaceContribution(
                    token.rawValue,
                    options: options
                )
            }

            return separatorContribution(
                token.rawValue,
                options: options
            )
        }
    }

    static func wordContribution(
        _ raw: String,
        options: TokenEstimationOptions,
        source: String?
    ) -> TokenContribution {
        let profile = scalarProfile(
            in: raw
        )

        let components: [TextToken]
        if options.splitIdentifierComponents {
            components = IdentifierTokenizer.tokenize(
                raw,
                options: .init(
                    normalization: options.normalization,
                    splitOnCaseTransitions: true,
                    splitOnDigitTransitions: true,
                    namespace: nil
                ),
                source: source
            )
        } else {
            components = []
        }

        var lexicalTokens: Int
        var identifierComponentCount = 0

        if components.count > 1 {
            identifierComponentCount = components.count
            lexicalTokens = components.reduce(
                0
            ) { partial, component in
                partial + lexicalTokenCount(
                    component.rawValue,
                    charactersPerToken: options.identifierCharactersPerToken
                )
            }
        } else {
            lexicalTokens = lexicalTokenCount(
                raw,
                charactersPerToken: options.wordCharactersPerToken
            )
        }

        if profile.cjk > 0 {
            lexicalTokens = max(
                lexicalTokens,
                profile.cjk * options.cjkScalarTokenCost
            )
        }

        if profile.emojiLike > 0 {
            lexicalTokens += profile.emojiLike * options.emojiLikeScalarTokenCost
        }

        let unicodePenalty = unicodePenaltyTokens(
            for: profile,
            options: options
        )

        return TokenContribution(
            tokens: lexicalTokens + unicodePenalty,
            unicodePenaltyTokens: unicodePenalty,
            profile: profile,
            identifierComponentCount: identifierComponentCount,
            longTokenCount: longTokenCount(
                raw,
                options: options
            )
        )
    }

    static func symbolContribution(
        _ raw: String,
        options: TokenEstimationOptions
    ) -> TokenContribution {
        let profile = scalarProfile(
            in: raw
        )

        var tokens = max(
            1,
            ceilDivide(
                raw.count,
                by: options.symbolCharactersPerToken
            )
        )

        if profile.emojiLike > 0 {
            tokens = max(
                tokens,
                profile.emojiLike * options.emojiLikeScalarTokenCost
            )
        }

        let unicodePenalty = unicodePenaltyTokens(
            for: profile,
            options: options
        )

        return TokenContribution(
            tokens: tokens + unicodePenalty,
            unicodePenaltyTokens: unicodePenalty,
            profile: profile,
            identifierComponentCount: 0,
            longTokenCount: longTokenCount(
                raw,
                options: options
            )
        )
    }

    static func separatorContribution(
        _ raw: String,
        options: TokenEstimationOptions
    ) -> TokenContribution {
        let profile = scalarProfile(
            in: raw
        )

        var tokens = max(
            1,
            ceilDivide(
                raw.count,
                by: options.separatorCharactersPerToken
            )
        )

        if profile.emojiLike > 0 {
            tokens = max(
                tokens,
                profile.emojiLike * options.emojiLikeScalarTokenCost
            )
        }

        let unicodePenalty = unicodePenaltyTokens(
            for: profile,
            options: options
        )

        return TokenContribution(
            tokens: tokens + unicodePenalty,
            unicodePenaltyTokens: unicodePenalty,
            profile: profile,
            identifierComponentCount: 0,
            longTokenCount: longTokenCount(
                raw,
                options: options
            )
        )
    }

    static func whitespaceContribution(
        _ raw: String,
        options: TokenEstimationOptions
    ) -> TokenContribution {
        let newlineCount = countNewlines(
            in: raw
        )
        let nonNewlineWhitespaceCount = raw.count - newlineCount

        var tokens = newlineCount * options.newlineTokenCost

        if nonNewlineWhitespaceCount > 0 {
            tokens += ceilDivide(
                nonNewlineWhitespaceCount,
                by: options.whitespaceCharactersPerToken
            )
        }

        if newlineCount == 0, !raw.isEmpty {
            tokens = max(
                tokens,
                options.whitespaceRunMinimumTokens
            )
        }

        return TokenContribution(
            tokens: tokens,
            unicodePenaltyTokens: 0,
            profile: .init(),
            identifierComponentCount: 0,
            longTokenCount: 0
        )
    }

    static func lexicalTokenCount(
        _ raw: String,
        charactersPerToken: Int
    ) -> Int {
        max(
            1,
            ceilDivide(
                raw.count,
                by: charactersPerToken
            )
        )
    }

    static func unicodePenaltyTokens(
        for profile: ScalarProfile,
        options: TokenEstimationOptions
    ) -> Int {
        let remainingNonASCII = max(
            0,
            profile.nonASCII - profile.cjk - profile.emojiLike
        )

        return ceilDivide(
            remainingNonASCII,
            by: options.nonASCIIScalarsPerExtraToken
        )
    }

    static func overheadTokens(
        lineCount: Int,
        options: TokenEstimationOptions
    ) -> Int {
        guard lineCount > 0 else {
            return options.framingOverheadTokens
        }

        return options.framingOverheadTokens
            + lineCount / options.lineOverheadTokenEvery
    }

    static func marginTokens(
        for tokens: Int,
        options: TokenEstimationOptions
    ) -> Int {
        guard tokens > 0, options.safetyMarginPercent > 0 else {
            return 0
        }

        return ceilDivide(
            tokens * options.safetyMarginPercent,
            by: 100
        )
    }

    static func normalizedEstimatedTokens(
        baseTokens: Int,
        overheadTokens: Int,
        marginTokens: Int,
        options: TokenEstimationOptions,
        isEmpty: Bool
    ) -> Int {
        guard !isEmpty else {
            return 0
        }

        return max(
            options.minimumTokenCount,
            baseTokens + overheadTokens + marginTokens
        )
    }

    static func confidence(
        for options: TokenEstimationOptions
    ) -> TokenEstimateConfidence {
        switch options.mode {
        case .fast:
            return .rough

        case .balanced:
            return .estimated

        case .conservative:
            return .conservative
        }
    }

    static func diagnostics(
        text: String,
        lineCount: Int,
        textTokenCount: Int,
        breakdown: TokenEstimateBreakdown,
        baseTokens: Int,
        overheadTokens: Int,
        options: TokenEstimationOptions
    ) -> [TokenEstimateDiagnostic] {
        var diagnostics: [TokenEstimateDiagnostic] = []

        if text.isEmpty {
            diagnostics.append(
                .init(
                    kind: .emptyInput,
                    message: "Input is empty."
                )
            )
        }

        if text.count >= options.largeInputCharacterThreshold {
            diagnostics.append(
                .init(
                    kind: .largeInput,
                    severity: .warning,
                    message: "Input is large enough that provider-specific tokenizer differences may become significant."
                )
            )
        }

        if lineCount >= options.manyLinesThreshold {
            diagnostics.append(
                .init(
                    kind: .manyLines,
                    severity: .warning,
                    message: "Input contains many lines; line framing and context delimiters may increase provider-side token use."
                )
            )
        }

        let structuralTokenCount = breakdown.wordCount
            + breakdown.numberCount
            + breakdown.symbolCount
            + breakdown.separatorCount
            + breakdown.whitespaceCount

        if structuralTokenCount > 0,
           breakdown.symbolCount * 100 >= structuralTokenCount * options.manySymbolsRatioPercent {
            diagnostics.append(
                .init(
                    kind: .manySymbols,
                    severity: .warning,
                    message: "Input has a high symbol ratio; code, JSON, and punctuation-heavy content usually tokenize denser than prose."
                )
            )
        }

        if structuralTokenCount > 0,
           breakdown.separatorCount * 100 >= structuralTokenCount * options.manySeparatorsRatioPercent {
            diagnostics.append(
                .init(
                    kind: .manySeparators,
                    severity: .warning,
                    message: "Input has many separator runs; structured data may tokenize denser than prose."
                )
            )
        }

        if breakdown.longTokenCount > 0 {
            diagnostics.append(
                .init(
                    kind: .longTokenRuns,
                    message: "Input contains long alphanumeric runs or identifiers.",
                    tokenImpact: breakdown.longTokenCount
                )
            )
        }

        if breakdown.nonASCIIScalarCount > 0 {
            diagnostics.append(
                .init(
                    kind: .nonASCIIContent,
                    message: "Input contains non-ASCII content; estimate includes an extra conservative Unicode penalty.",
                    tokenImpact: breakdown.unicodePenaltyTokens
                )
            )
        }

        if breakdown.cjkScalarCount > 0 {
            diagnostics.append(
                .init(
                    kind: .cjkContent,
                    severity: .warning,
                    message: "Input contains CJK scalars; these can tokenize closer to one token per scalar."
                )
            )
        }

        if breakdown.emojiLikeScalarCount > 0 {
            diagnostics.append(
                .init(
                    kind: .emojiLikeContent,
                    message: "Input contains emoji-like scalars; estimate treats them conservatively."
                )
            )
        }

        if looksCodeLike(text) {
            diagnostics.append(
                .init(
                    kind: .codeLikeContent,
                    message: "Input appears code-like; estimate uses punctuation and identifier splitting to stay conservative."
                )
            )
        }

        if looksJSONLike(text) {
            diagnostics.append(
                .init(
                    kind: .jsonLikeContent,
                    message: "Input appears JSON-like; punctuation and quoting may increase token density."
                )
            )
        }

        if looksMarkdownLike(text) {
            diagnostics.append(
                .init(
                    kind: .markdownLikeContent,
                    message: "Input appears Markdown-like; headings, lists, links, or code fences may affect token density."
                )
            )
        }

        if baseTokens > 0,
           overheadTokens * 5 >= baseTokens {
            diagnostics.append(
                .init(
                    kind: .highOverhead,
                    message: "Overhead tokens are relatively high compared with lexical tokens.",
                    tokenImpact: overheadTokens
                )
            )
        }

        return diagnostics
    }

    static func scalarProfile(
        in text: String
    ) -> ScalarProfile {
        var profile = ScalarProfile()

        for scalar in text.unicodeScalars {
            if scalar.value > 0x7F {
                profile.nonASCII += 1
            }

            if isCJKScalar(
                scalar
            ) {
                profile.cjk += 1
            }

            if isEmojiLikeScalar(
                scalar
            ) {
                profile.emojiLike += 1
            }
        }

        return profile
    }

    static func isCJKScalar(
        _ scalar: Unicode.Scalar
    ) -> Bool {
        switch scalar.value {
        case 0x3400...0x4DBF,
             0x4E00...0x9FFF,
             0xF900...0xFAFF,
             0x20000...0x2A6DF,
             0x2A700...0x2B73F,
             0x2B740...0x2B81F,
             0x2B820...0x2CEAF:
            return true

        default:
            return false
        }
    }

    static func isEmojiLikeScalar(
        _ scalar: Unicode.Scalar
    ) -> Bool {
        switch scalar.value {
        case 0x1F000...0x1FAFF,
             0x2600...0x27BF,
             0xFE00...0xFE0F:
            return true

        default:
            return false
        }
    }

    static func countLines(
        in text: String
    ) -> Int {
        guard !text.isEmpty else {
            return 0
        }

        return 1 + countNewlines(
            in: text
        )
    }

    static func countNewlines(
        in text: String
    ) -> Int {
        text.reduce(
            0
        ) { partial, character in
            character == "\n"
                ? partial + 1
                : partial
        }
    }

    static func isWhitespaceOnly(
        _ text: String
    ) -> Bool {
        !text.isEmpty && text.allSatisfy(\.isWhitespace)
    }

    static func longTokenCount(
        _ raw: String,
        options: TokenEstimationOptions
    ) -> Int {
        raw.count >= options.longTokenCharacterThreshold
            ? 1
            : 0
    }

    static func ceilDivide(
        _ value: Int,
        by denominator: Int
    ) -> Int {
        guard value > 0 else {
            return 0
        }

        return (value + max(1, denominator) - 1) / max(1, denominator)
    }

    static func looksCodeLike(
        _ text: String
    ) -> Bool {
        var codeSymbolCount = 0
        var visibleCount = 0

        let codeSymbols: Set<Character> = [
            "{",
            "}",
            "(",
            ")",
            "[",
            "]",
            ";",
            "=",
            "<",
            ">",
            ".",
            ":"
        ]

        for character in text {
            guard !character.isWhitespace else {
                continue
            }

            visibleCount += 1

            if codeSymbols.contains(
                character
            ) {
                codeSymbolCount += 1
            }
        }

        guard visibleCount > 0 else {
            return false
        }

        return codeSymbolCount * 100 >= visibleCount * 12
    }

    static func looksJSONLike(
        _ text: String
    ) -> Bool {
        let trimmed = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard let first = trimmed.first,
              first == "{" || first == "["
        else {
            return false
        }

        return trimmed.contains(":")
            || trimmed.contains("\"")
    }

    static func looksMarkdownLike(
        _ text: String
    ) -> Bool {
        text.contains("```")
            || text.contains("# ")
            || text.contains("## ")
            || text.contains("- ")
            || text.contains("* ")
            || text.contains("](")
    }
}
