//
//  ChangeGoalView.swift
//  Learning Journey1
//
//  Created by Amal Alqahtani on 07/06/1448 AH.
//

import SwiftUI

struct ChangeGoalView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ChangeGoalViewModel

    let onUpdate: (String, LearningDuration) -> Void

    init(
        topic: String,
        duration: LearningDuration,
        onUpdate: @escaping (String, LearningDuration) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: ChangeGoalViewModel(
                topic: topic,
                duration: duration
            )
        )

        self.onUpdate = onUpdate
    }

    var body: some View {

        ZStack {

            Color.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

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

                    Text("Learning Goal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        viewModel.requestUpdate()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(Color.orange)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 15)

                // Learning Topic
                Text("I want to learn")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.top, 45)

                TextField("Swift", text: $viewModel.topic)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .tint(.orange)
                    .padding(.vertical, 13)

                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 1)

                // Duration Title
                Text("I want to learn it in a")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.top, 30)

                // Duration Buttons
                HStack(spacing: 12) {

                    ForEach(LearningDuration.allCases) { duration in

                        let isSelected =
                            viewModel.duration == duration

                        Button {
                            viewModel.duration = duration
                        } label: {

                            Text(duration.rawValue)
                                .font(.system(size: 16))
                                .foregroundColor(
                                    isSelected ? .white : .gray
                                )
                                .frame(width: 85, height: 45)
                                .background(
                                    isSelected
                                    ? Color.orange
                                    : Color.white.opacity(0.10)
                                )
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .stroke(
                                            Color.white.opacity(0.15),
                                            lineWidth: 1
                                        )
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 12)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .preferredColorScheme(.dark)
        .alert("Update goal", isPresented: $viewModel.showConfirmation) {

            Button("Dismiss", role: .cancel) { }

            Button("Update", role: .destructive) {
                onUpdate(
                    viewModel.topic,
                    viewModel.duration
                )

                dismiss()
            }

        } message: {
            Text("If you update now, your streak will start over.")
        }
    }
}

#Preview {
    ChangeGoalView(
        topic: "Swift",
        duration: .week,
        onUpdate: { _, _ in }
    )
}
