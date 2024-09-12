//
//  Router.swift
//  Stations
//
//  Created by Guillaume Coquard on 12/05/24.
//

import SwiftUI

import Foundation

enum RouterError: Error {
    case invalidURL
    case missingParameter(String)
}

final class Router {

    static let shared: Router = .init()

    private let scheme = "camical"
    private var routes: [String: ([String: String]) -> Void] = [:]

    private init() {
        self.routes.updateValue( { parameters in
            guard let id = parameters["id"] else {
                print("Error: Missing 'id' parameter for event")
                return
            }
            EventHelper.openCalendarEvent(withId: id)
        }, forKey: "event")

        self.routes.updateValue( { parameters in
            guard let time = parameters["time"] else {
                print("Error: Missing 'time' parameter for event")
                return
            }
            EventHelper.openCalendarDay(atTime: time)
        }, forKey: "day")
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
            print("No handler found for path: \(path)")
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
