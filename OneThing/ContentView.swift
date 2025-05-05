//
//  ContentView.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/04/27.
//

import SwiftUI

// Data model for activity options
struct Activity: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let name: String
}


struct ActivityButton: View {
    let activity: Activity
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            HStack {
                Text(activity.emoji)
                    .font(.headline)
                    .padding(.leading)
                
                Text(activity.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(Color(white: 0.9))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 3)
            )
            
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @StateObject private var appStateManager = AppStateManager.shared
    @AppStorage("lastSelectionDate") private var lastSelectionTimeStamp: Double = 0
    
    // Enum to manage current view
    enum CurrentView {
        case oneThingPicker
        case camera(activity: Activity)
        case scanning(image: UIImage, activity: Activity)
        case results(isSuccess: Bool, confidence: Int, activityName: String, appName: String)
    }

    // Add a Binding to accept the state from OneThingApp
    @Binding var currentView: CurrentView
    
    // Computed property to get the date from the timestamp
    private var lastSelectionDate: Date {
        return Date(timeIntervalSince1970: lastSelectionTimeStamp)
    }
    
    var body: some View {
        VStack {
            switch currentView {
            case .oneThingPicker:
                OneThingPickerView(currentView: $currentView)
            case .camera(let activity):
                CameraView(selectedActivity: activity, currentView: $currentView)
            case .scanning(let image, let activity):
                ScanningPlaceholderView(image: image, activity: activity, currentView: $currentView)
            case .results(let isSuccess, let confidence, let activityName, let appName):
                ResultsView(isSuccess: isSuccess, confidence: confidence, activityName: activityName, appName: appName, currentView: $currentView)
            }
        }
    }
    
    private func findActivity(byID id: String) -> Activity? {
        let activities = [
            Activity(emoji: "💪", name: "Gym"),
            Activity(emoji: "📚", name: "Reading"),
            Activity(emoji: "🎹", name: "Piano"),
            Activity(emoji: "🔒", name: "Deep Work")
        ]
        
        return activities.first { $0.id.uuidString == id }
    }

    private func findActivity(byName name: String) -> Activity? {
        let activities = [
            Activity(emoji: "💪", name: "Gym"),
            Activity(emoji: "📚", name: "Reading"),
            Activity(emoji: "🎹", name: "Piano"),
            Activity(emoji: "🔒", name: "Deep Work")
        ]
        
        return activities.first { $0.name == name }
    }
}

// Add the OneThingView struct back 
struct OneThingView: View {
    let lastGuardedApp: String
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("One Thing Guard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Are you sure you want to use \(lastGuardedApp) right now?")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                
                Button(action: {
                    // Record the time when user breaks through the guard
                    AppStateManager.shared.recordBreakTime()
                    
                    // Close the view
                    UIApplication.shared.perform(NSSelectorFromString("suspend"))
                }) {
                    Text("Yes, continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.horizontal, 40)
                }
                .padding()
                
                Button(action: {
                    UIApplication.shared.perform(NSSelectorFromString("suspend"))
                }) {
                    Text("No, close this app")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(30)
                        .padding(.horizontal, 40)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView(currentView: .constant(.oneThingPicker))
        .environmentObject(NavigationModel.shared)
}
