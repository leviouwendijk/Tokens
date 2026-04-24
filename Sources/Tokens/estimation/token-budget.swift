public struct TokenBudget: Sendable, Codable, Hashable {
    public var maximumTokens: Int
    public var reservedTokens: Int
    public var warningThresholdPercent: Int

    public init(
        maximumTokens: Int,
        reservedTokens: Int = 0,
        warningThresholdPercent: Int = 85
    ) {
        self.maximumTokens = max(0, maximumTokens)
        self.reservedTokens = max(0, reservedTokens)
        self.warningThresholdPercent = min(
            100,
            max(
                1,
                warningThresholdPercent
            )
        )
    }

    public var usableInputTokens: Int {
        max(
            0,
            maximumTokens - reservedTokens
        )
    }

    public func evaluate(
        _ estimate: TokenEstimate
    ) -> TokenBudgetResult {
        let usable = usableInputTokens
        let remaining = usable - estimate.estimatedTokens
        let overage = max(
            0,
            -remaining
        )

        let warningThreshold = usable * warningThresholdPercent / 100

        let status: TokenBudgetStatus
        if estimate.estimatedTokens > usable {
            status = .overLimit
        } else if estimate.estimatedTokens >= warningThreshold {
            status = .nearLimit
        } else {
            status = .fits
        }

        return TokenBudgetResult(
            budget: self,
            estimate: estimate,
            status: status,
            usableInputTokens: usable,
            remainingTokens: remaining,
            overageTokens: overage
        )
    }
}
