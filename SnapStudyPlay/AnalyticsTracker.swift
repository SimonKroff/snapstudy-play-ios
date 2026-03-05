import Foundation
import os.log

struct AnalyticsEvent: Codable {
    let name: String
    let timestamp: Date
    let metadata: [String: String]
}

struct AnalyticsTracker {
    private let logger = Logger(subsystem: "no.snapstudy.play", category: "analytics")
    private let defaults: UserDefaults
    private let eventsKey = "analytics.events.v1"
    private let maxEvents = 250

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func track(_ name: String, metadata: [String: String] = [:]) {
        logger.info("event=\(name, privacy: .public)")
        var events = loadEvents()
        events.append(AnalyticsEvent(name: name, timestamp: Date(), metadata: metadata))
        if events.count > maxEvents {
            events = Array(events.suffix(maxEvents))
        }
        guard let data = try? JSONEncoder().encode(events) else { return }
        defaults.set(data, forKey: eventsKey)
    }

    func loadEvents() -> [AnalyticsEvent] {
        guard let data = defaults.data(forKey: eventsKey),
              let events = try? JSONDecoder().decode([AnalyticsEvent].self, from: data) else {
            return []
        }
        return events
    }
}
