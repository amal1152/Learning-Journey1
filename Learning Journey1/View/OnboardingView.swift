//
//  LearningJourneyView.swift
//  Learning Journey1
//
//  Created by Amal Alqahtani on 30/05/1448 AH.
//

import SwiftUI

struct OnboardingView: View {

    @StateObject private var viewModel = LearningJourneyViewModel()

    var body: some View {

        NavigationStack {

            ZStack {

                // Background
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {

                    // Logo
                    Image(systemName: "flame.fill")
                        .font(.system(size: 42))
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 65)

                    Spacer()
                        .frame(height: 90)

                    // Welcome Title
                    HStack(spacing: 0) {

                        Text("Hello ")
                            .fontWeight(.regular)

                        Text("Learner")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 34))
                    .foregroundColor(.primary)

                    // Subtitle
                    Text("This app will help you learn everyday!")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .padding(.top, 6)

                    // Learning Topic
                    Text("I want to learn")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding(.top, 40)

                    TextField(
                        "Swift",
                        text: $viewModel.model.topic
                    )
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .tint(.orange)
                    .padding(.vertical, 12)

                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 1)

                    // Duration Title
                    Text("I want to learn it in a")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding(.top, 30)

                    // Duration Buttons
                    HStack(spacing: 12) {

                        ForEach(LearningDuration.allCases) { duration in

                            let isSelected =
                                viewModel.model.duration == duration

                            Button {
                                viewModel.model.duration = duration
                            } label: {

                                Text(duration.rawValue)
                                    .font(.system(size: 17))
                                    .foregroundColor(
                                        isSelected ? .white : .primary
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .glassEffect(
                                        isSelected
                                        ? .regular.tint(.orange)
                                        : .regular,
                                        in: Capsule()
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 15)

                    Spacer()

                    // Start Learning Button
                    Button {
                        viewModel.startLearning()
                    } label: {

                        Text("Start Learning")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 165, height: 50)
                            .background(Color.orange)
                            .clipShape(Capsule())
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)

                    // Bottom Text
                    Text("You can edit your desire later")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, 22)
            }

            // Navigate to Activity
            .navigationDestination(
                isPresented: $viewModel.navigateToActivity
            ) {

                ActivityView(
                    topic: viewModel.model.topic,
                    duration: viewModel.model.duration
                )
            }
        }

        // Empty Topic Alert
        .alert(
            "Learning Topic",
            isPresented: $viewModel.showAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter what you want to learn.")
        }

        .preferredColorScheme(.dark)
    }
}

#Preview {
    OnboardingView()
}
