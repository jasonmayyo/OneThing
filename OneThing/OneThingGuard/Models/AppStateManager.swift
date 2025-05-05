import Foundation
import UIKit

class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var sourceApp: String = ""
    
    private let userDefaults = UserDefaults(suiteName: "group.com.jasonmayo.onething") ?? UserDefaults.standard
    
    private init() {
        // Load source app if available
        sourceApp = userDefaults.string(forKey: "LastGuardedApp") ?? ""
    }
    
    // Check if user has selected a One Thing today
    var hasSelectedOneThingToday: Bool {
        let lastSelectionTimeStamp = userDefaults.double(forKey: "lastSelectionDate")
        if lastSelectionTimeStamp > 0 {
            let lastSelectionDate = Date(timeIntervalSince1970: lastSelectionTimeStamp)
            return Calendar.current.isDateInToday(lastSelectionDate)
        }
        return false
    }
    
    // Save source app for later redirection
    func saveSourceApp(_ appName: String) {
        sourceApp = appName
        userDefaults.set(appName, forKey: "LastGuardedApp")
    }
    
    // Record break time when user completes One Thing check
    func recordBreakTime() {
        userDefaults.set(Date().timeIntervalSince1970, forKey: "LastBreakTime")
    }
    
    // Check if we're within the cooldown period
    func isWithinCooldownPeriod(minutes: Int = 5) -> Bool {
        let cooldownDuration: TimeInterval = TimeInterval(minutes * 60)
        let currentTime = Date().timeIntervalSince1970
        let lastBreakTime = userDefaults.double(forKey: "LastBreakTime")
        
        return (currentTime - lastBreakTime) < cooldownDuration
    }
    
    // Save selected One Thing
    func saveSelectedOneThing(_ activity: String) {
        userDefaults.set(activity, forKey: "selectedOneThing")
        userDefaults.set(Date().timeIntervalSince1970, forKey: "lastSelectionDate")
    }
    
    // Get selected One Thing
    var selectedOneThing: String {
        return userDefaults.string(forKey: "selectedOneThing") ?? ""
    }
    
    // Redirect to source app
    func redirectToSourceApp() {
        guard !sourceApp.isEmpty else { return }
        
        // This is a simplified implementation
        // In a real app, you would use App Groups and URL schemes to handle this
        // For example, using URL like "instagram://" if sourceApp is "Instagram"
        
        // For now, we'll just suspend our app
        UIApplication.shared.perform(NSSelectorFromString("suspend"))
    }
} 