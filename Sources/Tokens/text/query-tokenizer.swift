public enum QueryTokenizer {
    public static func normalized(
        _ query: String,
        normalization: TokenNormalizationOptions = .defaults
    ) -> String {
        TokenNormalizer.normalize(
            query,
            options: normalization
        )
    }

    public static func tokenize(
        _ query: String,
        normalization: TokenNormalizationOptions = .defaults,
        source: String? = nil
    ) -> [TextToken] {
        TextTokenizer.tokenize(
            query,
            options: .init(
                normalization: normalization,
                emission: .init(
                    separators: false,
                    whitespace: false,
                ),
                coalesceAdjacentSeparators: true,
                classifyNumbers: true,
                namespace: "query"
            ),
            source: source
        )
        .map { $0.withKind(.queryterm) }
    }
}
