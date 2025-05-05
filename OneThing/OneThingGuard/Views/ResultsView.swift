//
//  ResultsView.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/05.
//

import SwiftUI

struct ResultsView: View {
    // Add parameters for isSuccess, confidence, activityName, appName, and currentView
    var isSuccess: Bool
    var confidence: Int
    var activityName: String
    var appName: String
    @Binding var currentView: ContentView.CurrentView
    
    // State for animations
    @State private var animatedConfidence: Int = 0 // State for the count-up animation
    @State private var showContent: Bool = false
    @State private var showButton: Bool = false
    
    var body: some View {
        ZStack {
            // Background Color
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Top Title
                Text(isSuccess ? "WELL DONE!" : "Oh no :(")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeInOut(duration: 0.8).delay(0.2), value: showContent)
                
                Spacer()
                
                // Confidence Display
                VStack(spacing: 8) {
                    Text("We are")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("\(animatedConfidence)%")
                        .font(.system(size: 90, weight: .bold))
                        .foregroundColor(isSuccess ? .green : .red)
                    // Glow effect using shadow
                        .shadow(color: (isSuccess ? Color.green : Color.red).opacity(0.8), radius: 15, x: 0, y: 0)
                    // Apply animation specifically for the number change
                        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 1.0), value: animatedConfidence)
                    
                    Text("sure you are \(isSuccess ? "" : "NOT ") doing your ONE THING")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeInOut(duration: 0.8).delay(0.4), value: showContent)
                
                Spacer()
                
                // Action Button
                Button(action: {
                    if isSuccess {
                        print("Unlock \(appName)")
                        
                        // Set the break time to the current time
                        let currentTime = Date().timeIntervalSince1970
                        let sharedDefaults = UserDefaults(suiteName: "group.com.jasonmayo.OneThingApp")
                        sharedDefaults?.set(currentTime, forKey: "LastBreakTime")
                        sharedDefaults?.set(true, forKey: "UserAllowedBreak")
                        sharedDefaults?.synchronize()
                        
                        // Open the app
                        if let appName = sharedDefaults?.string(forKey: "LastGuardedApp") {
                            UIApplication.shared.open(getAppURL(for: appName), options: [:])
                        }
                        
                        // Navigate to the next view or perform any other action
                        // currentView = .nextView // Uncomment and set the appropriate view
                    } else {
                        print("Retake Photo")
                        // Add logic to navigate back or retake
                        // Need to find the activity object based on the name
                        if let activity = findActivity(byName: activityName) {
                             currentView = .camera(activity: activity) // Set the view to CameraView with the correct activity
                        } else {
                            // Fallback or handle error if activity not found
                            print("Error: Could not find activity named \(activityName)")
                            // Optionally navigate back to picker or show an error
                            currentView = .oneThingPicker
                        }
                    }
                }) {
                    Text(isSuccess ? "Unlock \(appName)" : "Retake Photo")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }.padding()
                .onAppear {
                    // Trigger animations
                    showContent = true
                    showButton = true
                    
                    // Start count-up animation after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // Delay matches confidence block fade-in
                        animatedConfidence = confidence
                    }
                }
            }
        }
    }
    
    // Helper function to find activity by name
    private func findActivity(byName name: String) -> Activity? {
        // Assuming activities are defined globally or passed in a way this view can access them
        // For now, redefining them here. Consider a better approach for sharing activity data.
        let activities = [
            Activity(emoji: "💪", name: "Gym"),
            Activity(emoji: "📚", name: "Reading"),
            Activity(emoji: "🎹", name: "Piano"),
            Activity(emoji: "🔒", name: "Deep Work")
        ]
        
        return activities.first { $0.name == name }
    }

    private func getAppURL(for appName: String) -> URL {
        switch appName.lowercased() {
        case "instagram": return URL(string: "instagram://")!
        case "youtube": return URL(string: "youtube://")!
        case "tiktok": return URL(string: "tiktok://")!
        case "threads": return URL(string: "threads://")!
        case "snapchat": return URL(string: "snapchat://")!
        case "netflix": return URL(string: "netflix://")!
        case "facebook": return URL(string: "facebook://")!
        case "bereal": return URL(string: "bereal://")!
        case "reddit": return URL(string: "reddit://")!
        case "x": return URL(string: "x://")!
        case "safari": return URL(string: "https://google.com")!
        default: return URL(string: "instagram://")!
        }
    }
}
