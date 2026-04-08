import Foundation

// MARK: - Daily Free Quota Tracker
// Non-premium users get 1 free reply generation per calendar day.

struct UsageLimiter: Sendable {

    private static let key = "com.reviewreply.lastFreeReplyDate"

    /// True if the user has not yet used their free reply today.
    static var canUseForFree: Bool {
        guard let last = UserDefaults.standard.object(forKey: key) as? Date else { return true }
        return !Calendar.current.isDateInToday(last)
    }

    /// Call this immediately after a successful free generation.
    static func recordUsage() {
        UserDefaults.standard.set(Date(), forKey: key)
    }

    /// Undo a recorded usage (call when generation fails so user isn't penalised).
    static func undoUsage() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// The next date/time the free quota resets (midnight of next calendar day).
    static var nextResetDate: Date? {
        guard let last = UserDefaults.standard.object(forKey: key) as? Date else { return nil }
        return Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: last))
    }

    /// Formatted string like "Resets in 4h 30m"
    static var resetCountdown: String {
        guard let reset = nextResetDate else { return "" }
        let diff = reset.timeIntervalSince(Date())
        guard diff > 0 else { return "Resets now" }
        let h = Int(diff) / 3600
        let m = (Int(diff) % 3600) / 60
        if h > 0 { return "Resets in \(h)h \(m)m" }
        return "Resets in \(m)m"
    }
}
