//
//  OneThingApp.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/04/27.
//

import SwiftUI

@main
struct OneThingApp: App {
    @StateObject private var navigationModel = NavigationModel.shared
    @StateObject private var appStateManager = AppStateManager.shared
    @StateObject private var oneThingGuardModel = OneThingGuardModel()
    @State private var currentView: ContentView.CurrentView = .oneThingPicker
    @State private var splashAnimationFinished = false
    
    init() {
        // Enable camera usage description
        setupAppPermissions()
        
        // Check if a 'One Thing' has been selected
        if let selectedActivityID = UserDefaults.standard.string(forKey: "SelectedOneThingID"),
           let activity = findActivity(byID: selectedActivityID) {
            // If a selection exists, set the initial view to CameraView with the selected activity
            _currentView = State(initialValue: .camera(activity: activity))
        } else {
            // Default to picker if no valid selection found
            _currentView = State(initialValue: .oneThingPicker)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if splashAnimationFinished {
            ContentView(currentView: $currentView)
                .environmentObject(navigationModel)
                .environmentObject(appStateManager)
                .environmentObject(oneThingGuardModel)
                .preferredColorScheme(.dark)
            } else {
                SplashScreenView(isAnimationComplete: $splashAnimationFinished)
            }
        }
    }
    
    private func setupAppPermissions() {
        // This doesn't actually set up permissions, but in a real app
        // you would request camera permissions at an appropriate time
        
        // You need to add these to Info.plist:
        // NSCameraUsageDescription - "One Thing needs camera access to verify your activity"
        // NSPhotoLibraryUsageDescription - "One Thing needs photo library access to save your evidence photos"
    }
    
    // Helper function to find activity (moved or copied here for access)
    private func findActivity(byID id: String) -> Activity? {
        let activities = [
            Activity(emoji: "💪", name: "Gym"),
            Activity(emoji: "📚", name: "Reading"),
            Activity(emoji: "🎹", name: "Piano"),
            Activity(emoji: "🔒", name: "Deep Work")
        ]
        
        return activities.first { $0.id.uuidString == id }
    }
}
