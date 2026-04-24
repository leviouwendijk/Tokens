public enum TokenEstimateDiagnosticSeverity: String, Sendable, Codable, Hashable, CaseIterable {
    case info
    case warning
}

public enum TokenEstimateDiagnosticKind: String, Sendable, Codable, Hashable, CaseIterable {
    case emptyInput
    case largeInput
    case manyLines
    case manySymbols
    case manySeparators
    case longTokenRuns
    case nonASCIIContent
    case cjkContent
    case emojiLikeContent
    case codeLikeContent
    case jsonLikeContent
    case markdownLikeContent
    case highOverhead
}

public struct TokenEstimateDiagnostic: Sendable, Codable, Hashable {
    public var kind: TokenEstimateDiagnosticKind
    public var severity: TokenEstimateDiagnosticSeverity
    public var message: String
    public var tokenImpact: Int?

    public init(
        kind: TokenEstimateDiagnosticKind,
        severity: TokenEstimateDiagnosticSeverity = .info,
        message: String,
        tokenImpact: Int? = nil
    ) {
        self.kind = kind
        self.severity = severity
        self.message = message
        self.tokenImpact = tokenImpact
    }
}
