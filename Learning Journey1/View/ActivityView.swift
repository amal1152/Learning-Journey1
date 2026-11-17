//
//  ActivityView.swift
//  Learning Journey1
//
//  Created by Amal Alqahtani on 01/06/1448 AH.
//


import SwiftUI
import Combine

struct ActivityView: View {

    @StateObject private var viewModel: ActivityViewModel

    init(
        topic: String = "",
        duration: LearningDuration = .week
    ) {
        _viewModel = StateObject(
            wrappedValue: ActivityViewModel(
                topic: topic,
                duration: duration
            )
        )
    }

    private var selectedDateBinding: Binding<Date> {

        Binding(
            get: {
                viewModel.model.selectedDate
            },
            set: {
                viewModel.selectDateFromCalendar($0)
            }
        )
    }

    var body: some View {

        ZStack {

            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header

                HStack {

                    VStack(alignment: .leading, spacing: 5) {

                        Text("Activity")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        Text(
                            viewModel.model.selectedDate.formatted(
                                Date.FormatStyle()
                                    .weekday(.wide)
                                    .day()
                                    .month(.wide)
                            )
                        )
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    }

                    Spacer()

                    // Activities Calendar Button

                    Button {
                        viewModel.showCalendar = true
                    } label: {

                        Image(systemName: "calendar")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }

                    // Change Goal Button

                    Button {
                        viewModel.showChangeGoal = true
                    } label: {

                        Image(systemName: "pencil.and.outline")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 25)

                // MARK: Weekly Calendar

                HStack(spacing: 0) {

                    ForEach(viewModel.model.days) { day in

                        let isSelected = Calendar.current.isDate(
                            day.date,
                            inSameDayAs: viewModel.model.selectedDate
                        )

                        let isToday = Calendar.current.isDateInToday(
                            day.date
                        )

                        VStack(spacing: 8) {

                            Text(
                                day.date.formatted(
                                    .dateTime.weekday(.narrow)
                                        .locale(
                                            Locale(identifier: "en_US")
                                        )
                                )
                            )
                            .font(.system(size: 10))
                            .foregroundColor(.white)

                            let dayNumber = Calendar.current.component(
                                .day,
                                from: day.date
                            )

                            Text(String(dayNumber))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(
                                    dayColor(
                                        day.status,
                                        isSelected: isSelected
                                    )
                                )
                                .frame(width: 29, height: 29)
                                .background {

                                    Circle()
                                        .fill(
                                            dayBackground(
                                                day.status,
                                                isSelected: isSelected
                                            )
                                        )
                                }
                                .overlay {

                                    if isToday && !isSelected && day.status == .none {

                                        Circle()
                                            .stroke(
                                                Color.orange,
                                                lineWidth: 1
                                            )
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectDay(day.date)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 25)

                // MARK: Statistics

                HStack(spacing: 10) {

                    statCard(
                        icon: "flame.fill",
                        color: .orange,
                        count: viewModel.streakCount,
                        title: "Learned"
                    )

                    statCard(
                        icon: "snowflake",
                        color: .cyan,
                        count: viewModel.frozenCount,
                        title: "Freezed"
                    )
                }
                .padding(.horizontal, 12)
                .padding(.top, 18)

                // MARK: Goal Result or Daily Activity

                if let result = viewModel.goalResult {

                    goalResultScreen(result)

                } else {

                    Spacer(minLength: 120)


                    // MARK: Log as Learned / Unlearn

                    Button {

                        if viewModel.selectedStatus == .learned {
                            viewModel.unlearnDay()
                        } else {
                            viewModel.logAsLearned()
                        }

                    } label: {

                        Text(
                            viewModel.selectedStatus == .learned
                            ? "Unlearn"
                            : "Log as Learned"
                        )
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(
                            viewModel.selectedStatus == .none
                            ? .white : .gray
                        )
                        .frame(width: 250, height: 250)
                        .background(
                            viewModel.selectedStatus == .none
                            ? Color.orange
                            : Color.white.opacity(0.10)
                        )
                        .clipShape(Circle())
                        .overlay {

                            Circle()
                                .stroke(
                                    Color.white.opacity(0.12),
                                    lineWidth: 1
                                )
                        }
                        .shadow(
                            color: .orange.opacity(0.20),
                            radius: 12,
                            x: 0,
                            y: 4
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        Calendar.current.startOfDay(
                            for: viewModel.model.selectedDate
                        ) > Calendar.current.startOfDay(
                            for: viewModel.currentDate
                        )
                    )
                    Spacer(minLength: 20)
                    // MARK: Freeze Button

                    Button {
                        viewModel.freezeDay()
                    } label: {

                        HStack(spacing: 7) {

                            Image(systemName: "snowflake")

                            Text(
                                viewModel.selectedStatus == .frozen
                                ? "Freezed for a day"
                                : "Freeze for a day"
                            )
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .overlay {

                            Capsule()
                                .stroke(
                                    Color.white.opacity(0.3),
                                    lineWidth: 1
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        viewModel.selectedStatus != .none ||
                        viewModel.remainingFreezes == 0 ||
                        Calendar.current.startOfDay(
                            for: viewModel.model.selectedDate
                        ) > Calendar.current.startOfDay(
                            for: viewModel.currentDate
                        )
                    )
                    .opacity(
                        viewModel.selectedStatus != .none ||
                        viewModel.remainingFreezes == 0 ||
                        Calendar.current.startOfDay(
                            for: viewModel.model.selectedDate
                        ) > Calendar.current.startOfDay(
                            for: viewModel.currentDate
                        ) ? 0.25 : 1
                    )
                    .padding(.horizontal, 38)

                    // Freeze Counter

                    Text(
                        "\(viewModel.freezesUsed) out of \(viewModel.model.totalFreezes) Freezes used"
                    )
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)

        // MARK: Activities History Calendar

        .sheet(isPresented: $viewModel.showCalendar) {

            ActivityHistoryView(
                records: viewModel.historyRecords,
                startDate: viewModel.historyStartDate,
                endDate: viewModel.currentDate
            )
        }

        // MARK: Change Learning Goal

        .sheet(isPresented: $viewModel.showChangeGoal) {

            ChangeGoalView(
                topic: viewModel.topic,
                duration: viewModel.model.duration
            ) { newTopic, newDuration in

                viewModel.updateLearningGoal(
                    topic: newTopic,
                    duration: newDuration
                )
            }
        }

        // MARK: Refresh Date

        .onReceive(
            Timer.publish(
                every: 60,
                on: .main,
                in: .common
            ).autoconnect()
        ) { _ in

            viewModel.refreshCurrentDate()
        }
    }

    // MARK: Day Text Color

    private func dayColor(
        _ status: ActivityDayStatus,
        isSelected: Bool
    ) -> Color {

        if isSelected {
            return .white
        }

        switch status {

        case .learned:
            return .orange

        case .frozen:
            return .cyan

        case .none:
            return .white
        }
    }

    // MARK: Day Background

    private func dayBackground(
        _ status: ActivityDayStatus,
        isSelected: Bool
    ) -> Color {

        if isSelected {
            return .orange
        }

        switch status {

        case .learned:
            return Color.orange.opacity(0.15)

        case .frozen:
            return Color.cyan.opacity(0.15)

        case .none:
            return .clear
        }
    }

    // MARK: Statistics Card

    private func statCard(
        icon: String,
        color: Color,
        count: Int,
        title: String
    ) -> some View {

        VStack(spacing: 5) {

            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)

            Text(
                "\(count) \(count == 1 ? "day" : "days")"
            )
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)

            Text(title)
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 63)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {

            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.white.opacity(0.18),
                    lineWidth: 1
                )
        }
    }

    // MARK: Goal Result Screen

    private func goalResultScreen(
        _ result: GoalResult
    ) -> some View {

        VStack(spacing: 0) {

            Spacer()

            if result == .completed {

                // Completed Icon

                Image(systemName: "hands.clap.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)

                Text("Well done!")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Text("Ready for your next goal?")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 8)

            } else {

                // Not Met Icon

                Image(systemName: "xmark.seal.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)

                Text("You didn't reach your goal this time.")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Text("Want to set another goal?")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }

            Spacer()

            // Set a Goal Button

            Button {
                viewModel.showChangeGoal = true
            } label: {

                HStack(spacing: 8) {

                    Image(systemName: "clock.arrow.circlepath")

                    Text("Set a goal")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .frame(height: 50)
                .background(Color.orange)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
                .frame(height: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 25)
    }
}

#Preview {

    ActivityView(
        topic: "Swift",
        duration: .week
    )
}
