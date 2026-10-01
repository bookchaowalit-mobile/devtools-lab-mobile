import Foundation

public struct Summary: Equatable {
    public let count: Int
    public let mean: Double
    /// Sample standard deviation (n - 1); 0 for a single sample.
    public let standardDeviation: Double

    /// Standard error of the mean.
    public var standardError: Double { count > 0 ? standardDeviation / Double(count).squareRoot() : 0 }

    /// Normal-approximation 95% confidence interval for the mean.
    public var confidenceInterval95: ClosedRange<Double> {
        let margin = 1.96 * standardError
        return (mean - margin)...(mean + margin)
    }

    public init?(_ values: [Double]) {
        let finite = values.filter { $0.isFinite }
        guard !finite.isEmpty else { return nil }
        let n = Double(finite.count)
        let mean = finite.reduce(0, +) / n
        let variance = finite.count > 1 ? finite.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / (n - 1) : 0
        self.count = finite.count
        self.mean = mean
        self.standardDeviation = variance.squareRoot()
    }
}

public enum Verdict: Equatable {
    case needsMoreData
    case noClearDifference
    case better
    case worse
}

public struct Comparison: Equatable {
    public let control: Summary
    public let treatment: Summary
    /// Relative change of the treatment mean vs control, in percent (nil if control mean is 0).
    public let liftPercent: Double?
    /// Welch's t statistic.
    public let t: Double
    public let verdict: Verdict
}

public struct Experiment: Identifiable {
    public let id: UUID
    public var name: String
    public var hypothesis: String
    /// true when a larger metric is better (e.g. conversion), false for e.g. latency.
    public var higherIsBetter: Bool
    public private(set) var measurements: [String: [Double]] = [:]

    public init(id: UUID = UUID(), name: String, hypothesis: String, higherIsBetter: Bool = true) {
        self.id = id
        self.name = name
        self.hypothesis = hypothesis
        self.higherIsBetter = higherIsBetter
    }

    public mutating func record(_ value: Double, for variant: String) {
        guard value.isFinite else { return }
        measurements[variant, default: []].append(value)
    }

    public var variants: [String] { measurements.keys.sorted() }

    /// Compares `treatment` against `control`. Needs at least `minimumSamples`
    /// per variant; |t| >= 1.96 counts as a clear difference (≈95%, large samples).
    public func compare(control: String, treatment: String, minimumSamples: Int = 30) -> Comparison? {
        guard let c = Summary(measurements[control] ?? []), let tr = Summary(measurements[treatment] ?? []) else { return nil }
        let lift: Double? = c.mean == 0 ? nil : (tr.mean - c.mean) / abs(c.mean) * 100
        let se = (c.standardError * c.standardError + tr.standardError * tr.standardError).squareRoot()
        let t = se > 0 ? (tr.mean - c.mean) / se : 0
        let verdict: Verdict
        if c.count < minimumSamples || tr.count < minimumSamples {
            verdict = .needsMoreData
        } else if abs(t) < 1.96 {
            verdict = .noClearDifference
        } else {
            verdict = (t > 0) == higherIsBetter ? .better : .worse
        }
        return Comparison(control: c, treatment: tr, liftPercent: lift, t: t, verdict: verdict)
    }
}
