import Testing
@testable import WCPSSAlerts

@Suite("WCPSS Alerts Tests")
struct WCPSSAlertsTests {

    @Test("District enum has all expected cases")
    func districtCases() {
        let allDistricts = District.allCases
        #expect(allDistricts.count == 6)
        #expect(allDistricts.contains(.wcpss))
        #expect(allDistricts.contains(.dps))
    }

    @Test("Closure status has display names")
    func closureStatusDisplayNames() {
        #expect(ClosureStatus.open.displayName == "Open")
        #expect(ClosureStatus.delay2hr.displayName == "2-Hour Delay")
        #expect(ClosureStatus.closed.displayName == "Closed")
    }

    @Test("Color tokens generate probability colors")
    func probabilityColors() {
        // Low probability should be green-ish
        let lowColor = ColorTokens.probabilityColor(10)
        #expect(lowColor == ColorTokens.success)

        // High probability should be red-ish
        let highColor = ColorTokens.probabilityColor(90)
        #expect(highColor == ColorTokens.error)
    }
}

@Suite("Prediction Change Detection Tests")
struct PredictionChangeDetectionTests {

    private func makePrediction(
        probability: Int = 50,
        recommendation: ClosureStatus = .open,
        confidence: ConfidenceLevel = .medium
    ) -> ClosurePrediction {
        ClosurePrediction(
            probability: probability,
            recommendation: recommendation,
            confidence: confidence,
            factors: PredictionFactors(
                temperature: 32,
                snowfall: 2.0,
                windSpeed: "10 mph",
                iceRisk: "low",
                precipitation: 0.5,
                visibility: 5.0,
                roadConditions: "wet"
            ),
            reasoning: ["Test reason"],
            criticalTimeWindow: nil,
            lastUpdated: Date()
        )
    }

    @Test("Detects significant probability change")
    func significantProbabilityChange() {
        let oldPrediction = makePrediction(probability: 30)
        let newPrediction = makePrediction(probability: 50) // 20 point change

        #expect(newPrediction.hasSignificantChange(from: oldPrediction) == true)
    }

    @Test("Ignores minor probability change")
    func minorProbabilityChange() {
        let oldPrediction = makePrediction(probability: 30)
        let newPrediction = makePrediction(probability: 35) // 5 point change

        #expect(newPrediction.hasSignificantChange(from: oldPrediction) == false)
    }

    @Test("Detects status change")
    func statusChange() {
        let oldPrediction = makePrediction(recommendation: .open)
        let newPrediction = makePrediction(recommendation: .delay2hr)

        #expect(newPrediction.hasSignificantChange(from: oldPrediction) == true)
    }

    @Test("Detects confidence change")
    func confidenceChange() {
        let oldPrediction = makePrediction(confidence: .low)
        let newPrediction = makePrediction(confidence: .high)

        #expect(newPrediction.hasSignificantChange(from: oldPrediction) == true)
    }

    @Test("First prediction is always significant")
    func firstPredictionIsSignificant() {
        let prediction = makePrediction()
        #expect(prediction.hasSignificantChange(from: nil) == true)
    }

    @Test("shouldNotify returns true for elevated probability")
    func shouldNotifyElevatedProbability() {
        let prediction = makePrediction(probability: 45, recommendation: .open)
        #expect(prediction.shouldNotify == true)
    }

    @Test("shouldNotify returns true for non-open status")
    func shouldNotifyNonOpenStatus() {
        let prediction = makePrediction(probability: 20, recommendation: .closed)
        #expect(prediction.shouldNotify == true)
    }

    @Test("shouldNotify returns false for low probability and open")
    func shouldNotifyLowProbabilityOpen() {
        let prediction = makePrediction(probability: 20, recommendation: .open)
        #expect(prediction.shouldNotify == false)
    }
}

@Suite("Alert Change Detection Tests")
struct AlertChangeDetectionTests {

    private func makeAlert(
        status: ClosureStatus = .open,
        probability: Int = 50
    ) -> ClosureAlert {
        ClosureAlert(
            id: "test-\(UUID().uuidString)",
            district: .wcpss,
            status: status,
            probability: probability,
            confidence: .medium,
            title: "Test Alert",
            description: "Test description",
            reasoning: ["Test reason"],
            criticalWindow: nil,
            weatherFactors: ClosureAlert.WeatherFactors(
                temperature: 32,
                snowfall: 2.0,
                windSpeed: 10.0,
                iceRisk: .low,
                precipitation: 0.5
            ),
            timestamp: Date()
        )
    }

    @Test("Detects significant alert probability change")
    func significantAlertProbabilityChange() {
        let oldAlert = makeAlert(probability: 30)
        let newAlert = makeAlert(probability: 50)

        #expect(newAlert.hasSignificantChange(from: oldAlert) == true)
    }

    @Test("Detects alert status change")
    func alertStatusChange() {
        let oldAlert = makeAlert(status: .open)
        let newAlert = makeAlert(status: .closed)

        #expect(newAlert.hasSignificantChange(from: oldAlert) == true)
    }

    @Test("First alert is always significant")
    func firstAlertIsSignificant() {
        let alert = makeAlert()
        #expect(alert.hasSignificantChange(from: nil) == true)
    }
}
