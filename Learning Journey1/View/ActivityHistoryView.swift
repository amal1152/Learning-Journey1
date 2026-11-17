//
//  ActivityHistoryView.swift
//  Learning Journey1
//
//  Created by Amal Alqahtani on 07/06/1448 AH.
//

import SwiftUI

struct ActivityHistoryView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ActivityHistoryViewModel

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 7
    )

    init(
        records: [ActivityRecord],
        startDate: Date,
        endDate: Date
    ) {
        _viewModel = StateObject(
            wrappedValue: ActivityHistoryViewModel(
                records: records,
                startDate: startDate,
                endDate: endDate
            )
        )
    }

    var body: some View {

        ZStack {

            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Header
                HStack {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Activities")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    // Balance the header
                    Color.clear
                        .frame(width: 42, height: 42)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 18)

                // Scrollable months
                ScrollViewReader { proxy in

                    ScrollView(showsIndicators: true) {

                        LazyVStack(spacing: 0) {

                            ForEach(
                                Array(viewModel.months.enumerated()),
                                id: \.offset
                            ) { index, month in

                                monthCalendar(month)
                                    .id(index)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .onAppear {

                        let currentMonth = Calendar.current.component(
                            .month,
                            from: Date()
                        )

                        DispatchQueue.main.async {
                            proxy.scrollTo(currentMonth - 1, anchor: .top)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Month Calendar

    private func monthCalendar(_ month: Date) -> some View {

        let dates = viewModel.datesForMonth(month)

        let weekdays = [
            "SUN", "MON", "TUE", "WED",
            "THU", "FRI", "SAT"
        ]

        return VStack(alignment: .leading, spacing: 12) {

            // Month title
            Text(
                month.formatted(
                    .dateTime.month(.wide).year()
                        .locale(Locale(identifier: "en_US"))
                )
            )
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .padding(.top, 14)

            // Weekday names
            LazyVGrid(columns: columns, spacing: 8) {

                ForEach(weekdays, id: \.self) { day in

                    Text(day)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days
            LazyVGrid(columns: columns, spacing: 9) {

                ForEach(
                    0..<dates.count,
                    id: \.self
                ) { index in

                    if let date = dates[index] {

                        dayCell(date)

                    } else {

                        Color.clear
                            .frame(height: 34)
                    }
                }
            }

            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
                .padding(.top, 4)
        }
        .padding(.horizontal, 2)
    }

    // MARK: - Day Cell

    private func dayCell(_ date: Date) -> some View {

        let status = viewModel.status(for: date)

        let isFuture = viewModel.isFutureDate(date)

        let dayNumber = Calendar.current.component(
            .day,
            from: date
        )

        return Text("\(dayNumber)")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(dayTextColor(status, isFuture: isFuture))
            .frame(width: 34, height: 34)
            .background {

                if !isFuture {
                    Circle()
                        .fill(dayBackground(status))
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel(
                "\(date.formatted(date: .complete, time: .omitted)), \(status.rawValue)"
            )
    }

    // MARK: - Day Colors

    private func dayTextColor(
        _ status: ActivityDayStatus,
        isFuture: Bool
    ) -> Color {

        if isFuture {
            return .gray.opacity(0.5)
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

    private func dayBackground(
        _ status: ActivityDayStatus
    ) -> Color {

        switch status {
        case .learned:
            return Color.orange.opacity(0.18)

        case .frozen:
            return Color.cyan.opacity(0.18)

        case .none:
            return .clear
        }
    }
}

#Preview {
    ActivityHistoryView(
        records: [],
        startDate: Date(),
        endDate: Date()
    )
}
