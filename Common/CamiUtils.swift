//
//  Utils.swift
//  Cami
//
//  Created by Guillaume Coquard on 07/11/23.
//

import Foundation

public final class CamiUtils {
    public static func getDayFromDate(date: Date) -> (String,String) {
        let stringFormatter = DateFormatter()
        let numberFormatter = DateFormatter()
        stringFormatter.dateFormat = "EEEE"
        numberFormatter.dateFormat = "d"
        return (
            stringFormatter.string(from: date),
            numberFormatter.string(from: date)
        )
    }

    public static func relativeDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        formatter.monthSymbols = .none
        formatter.doesRelativeDateFormatting = true
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: date)
    }

    public static func remainingTime(_ date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowedUnits = [.day, .hour, .minute]
        return formatter.string(from: Date.now, to: date)!
    }
}


