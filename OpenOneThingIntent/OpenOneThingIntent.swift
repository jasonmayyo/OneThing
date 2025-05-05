//
//  OpenOneThingIntent.swift
//  OpenOneThingIntent
//
//  Created by Jason Mayo on 2025/04/27.
//

import AppIntents

struct OpenOneThingIntent: AppIntent {
    static let title: LocalizedStringResource = "Open One Thing"
    static let description = IntentDescription("Opens the One Thing app")
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        print("OpenOneThingIntent: Attempting to perform")
        NavigationModel.shared.navigate(to: .oneThingView)
        return .result(value: true)
    }
}
