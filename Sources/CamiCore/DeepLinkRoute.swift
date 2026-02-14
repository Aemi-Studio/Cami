import Foundation

public enum DeepLinkRoute: Equatable, Sendable {
    case eventDetail(id: String)
    case reminderDetail(id: String)
    case day(timeIntervalSinceReferenceDate: Double)
    case createEvent
    case createReminder
    case settings
    case permissions

    public var canonicalURLString: String {
        switch self {
        case .eventDetail(let id):
            "camical://event/\(id)"
        case .reminderDetail(let id):
            "camical://reminder/\(id)"
        case .day(let time):
            "camical://day?time=\(time)"
        case .createEvent:
            "camical://create/event"
        case .createReminder:
            "camical://create/reminder"
        case .settings:
            "camical://settings"
        case .permissions:
            "camical://permissions"
        }
    }

    public static func parse(_ rawValue: String) -> DeepLinkRoute? {
        guard let url = URL(string: rawValue),
              let scheme = url.scheme?.lowercased(),
              scheme == "camical" || scheme == "cami"
        else {
            return nil
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let query: [String: String] = Dictionary(
            uniqueKeysWithValues: (components?.queryItems ?? []).compactMap { item in
                guard let value = item.value else {
                    return nil
                }
                return (item.name, value)
            }
        )

        let host = components?.host?.lowercased()
        let filteredPath = url.pathComponents.filter { $0 != "/" }
        let normalizedPath = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()

        let routeToken: String = {
            if let host {
                return host
            }
            if let firstPath = filteredPath.first?.lowercased(), !firstPath.isEmpty {
                return firstPath
            }
            return normalizedPath
        }()

        switch routeToken {
        case "event":
            if let id = filteredPath.first, host != nil, !id.isEmpty {
                return .eventDetail(id: id)
            }
            if let id = query["id"], !id.isEmpty {
                return .eventDetail(id: id)
            }
            return nil

        case "reminder":
            if let id = filteredPath.first, host != nil, !id.isEmpty {
                return .reminderDetail(id: id)
            }
            if let id = query["id"], !id.isEmpty {
                return .reminderDetail(id: id)
            }
            return nil

        case "day":
            guard let time = query["time"], let value = Double(time) else {
                return nil
            }
            return .day(timeIntervalSinceReferenceDate: value)

        case "create":
            let kind = (host != nil ? filteredPath.first : query["kind"])?.lowercased()
            if kind == "reminder" {
                return .createReminder
            }
            return .createEvent

        case "settings":
            return .settings

        case "permissions":
            return .permissions

        default:
            return nil
        }
    }
}
