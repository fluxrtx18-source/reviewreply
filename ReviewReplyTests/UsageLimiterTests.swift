import Testing
import Foundation
@testable import ReviewReply

// MARK: - UsageLimiter Tests

@Suite("UsageLimiter", .serialized)
@MainActor
struct UsageLimiterTests {

    private let key = "com.reviewreply.lastFreeReplyDate"

    /// Returns the defaults instance that UsageLimiter uses (shared group or .standard fallback).
    private var defaults: UserDefaults {
        UserDefaults(suiteName: UserDefaultsKeys.sharedGroupID) ?? .standard
    }

    init() {
        // Clean state before each test
        let d = UserDefaults(suiteName: UserDefaultsKeys.sharedGroupID) ?? .standard
        d.removeObject(forKey: key)
    }

    @Test("Fresh install allows free usage")
    func freshInstallAllowsFree() {
        defaults.removeObject(forKey: key)
        #expect(UsageLimiter.canUseForFree == true)
    }

    @Test("After recording usage, free usage is blocked today")
    func afterUsageBlocked() {
        UsageLimiter.recordUsage()
        #expect(UsageLimiter.canUseForFree == false)
    }

    @Test("Usage from yesterday allows free usage today")
    func yesterdayUsageAllowsToday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        defaults.set(yesterday, forKey: key)
        #expect(UsageLimiter.canUseForFree == true)
    }

    @Test("Next reset date is tomorrow midnight after recording")
    func nextResetDateIsTomorrow() {
        UsageLimiter.recordUsage()
        let reset = UsageLimiter.nextResetDate
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        #expect(reset != nil)
        if let reset {
            #expect(abs(reset.timeIntervalSince(tomorrow)) < 2, "Reset should be ~midnight tomorrow")
        }
    }

    @Test("undoUsage restores free access")
    func undoUsageRestoresFree() {
        UsageLimiter.recordUsage()
        #expect(UsageLimiter.canUseForFree == false)
        UsageLimiter.undoUsage()
        #expect(UsageLimiter.canUseForFree == true)
    }

    @Test("Next reset date is nil when no usage recorded")
    func noUsageNoReset() {
        defaults.removeObject(forKey: key)
        #expect(UsageLimiter.nextResetDate == nil)
    }

    @Test("Reset countdown returns non-empty after usage")
    func countdownAfterUsage() {
        UsageLimiter.recordUsage()
        let countdown = UsageLimiter.resetCountdown
        #expect(!countdown.isEmpty)
        #expect(countdown.contains("Resets in"))
    }

    @Test("Reset countdown returns empty when no usage")
    func countdownNoUsage() {
        defaults.removeObject(forKey: key)
        #expect(UsageLimiter.resetCountdown.isEmpty)
    }
}
