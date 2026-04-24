public struct TokenBudgetResult: Sendable, Codable, Hashable {
    public var budget: TokenBudget
    public var estimate: TokenEstimate
    public var status: TokenBudgetStatus
    public var usableInputTokens: Int
    public var remainingTokens: Int
    public var overageTokens: Int

    public init(
        budget: TokenBudget,
        estimate: TokenEstimate,
        status: TokenBudgetStatus,
        usableInputTokens: Int,
        remainingTokens: Int,
        overageTokens: Int
    ) {
        self.budget = budget
        self.estimate = estimate
        self.status = status
        self.usableInputTokens = usableInputTokens
        self.remainingTokens = remainingTokens
        self.overageTokens = overageTokens
    }

    public var fits: Bool {
        status != .overLimit
    }
}
