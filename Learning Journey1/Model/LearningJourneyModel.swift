//
//  LearningJourneyModel.swift
//  Learning Journey1
//
//  Created by Amal Alqahtani on 30/05/1448 AH.
//


import Foundation

enum LearningDuration: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String {
        rawValue
    }
}

struct LearningJourneyModel {
    var topic: String = ""
    var duration: LearningDuration = .week
}
