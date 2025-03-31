//
//  Router.swift
//  Stations
//
//  Created by Guillaume Coquard on 12/05/24.
//

import Foundation
import SwiftUI

final class Router: Loggable {
    static let shared = Router()

    private let scheme = "camical"
    private var routes: [String: ([String: String]) -> Void] = [:]

    private init() {
        routes.updateValue({ parameters in
            guard let id = parameters["id"] else {
                self.log.error("Missing 'id' parameter for event")
                return
            }
            Task { @MainActor in
                DataContext.shared.openCalendarEvent(withId: id)
            }
        }, forKey: "event")

        routes.updateValue({ parameters in
            guard let time = parameters["time"] else {
                self.log.error("Missing 'time' parameter for event")
                return
            }
            Task { @MainActor in
                DataContext.shared.openCalendarDay(atTime: time)
            }
        }, forKey: "day")

        routes.updateValue({ _ in
            ModalSheetContext.shared.open(modal: .new())
        }, forKey: "create")
    }

    func addRoute(_ path: String, handler: @escaping ([String: String]) -> Void) {
        if routes[path] != nil {
            routes[path] = handler
        }
    }

    func handleURL(_ url: URL) {
        guard url.scheme == scheme else {
            UIApplication.shared.open(url)
            return
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let path = components?.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) else {
            print(RouterError.invalidURL)
            return
        }

        guard let handler = routes[path] else {
            log.error("No handler found for path: \(path)")
            return
        }

        var parameters: [String: String] = [:]
        components?.queryItems?.forEach { item in
            if let value = item.value {
                parameters[item.name] = value
            }
        }

        handler(parameters)
    }
}
