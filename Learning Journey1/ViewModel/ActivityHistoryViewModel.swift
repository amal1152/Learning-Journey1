//
//  ActivityHistoryViewModel.swift
//  Learning Journey1
//
//  Created by Amal Alqahtani on 07/06/1448 AH.
//

import SwiftUI
import Combine

class ActivityHistoryViewModel: ObservableObject {

    let records: [ActivityRecord]
    let startDate: Date
    let endDate: Date

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = 1
        return calendar
    }()

    init(
        records: [ActivityRecord],
        startDate: Date,
        endDate: Date
    ) {
        self.records = records
        self.startDate = startDate
        self.endDate = endDate
    }

    // All months from the first activity until the current month
    
    var months: [Date] {

        let calendar = Calendar(identifier: .gregorian)

        guard let startOfYear = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 1,
                day: 1
            )
        ) else {
            return []
        }

        return (0..<12).compactMap { month in

            calendar.date(
                byAdding: .month,
                value: month,
                to: startOfYear
            )
        }
    }


    // Status of a specific date
    func status(for date: Date) -> ActivityDayStatus {

        records.first {
            calendar.isDate(
                $0.date,
                inSameDayAs: date
            )
        }?.status ?? .none
    }

    // Dates displayed inside a month grid
    func datesForMonth(_ month: Date) -> [Date?] {

        guard let range = calendar.range(
            of: .day,
            in: .month,
            for: month
        ) else {
            return []
        }

        let firstWeekday = calendar.component(
            .weekday,
            from: month
        )

        let leadingEmptyDays = firstWeekday - 1

        var dates: [Date?] = Array(
            repeating: nil,
            count: leadingEmptyDays
        )

        for day in range {

            if let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: month
            ) {
                dates.append(date)
            }
        }

        return dates
    }

    func isFutureDate(_ date: Date) -> Bool {
        calendar.startOfDay(for: date) >
        calendar.startOfDay(for: endDate)
    }
}
