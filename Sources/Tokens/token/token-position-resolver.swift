import Position

public struct TokenResolvedLineRange: Sendable, Hashable {
    public let identifier: TokenIdentifier
    public let offsetRange: TokenOffsetRange
    public let lineRange: LineRange

    public init(
        identifier: TokenIdentifier,
        offsetRange: TokenOffsetRange,
        lineRange: LineRange
    ) {
        self.identifier = identifier
        self.offsetRange = offsetRange
        self.lineRange = lineRange
    }
}

public enum TokenPositionResolver {
    public static func lineRange(
        for range: TokenOffsetRange,
        in text: String
    ) -> LineRange {
        let lineTable = LineTable(text: text)

        let start = lineTable.lineAndColumn(
            at: range.startoffset
        )

        let inclusiveEndOffset = range.isEmpty
            ? range.startoffset
            : max(
                range.startoffset,
                range.endoffset - 1
            )

        let end = lineTable.lineAndColumn(
            at: inclusiveEndOffset
        )

        return LineRange(
            uncheckedStart: start.line,
            uncheckedEnd: end.line
        )
    }

    public static func lineRange<T: TokenProtocol>(
        for token: T,
        in text: String
    ) -> TokenResolvedLineRange {
        TokenResolvedLineRange(
            identifier: token.identifier,
            offsetRange: token.offsetRange,
            lineRange: lineRange(
                for: token.offsetRange,
                in: text
            )
        )
    }

    public static func lineRanges<T: TokenProtocol>(
        for tokens: [T],
        in text: String
    ) -> [TokenResolvedLineRange] {
        tokens.map {
            lineRange(
                for: $0,
                in: text
            )
        }
    }
}
