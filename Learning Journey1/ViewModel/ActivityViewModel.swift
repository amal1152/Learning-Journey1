//
//  ActivityViewModel.swift
//  Learning Journey1
//
//  Created by Amal Alqahtani on 01/06/1448 AH.


import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {

    @Published var model: ActivityModel
    @Published var topic: String

    @Published var showCalendar = false
    @Published var showChangeGoal = false

    @Published var currentDate = Date()
    @Published var historyRecords: [ActivityRecord] = []

    private static let historyKey = "LearningActivityHistory"

    // MARK: - Initialization

    init(
        topic: String = "",
        duration: LearningDuration = .week
    ) {
        self.topic = topic
        self.model = ActivityModel(duration: duration)
        self.historyRecords = Self.loadHistory()
    }

    // MARK: - History Storage

    private static func loadHistory() -> [ActivityRecord] {

        guard let data = UserDefaults.standard.data(
            forKey: historyKey
        ) else {
            return []
        }

        return (try? JSONDecoder().decode(
            [ActivityRecord].self,
            from: data
        )) ?? []
    }

    private func saveHistory() {

        guard let data = try? JSONEncoder().encode(
            historyRecords
        ) else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: Self.historyKey
        )
    }

    private func saveHistoryRecord(
        status: ActivityDayStatus,
        date: Date
    ) {

        let day = Calendar.current.startOfDay(for: date)

        if let index = historyRecords.firstIndex(where: {
            Calendar.current.isDate(
                $0.date,
                inSameDayAs: day
            )
        }) {

            historyRecords[index].status = status

        } else {

            historyRecords.append(
                ActivityRecord(
                    date: day,
                    status: status
                )
            )
        }

        saveHistory()
    }

    var historyStartDate: Date {

        historyRecords.map(\.date).min()
            ?? model.goalStartDate
    }


    // MARK: - Goal Completion

  var goalResult: GoalResult? {

       let allDaysCompleted = model.goalDates.allSatisfy { date in

           guard let record = model.records.first(where: {
                Calendar.current.isDate(
                $0.date,
                    inSameDayAs: date
               )
           }) else {
               return false
            }

           return record.status == .learned ||
                   record.status == .frozen
        }

        if allDaysCompleted {
            return .completed
    }

        if currentDate >= model.goalEndDate {
           return .notMet
        }

        return nil
    } 
    
    // هنا اقدر اغير نتيجه الهدف
    
    /* var goalResult: GoalResult? {
        return .notMet
    } */
    
    //notMet
    //completed

    


    // MARK: - Streak

    var streakCount: Int {

        guard let lastRecord = model.records
            .filter({
                $0.status == .learned ||
                $0.status == .frozen
            })
            .max(by: { $0.date < $1.date }) else {
            return 0
        }

        if currentDate.timeIntervalSince(lastRecord.date) >
            32 * 60 * 60 {
            return 0
        }

        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(
            for: lastRecord.date
        )

        var count = 0

        while let record = model.records.first(where: {
            calendar.isDate(
                $0.date,
                inSameDayAs: checkDate
            )
        }) {

            guard record.status == .learned ||
                  record.status == .frozen else {
                break
            }

            if record.status == .learned {
                count += 1
            }

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: checkDate
            ) else {
                break
            }

            checkDate = previousDay
        }

        return count
    }

    // MARK: - Statistics

    var learnedCount: Int {

        model.days.filter {
            $0.status == .learned
        }.count
    }

    var frozenCount: Int {

        model.days.filter {
            $0.status == .frozen
        }.count
    }

    var freezesUsed: Int {
        model.freezesUsed
    }

    var remainingFreezes: Int {

        max(
            0,
            model.totalFreezes - freezesUsed
        )
    }

    // MARK: - Selected Day

    var selectedStatus: ActivityDayStatus {

        model.days.first {
            Calendar.current.isDate(
                $0.date,
                inSameDayAs: model.selectedDate
            )
        }?.status ?? .none
    }

    func selectDay(_ date: Date) {

        model.selectedDate = Calendar.current.startOfDay(
            for: date
        )
    }

    func selectDateFromCalendar(_ date: Date) {

        model.selectedDate = Calendar.current.startOfDay(
            for: date
        )
    }

    // MARK: - Log Learning

    func logAsLearned() {

        let selectedDay = Calendar.current.startOfDay(
            for: model.selectedDate
        )

        let today = Calendar.current.startOfDay(
            for: currentDate
        )

        guard selectedDay >= model.goalStartDate else {
            return
        }

        guard selectedDay < model.goalEndDate else {
            return
        }

        guard selectedDay <= today else {
            return
        }

        guard selectedStatus == .none else {
            return
        }

        model.setStatus(
            .learned,
            for: model.selectedDate
        )

        saveHistoryRecord(
            status: .learned,
            date: model.selectedDate
        )
    }
    // MARK: - Unlearn Day

    func unlearnDay() {

        guard selectedStatus == .learned else {
            return
        }

        model.setStatus(
            .none,
            for: model.selectedDate
        )

        saveHistoryRecord(
            status: .none,
            date: model.selectedDate
        )
    }
    // MARK: - Freeze Day

    func freezeDay() {

        guard remainingFreezes > 0 else {
            return
        }

        guard selectedStatus == .none else {
            return
        }

        let selectedDay = Calendar.current.startOfDay(
            for: model.selectedDate
        )

        let today = Calendar.current.startOfDay(
            for: currentDate
        )

        guard selectedDay >= model.goalStartDate else {
            return
        }

        guard selectedDay < model.goalEndDate else {
            return
        }

        guard selectedDay <= today else {
            return
        }

        model.setStatus(
            .frozen,
            for: model.selectedDate
        )

        saveHistoryRecord(
            status: .frozen,
            date: model.selectedDate
        )
    }

    // MARK: - Refresh Date

    func refreshCurrentDate() {
        currentDate = Date()
    }

    // MARK: - Update Learning Goal

    func updateLearningGoal(
        topic: String,
        duration: LearningDuration
    ) {

        // Preserve previous goal records
        for record in model.records {

            saveHistoryRecord(
                status: record.status,
                date: record.date
            )
        }

        self.topic = topic

        // Start a new learning goal
        model = ActivityModel(
            duration: duration,
            startDate: Date()
        )

        currentDate = Date()
    }
}
