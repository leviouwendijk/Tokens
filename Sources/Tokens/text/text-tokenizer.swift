import Foundation

public enum TextTokenizer {
    public static func tokenize(
        _ text: String,
        options: TextTokenizationOptions = .defaults,
        source: String? = nil
    ) -> [TextToken] {
        let characters = Array(text)
        var tokens: [TextToken] = []
        var offset = 0

        while offset < characters.count {
            let character = characters[offset]

            if isAlphaNumeric(character) {
                let start = offset
                var end = offset + 1
                var digitsOnly = isDigit(character)

                while end < characters.count, isAlphaNumeric(characters[end]) {
                    digitsOnly = digitsOnly && isDigit(characters[end])
                    end += 1
                }

                let raw = String(characters[start..<end])
                let kind: TextTokenKind = if options.classifyNumbers && digitsOnly {
                    .number
                } else {
                    .word
                }

                tokens.append(
                    makeToken(
                        raw: raw,
                        kind: kind,
                        startOffset: start,
                        endOffset: end,
                        ordinal: tokens.count,
                        source: source,
                        options: options
                    )
                )

                offset = end
                continue
            }

            if character.isWhitespace {
                if options.emission.whitespace {
                    let start = offset
                    var end = offset + 1

                    if options.coalesceAdjacentSeparators {
                        while end < characters.count, characters[end].isWhitespace {
                            end += 1
                        }
                    }

                    let raw = String(characters[start..<end])

                    tokens.append(
                        makeToken(
                            raw: raw,
                            kind: .separator,
                            startOffset: start,
                            endOffset: end,
                            ordinal: tokens.count,
                            source: source,
                            options: options
                        )
                    )

                    offset = end
                    continue
                }

                offset += 1
                continue
            }

            if options.emission.separators {
                let start = offset
                var end = offset + 1

                if options.coalesceAdjacentSeparators {
                    while end < characters.count {
                        let next = characters[end]

                        guard !isAlphaNumeric(next), !next.isWhitespace else {
                            break
                        }

                        end += 1
                    }
                }

                let raw = String(characters[start..<end])
                let kind: TextTokenKind = raw.count == 1 ? .symbol : .separator

                tokens.append(
                    makeToken(
                        raw: raw,
                        kind: kind,
                        startOffset: start,
                        endOffset: end,
                        ordinal: tokens.count,
                        source: source,
                        options: options
                    )
                )

                offset = end
                continue
            }

            offset += 1
        }

        return tokens
    }
}

private extension TextTokenizer {
    static func makeToken(
        raw: String,
        kind: TextTokenKind,
        startOffset: Int,
        endOffset: Int,
        ordinal: Int,
        source: String?,
        options: TextTokenizationOptions
    ) -> TextToken {
        TextToken(
            identifier: TokenIdentifier(
                namespace: options.namespace,
                source: source,
                ordinal: ordinal
            ),
            kind: kind,
            rawValue: raw,
            normalizedValue: TokenNormalizer.normalizeToken(
                raw,
                options: options.normalization
            ),
            offsetRange: TokenOffsetRange(
                uncheckedStart: startOffset,
                uncheckedEnd: endOffset
            )
        )
    }

    static func isAlphaNumeric(
        _ character: Character
    ) -> Bool {
        character.unicodeScalars.allSatisfy {
            CharacterSet.alphanumerics.contains($0)
        }
    }

    static func isDigit(
        _ character: Character
    ) -> Bool {
        character.unicodeScalars.allSatisfy {
            CharacterSet.decimalDigits.contains($0)
        }
    }
}
