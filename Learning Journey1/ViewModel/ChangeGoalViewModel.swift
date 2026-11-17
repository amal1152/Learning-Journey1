//
//  ChangeGoalViewModel.swift
//  Learning Journey1
//
//  Created by Amal Alqahtani on 07/06/1448 AH.
//

import SwiftUI
import Combine

class ChangeGoalViewModel: ObservableObject {

    @Published var topic: String
    @Published var duration: LearningDuration
    @Published var showConfirmation = false

    init(
        topic: String,
        duration: LearningDuration
    ) {
        self.topic = topic
        self.duration = duration
    }

    func requestUpdate() {

        let cleanedTopic = topic.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedTopic.isEmpty else {
            return
        }

        topic = cleanedTopic
        showConfirmation = true
    }
}
