public enum Tokenization {}

public extension Tokenization {
    static func estimate(
        _ text: String,
        options: TokenEstimationOptions = .conservative,
        source: String? = nil
    ) -> TokenEstimate {
        TokenEstimator.estimate(
            text,
            options: options,
            source: source
        )
    }

    static func evaluate(
        _ text: String,
        budget: TokenBudget,
        options: TokenEstimationOptions = .conservative,
        source: String? = nil
    ) -> TokenBudgetResult {
        budget.evaluate(
            estimate(
                text,
                options: options,
                source: source
            )
        )
    }
}
