public enum TextTokenKind: String, Sendable, Codable, Hashable, CaseIterable {
    case word
    case number
    case separator
    case symbol
    case acronym
    case identifiercomponent
    case queryterm
}
