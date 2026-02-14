import CamiCore
import Testing

struct DeepLinkRouteTests {
    @Test("Parses canonical event URL")
    func parsesCanonicalEventURL() {
        let route = DeepLinkRoute.parse("camical://event/abc-123")
        #expect(route == .eventDetail(id: "abc-123"))
    }

    @Test("Parses legacy event URL")
    func parsesLegacyEventURL() {
        let route = DeepLinkRoute.parse("camical:event?id=abc-123")
        #expect(route == .eventDetail(id: "abc-123"))
    }

    @Test("Parses day URL")
    func parsesDayURL() {
        let route = DeepLinkRoute.parse("camical://day?time=1234")
        #expect(route == .day(timeIntervalSinceReferenceDate: 1234))
    }

    @Test("Rejects invalid URL")
    func rejectsInvalidURL() {
        let route = DeepLinkRoute.parse("https://example.com")
        #expect(route == nil)
    }

    @Test("Builds canonical URL")
    func buildsCanonicalURL() {
        let route = DeepLinkRoute.reminderDetail(id: "r-42")
        #expect(route.canonicalURLString == "camical://reminder/r-42")
    }
}
