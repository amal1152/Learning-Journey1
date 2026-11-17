//
//  ActivityModel.swift
//  Learning Journey1
//
//  Created by Amal Alqahtani on 01/06/1448 AH.
//


import Foundation

enum ActivityDayStatus: String, Codable {
    case none
    case learned
    case frozen
}

enum GoalResult {
    case completed
    case notMet
}

struct ActivityRecord: Identifiable, Codable {
    let date: Date
    var status: ActivityDayStatus

    var id: Date {
        Calendar.current.startOfDay(for: date)
    }
}

struct ActivityDay: Identifiable {
    let date: Date
    let status: ActivityDayStatus

    var id: Date {
        Calendar.current.startOfDay(for: date)
    }
}

struct ActivityModel {

    var records: [ActivityRecord] = []

    var selectedDate: Date

    var duration: LearningDuration

    var goalStartDate: Date

    init(
        duration: LearningDuration = .week,
        startDate: Date = Date()
    ) {
        let today = Calendar.current.startOfDay(for: startDate)

        self.duration = duration
        self.goalStartDate = today
        self.selectedDate = today
    }

    // Freeze limit
    var totalFreezes: Int {
        switch duration {
        case .week:
            return 2
        case .month:
            return 8
        case .year:
            return 96
        }
    }

    // Goal end date (exclusive)
    var goalEndDate: Date {
        let component: Calendar.Component

        switch duration {
        case .week:
            component = .weekOfYear
        case .month:
            component = .month
        case .year:
            component = .year
        }

        return Calendar.current.date(
            byAdding: component,
            value: 1,
            to: goalStartDate
        ) ?? goalStartDate
    }

    // All days required to complete the goal
    var goalDates: [Date] {

        let calendar = Calendar.current

        let numberOfDays = calendar.dateComponents(
            [.day],
            from: goalStartDate,
            to: goalEndDate
        ).day ?? 0

        return (0..<numberOfDays).compactMap {
            calendar.date(
                byAdding: .day,
                value: $0,
                to: goalStartDate
            )
        }
    }

    // Weekly calendar
    var days: [ActivityDay] {

        let calendar = Calendar.current

        let weekday = calendar.component(
            .weekday,
            from: selectedDate
        )

        let difference = (
            weekday - calendar.firstWeekday + 7
        ) % 7

        guard let startOfWeek = calendar.date(
            byAdding: .day,
            value: -difference,
            to: calendar.startOfDay(for: selectedDate)
        ) else {
            return []
        }

        return (0..<7).compactMap { offset in

            guard let date = calendar.date(
                byAdding: .day,
                value: offset,
                to: startOfWeek
            ) else {
                return nil
            }

            let status = records.first {
                calendar.isDate(
                    $0.date,
                    inSameDayAs: date
                )
            }?.status ?? .none

            return ActivityDay(
                date: date,
                status: status
            )
        }
    }

    // Freezes used during this goal
    var freezesUsed: Int {

        records.filter {
            $0.status == .frozen &&
            $0.date >= goalStartDate &&
            $0.date < goalEndDate
        }.count
    }

    // Save or update a day
    mutating func setStatus(
        _ status: ActivityDayStatus,
        for date: Date
    ) {

        let day = Calendar.current.startOfDay(for: date)

        if let index = records.firstIndex(where: {
            Calendar.current.isDate(
                $0.date,
                inSameDayAs: day
            )
        }) {
            records[index].status = status
        } else {
            records.append(
                ActivityRecord(
                    date: day,
                    status: status
                )
            )
        }
    }
}
