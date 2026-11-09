import Position

/// A lossless lexical segment with UTF-8 offsets into the exact source string.
public struct TokenBoundary: Sendable, Hashable {
    public let kind: TextTokenKind
    public let rawValue: String
    public let utf8: Range<Position.Offset<Position.Unit.UTF8>>

    public func coordinates(in source: String) throws -> Position.CoordinateRange<Position.Unit.UTF8> {
        let map = Position.TextMap(source: source)
        return try .init(
            start: map.coordinate(at: utf8.lowerBound),
            end: map.coordinate(at: utf8.upperBound)
        )
    }
}

public enum TokenBoundaries {
    public enum Failure: Error, Sendable {
        case invalidCoverage
    }

    /// Emits every source Character, including whitespace and punctuation.
    /// The existing TextTokenizer's Character offsets are converted explicitly.
    public static func lexical(_ source: String) throws -> [TokenBoundary] {
        let characters = Array(source)
        var offsets = [Int](repeating: 0, count: characters.count + 1)
        for index in characters.indices {
            offsets[index + 1] = offsets[index] + String(characters[index]).utf8.count
        }
        let tokens = TextTokenizer.tokenize(source, options: .init(
            emission: .init(separators: true, whitespace: true),
            coalesceAdjacentSeparators: true
        ))
        var cursor = 0
        let segments: [TokenBoundary] = try tokens.map { token in
            let range = token.offsetRange
            guard range.startoffset == cursor,
                  range.endoffset <= characters.count,
                  range.endoffset > range.startoffset else {
                throw Failure.invalidCoverage
            }
            cursor = range.endoffset
            let start = try Position.Offset<Position.Unit.UTF8>(offsets[range.startoffset])
            let end = try Position.Offset<Position.Unit.UTF8>(offsets[range.endoffset])
            return .init(kind: token.kind, rawValue: token.rawValue, utf8: start..<end)
        }
        guard cursor == characters.count else { throw Failure.invalidCoverage }
        return segments
    }
}
