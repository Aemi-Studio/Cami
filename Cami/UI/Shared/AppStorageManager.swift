//
//  AppStorageManager.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import SwiftUI

@MainActor
final class AppStorageManager: Loggable {
    private static let jsonDecoder = JSONDecoder()
    private static let jsonEncoder = JSONEncoder()
    
    @AppStorage(SettingsKeys.accessWorkInProgressFeatures.rawValue)
    var accessWorkInProgressFeatures = get(.accessWorkInProgressFeatures, as: Bool.self)
    
    @AppStorage(SettingsKeys.hasCompletedInitialOnboarding.rawValue)
    var hasCompletedInitialOnboarding = get(.hasCompletedInitialOnboarding, as: Bool.self)
    
    @AppStorage(SettingsKeys.openInCami.rawValue)
    var openInCami = get(.openInCami, as: Bool.self)
    
    // MARK: - Completed Onboarding Steps
    
    @AppStorage(SettingsKeys.completedOnboardingSteps.rawValue)
    private var rawStorage_completedOnboardingSteps = get(.completedOnboardingSteps, as: Data?.self) ?? Data()
    
    var completedOnboardingSteps: Set<Int> {
        get {
            Self.decode(Set<Int>.self, from: rawStorage_completedOnboardingSteps) ?? []
        }
        set {
            if let encodedValue = Self.encode(newValue) {
                rawStorage_completedOnboardingSteps = encodedValue
            }
        }
    }
}

@MainActor
extension AppStorageManager {
    private static func get<T>(_ key: SettingsKeys, as type: T.Type) -> T {
        switch T.self {
            case is Bool.Type:
                UserDefaults.standard.bool(forKey: key.rawValue) as! T
            case is Data?.Type:
                UserDefaults.standard.data(forKey: key.rawValue) as! T
            default:
                fatalError("Unsupported type \(type) for AppStorageManager default value.")
        }
    }
    
    private static func encode<T: Encodable>(_ value: T) -> Data? {
        do {
            return try jsonEncoder.encode(value)
        } catch {
            logger.error("Failed to encode value: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    private static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        do {
            return try jsonDecoder.decode(type, from: data)
        } catch {
            logger.error("Failed to decode value: \(error.localizedDescription)")
        }
        
        return nil
    }
}
