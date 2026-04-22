import Foundation

public struct IdentifierTokenizationOptions: Sendable, Codable, Hashable {
    public var normalization: TokenNormalizationOptions
    public var splitOnCaseTransitions: Bool
    public var splitOnDigitTransitions: Bool
    public var separators: Set<Character>
    public var namespace: String?

    public init(
        normalization: TokenNormalizationOptions = .defaults,
        splitOnCaseTransitions: Bool = true,
        splitOnDigitTransitions: Bool = true,
        separators: Set<Character> = ["_", "-", ".", "/", ":"],
        namespace: String? = "identifier"
    ) {
        self.normalization = normalization
        self.splitOnCaseTransitions = splitOnCaseTransitions
        self.splitOnDigitTransitions = splitOnDigitTransitions
        self.separators = separators
        self.namespace = namespace
    }

    public static let defaults: Self = .init()
}

extension IdentifierTokenizationOptions {
    enum CodingKeys: String, CodingKey {
        case normalization
        case splitOnCaseTransitions
        case splitOnDigitTransitions
        case separators
        case namespace
    }

    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.normalization = try container.decode(
            TokenNormalizationOptions.self,
            forKey: .normalization
        )

        self.splitOnCaseTransitions = try container.decode(
            Bool.self,
            forKey: .splitOnCaseTransitions
        )

        self.splitOnDigitTransitions = try container.decode(
            Bool.self,
            forKey: .splitOnDigitTransitions
        )

        let separatorStrings = try container.decode(
            [String].self,
            forKey: .separators
        )

        self.separators = Set(
            separatorStrings.compactMap(\.first)
        )

        self.namespace = try container.decodeIfPresent(
            String.self,
            forKey: .namespace
        )
    }

    public func encode(
        to encoder: any Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(
            normalization,
            forKey: .normalization
        )

        try container.encode(
            splitOnCaseTransitions,
            forKey: .splitOnCaseTransitions
        )

        try container.encode(
            splitOnDigitTransitions,
            forKey: .splitOnDigitTransitions
        )

        try container.encode(
            separators
                .map(String.init)
                .sorted(),
            forKey: .separators
        )

        try container.encodeIfPresent(
            namespace,
            forKey: .namespace
        )
    }
}

public enum IdentifierTokenizer {
    public static func tokenize(
        _ identifier: String,
        options: IdentifierTokenizationOptions = .defaults,
        source: String? = nil
    ) -> [TextToken] {
        let characters = Array(identifier)
        var tokens: [TextToken] = []

        var current: [Character] = []
        var currentStart: Int?

        func flush(
            endoffset: Int
        ) {
            guard let start = currentStart, !current.isEmpty else {
                return
            }

            let raw = String(current)

            tokens.append(
                TextToken(
                    identifier: TokenIdentifier(
                        namespace: options.namespace,
                        source: source,
                        ordinal: tokens.count
                    ),
                    kind: .identifiercomponent,
                    rawValue: raw,
                    normalizedValue: TokenNormalizer.normalizeToken(
                        raw,
                        options: options.normalization
                    ),
                    offsetRange: TokenOffsetRange(
                        uncheckedStart: start,
                        uncheckedEnd: endoffset
                    )
                )
            )

            current.removeAll(keepingCapacity: true)
            currentStart = nil
        }

        for offset in characters.indices {
            let character = characters[offset]

            if options.separators.contains(character) || character.isWhitespace {
                flush(endoffset: offset)
                continue
            }

            if current.isEmpty {
                currentStart = offset
                current.append(character)
                continue
            }

            let previous = current.last!

            let splitForDigitTransition =
                options.splitOnDigitTransitions
                && (isDigit(previous) != isDigit(character))

            let splitForLowerToUpper =
                options.splitOnCaseTransitions
                && isLowercaseLetter(previous)
                && isUppercaseLetter(character)

            if splitForDigitTransition || splitForLowerToUpper {
                flush(endoffset: offset)
                currentStart = offset
                current.append(character)
                continue
            }

            let splitForAcronymTail =
                options.splitOnCaseTransitions
                && isUppercaseLetter(previous)
                && isLowercaseLetter(character)
                && current.count > 1
                && current.allSatisfy {
                    isUppercaseLetter($0) || isDigit($0)
                }

            if splitForAcronymTail {
                let carried = current.removeLast()
                flush(endoffset: offset - 1)
                currentStart = offset - 1
                current = [carried, character]
                continue
            }

            current.append(character)
        }

        flush(endoffset: characters.count)

        return tokens
    }
}

public enum AcronymExtractor {
    public static func string(
        from tokens: [TextToken],
        uppercased: Bool = true
    ) -> String {
        let scalar = tokens.compactMap { token in
            token.rawValue.first
        }

        let value = String(scalar)

        if uppercased {
            return value.uppercased()
        }

        return value
    }

    public static func token(
        from tokens: [TextToken],
        source: String? = nil,
        namespace: String? = "acronym",
        uppercased: Bool = true
    ) -> TextToken? {
        guard
            let first = tokens.first,
            let last = tokens.last
        else {
            return nil
        }

        let raw = string(
            from: tokens,
            uppercased: uppercased
        )

        guard !raw.isEmpty else {
            return nil
        }

        return TextToken(
            identifier: TokenIdentifier(
                namespace: namespace,
                source: source,
                ordinal: 0
            ),
            kind: .acronym,
            rawValue: raw,
            normalizedValue: raw,
            offsetRange: TokenOffsetRange(
                uncheckedStart: first.offsetRange.startoffset,
                uncheckedEnd: last.offsetRange.endoffset
            )
        )
    }
}

private func isDigit(
    _ character: Character
) -> Bool {
    character.unicodeScalars.allSatisfy {
        $0.properties.numericType != nil
    }
}

private func isUppercaseLetter(
    _ character: Character
) -> Bool {
    let string = String(character)
    return string == string.uppercased() && string != string.lowercased()
}

private func isLowercaseLetter(
    _ character: Character
) -> Bool {
    let string = String(character)
    return string == string.lowercased() && string != string.uppercased()
}
