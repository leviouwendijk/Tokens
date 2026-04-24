public enum TokenBudgetStatus: String, Sendable, Codable, Hashable, CaseIterable {
    case fits
    case nearLimit
    case overLimit
}
