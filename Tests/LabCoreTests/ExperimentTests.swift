import XCTest
@testable import LabCore

final class ExperimentTests: XCTestCase {
    func testSummaryStatistics() throws {
        let s = try XCTUnwrap(Summary([2, 4, 4, 4, 5, 5, 7, 9]))
        XCTAssertEqual(s.count, 8)
        XCTAssertEqual(s.mean, 5, accuracy: 1e-9)
        XCTAssertEqual(s.standardDeviation, 2.138089935, accuracy: 1e-6)
        XCTAssertEqual(s.confidenceInterval95.lowerBound, 5 - 1.96 * 2.138089935 / 8.0.squareRoot(), accuracy: 1e-6)
        XCTAssertNil(Summary([]))
        XCTAssertNil(Summary([.nan, .infinity]))
        XCTAssertEqual(Summary([3])?.standardDeviation, 0)
    }

    func testIgnoresNonFiniteMeasurements() {
        var e = Experiment(name: "x", hypothesis: "y")
        e.record(.nan, for: "A")
        e.record(1, for: "A")
        XCTAssertEqual(e.measurements["A"], [1])
        XCTAssertEqual(e.variants, ["A"])
    }

    private func experiment(control: [Double], treatment: [Double], higherIsBetter: Bool = true) -> Experiment {
        var e = Experiment(name: "Checkout button", hypothesis: "Green converts better", higherIsBetter: higherIsBetter)
        control.forEach { e.record($0, for: "control") }
        treatment.forEach { e.record($0, for: "green") }
        return e
    }

    func testNeedsMoreData() throws {
        let e = experiment(control: [1, 2, 3], treatment: [4, 5, 6])
        XCTAssertEqual(try XCTUnwrap(e.compare(control: "control", treatment: "green")).verdict, .needsMoreData)
        XCTAssertNil(e.compare(control: "control", treatment: "missing"))
    }

    func testClearImprovementAndLift() throws {
        let control = (0..<40).map { Double(10 + $0 % 3) }   // mean 10.975
        let treatment = (0..<40).map { Double(12 + $0 % 3) } // mean 12.975
        let c = try XCTUnwrap(experiment(control: control, treatment: treatment).compare(control: "control", treatment: "green"))
        XCTAssertEqual(c.verdict, .better)
        XCTAssertEqual(try XCTUnwrap(c.liftPercent), 2 / 10.975 * 100, accuracy: 1e-9)
        XCTAssertGreaterThan(c.t, 1.96)
        // For a latency metric the same numbers are a regression.
        let latency = try XCTUnwrap(experiment(control: control, treatment: treatment, higherIsBetter: false).compare(control: "control", treatment: "green"))
        XCTAssertEqual(latency.verdict, .worse)
    }

    func testNoClearDifference() throws {
        let control = (0..<40).map { Double($0 % 10) }
        let treatment = (0..<40).map { Double(($0 + 3) % 10) }
        let c = try XCTUnwrap(experiment(control: control, treatment: treatment).compare(control: "control", treatment: "green"))
        XCTAssertEqual(c.verdict, .noClearDifference)
        XCTAssertEqual(try XCTUnwrap(c.liftPercent), 0, accuracy: 1e-9)
    }

    func testZeroControlMeanHasNoLift() throws {
        let zeros = Array(repeating: 0.0, count: 30)
        let c = try XCTUnwrap(experiment(control: zeros, treatment: zeros).compare(control: "control", treatment: "green"))
        XCTAssertNil(c.liftPercent)
        XCTAssertEqual(c.t, 0)
        XCTAssertEqual(c.verdict, .noClearDifference)
    }
}
