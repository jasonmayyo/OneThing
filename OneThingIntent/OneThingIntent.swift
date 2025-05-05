//
//  OneThingIntent.swift
//  OneThingIntent
//
//  Created by Jason Mayo on 2025/04/27.
//

import AppIntents
import Foundation
import UIKit

struct OneThingIntent: AppIntent {
    static var title: LocalizedStringResource = "One Thing Guard"
    
    static var description = IntentDescription(
        "Check if a One Thing Guard has been placed on this app"
    )
    
    @Parameter(title: "App Name")
    var appName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Active One Thing Guard when \(\.$appName) opens")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let cooldownDuration: TimeInterval = 5 * 60 // 5 minutes
        let currentTime = Date().timeIntervalSince1970
        
        // Use shared UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.jasonmayo.OneThingApp")
        let lastBreakTime = sharedDefaults?.double(forKey: "LastBreakTime") ?? 0
        
        print("OneThingIntent: Current time:", currentTime)
        print("OneThingIntent: Last break time:", lastBreakTime)
        print("OneThingIntent: Time difference:", currentTime - lastBreakTime)
        print("OneThingIntent: Cooldown duration:", cooldownDuration)
        
        // Store the app name for later use
        sharedDefaults?.set(appName, forKey: "LastGuardedApp")
        
        // Only check if we're within the cooldown period
        if currentTime - lastBreakTime < cooldownDuration {
            print("OneThingIntent: Within cooldown period, skipping break")
            return .result(value: false)
        }
        
        print("OneThingIntent: Outside cooldown period, showing OneThingView")
        return .result(value: true)
    }
}
