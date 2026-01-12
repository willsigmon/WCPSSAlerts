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
