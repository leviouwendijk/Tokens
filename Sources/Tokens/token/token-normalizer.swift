import Foundation

public enum TokenNormalizer {
    public static func normalize(
        _ raw: String,
        options: TokenNormalizationOptions = .defaults
    ) -> String {
        var value = raw

        if options.whitespace.trim {
            value = value.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        }

        if options.whitespace.inner.collapse {
            value = collapseWhitespace(value)
        }

        switch options.case.sensitivity {
        case .sensitive:
            return value
        case .insensitive:
            return value.lowercased()
        }
    }

    public static func normalizeToken(
        _ raw: String,
        options: TokenNormalizationOptions = .defaults
    ) -> String {
        switch options.case.sensitivity {
        case .sensitive:
            return raw
        case .insensitive:
            return raw.lowercased()
        }
    }

    private static func collapseWhitespace(
        _ string: String
    ) -> String {
        string.split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}
