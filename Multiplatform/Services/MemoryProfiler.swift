//
//  MemoryProfiler.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import Foundation
import os.log

final class MemoryProfiler {
    static let shared = MemoryProfiler()
    private let logger = Logger(subsystem: "com.cami.memory", category: "profiler")

    private init() {}

    func profileMemoryUsage(_ label: String = "Memory Check") {
        let usage = getCurrentMemoryUsage()
        logger.info("\(label): \(usage.formatted(.byteCount(style: .memory)))")
    }

    func measureMemoryImpact<T>(
        of operation: () -> T,
        label: String = "Operation"
    ) -> (result: T, memoryDelta: Int64) {
        let beforeMemory = getCurrentMemoryUsage()
        let result = operation()
        let afterMemory = getCurrentMemoryUsage()
        let delta = afterMemory - beforeMemory

        logger.info("\(label) memory impact: \(delta.formatted(.byteCount(style: .memory)))")
        return (result, delta)
    }

    func getCurrentMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Int64(info.resident_size)
        } else {
            logger.error("Failed to get memory usage: \(kerr)")
            return 0
        }
    }

    func checkWidgetMemoryLimit() -> Bool {
        let currentUsage = getCurrentMemoryUsage()
        let limitMB = 30
        let limitBytes = Int64(limitMB * 1024 * 1024)
        let isWithinLimit = currentUsage < limitBytes
        let currentFormatted = currentUsage.formatted(.byteCount(style: .memory))
        let limitFormatted = limitBytes.formatted(.byteCount(style: .memory))
        let status = isWithinLimit ? "✅ OK" : "❌ OVER LIMIT"

        logger.info("Widget memory: \(currentFormatted) / \(limitFormatted) - \(status)")

        return isWithinLimit
    }
}

// MARK: - Memory Measurement Extensions

extension MemoryProfiler {
    func profileDataContextOperations() {
        _ = measureMemoryImpact(of: {
            _ = DataContext.shared.events(from: DataContext.shared.calendars, during: 30, relativeTo: .now)
        }, label: "DataContext Events Fetch")

        _ = measureMemoryImpact(of: {
            DataContext.shared.reminders { _ in }
        }, label: "DataContext Reminders Fetch")

        _ = measureMemoryImpact(of: {
            _ = DataContext.shared.birthdays
        }, label: "DataContext Birthdays Fetch")
    }

    func profileWidgetServices() {
        let widgetService = WidgetDataService()

        _ = measureMemoryImpact(of: {
            _ = widgetService.getEventsForWidget(
                calendars: DataContext.shared.calendars.map(\.calendarIdentifier),
                limit: 20
            )
        }, label: "WidgetDataService Events")

        _ = measureMemoryImpact(of: {
            widgetService.getRemindersForWidget { _ in }
        }, label: "WidgetDataService Reminders")

        _ = measureMemoryImpact(of: {
            _ = widgetService.getBirthdaysForWidget()
        }, label: "WidgetDataService Birthdays")
    }

    func compareWidgetContentCreation() {
        let entry = StandardWidgetEntry.default

        let (_, standardMemory) = measureMemoryImpact(of: {
            StandardWidgetContent(from: entry)
        }, label: "StandardWidgetContent Creation")

        let (_, lightweightMemory) = measureMemoryImpact(of: {
            LightweightWidgetContent(from: entry)
        }, label: "LightweightWidgetContent Creation")

        let memoryImprovement = standardMemory - lightweightMemory
        let percentImprovement = standardMemory > 0 ? (Double(memoryImprovement) / Double(standardMemory)) * 100 : 0

        let improvementString = memoryImprovement.formatted(.byteCount(style: .memory))
        let percentString = String(format: "%.1f", percentImprovement)
        logger.info("Memory improvement: \(improvementString) (\(percentString)%)")
    }
}
