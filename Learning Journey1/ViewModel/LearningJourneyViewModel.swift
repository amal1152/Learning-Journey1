//
//  LearningJourneyViewModel.swift
//  Learning Journey1
//
//  Created by Amal Alqahtani on 30/05/1448 AH.
//



import SwiftUI
import Combine

class LearningJourneyViewModel: ObservableObject {

    @Published var model = LearningJourneyModel()

    @Published var showAlert = false
    @Published var navigateToActivity = false

    func startLearning() {

        let topic = model.topic.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !topic.isEmpty else {
            showAlert = true
            return
        }

        model.topic = topic

        print("Topic: \(topic)")
        print("Duration: \(model.duration.rawValue)")

        navigateToActivity = true
    }
}
