//
//  OneThingPickerView.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/04/27.
//

import SwiftUI

struct OneThingPickerView: View {
    @AppStorage("selectedOneThingID") private var selectedOneThingID: String = ""
    @AppStorage("lastSelectionDate") private var lastSelectionTimeStamp: Double = 0
    @EnvironmentObject var onethingguardmodel: OneThingGuardModel
    @State private var selectedActivity: Activity?
    @State private var showEvidence = false
    
    // Add a binding for currentView
    @Binding var currentView: ContentView.CurrentView

    @State private var showTitle = false
    @State private var showActivitys = false
    
    // Computed property to get the date from the timestamp
    private var lastSelectionDate: Date {
        return Date(timeIntervalSince1970: lastSelectionTimeStamp)
    }
    
    let activities: [Activity] = [
        Activity(emoji: "💪", name: "Gym"),
        Activity(emoji: "📚", name: "Reading"),
        Activity(emoji: "🎹", name: "Practice Piano"),
        Activity(emoji: "🔒", name: "Deep Work"),
        Activity(emoji: "🍎", name: "Eat a Fruit"),
        Activity(emoji: "🚶‍♂️", name: "Go for a Walk"),
        Activity(emoji: "🥛", name: "Drink Water")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 5) {
                    Text("What is going to be your")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 20)
                        .animation(.easeInOut(duration: 1).delay(0.2), value: showTitle)
                    
                    Text("ONE THING TODAY?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 20)
                        .animation(.easeInOut(duration: 1).delay(0.2), value: showTitle)
                }
                
                // Activity options
                VStack(spacing: 8) {
                    ForEach(activities) { activity in
                        ActivityButton(
                            activity: activity,
                            isSelected: Binding(
                                get: { selectedActivity?.id == activity.id },
                                set: { isSelected in
                                    if isSelected {
                                        selectedActivity = activity
                                    } else if selectedActivity?.id == activity.id {
                                        selectedActivity = nil
                                    }
                                }
                            )
                        )
                        .opacity(showActivitys ? 1 : 0)
                        .offset(y: showActivitys ? 0 : 20)
                        .animation(.easeInOut(duration: 1).delay(0.6 + Double(activities.firstIndex(of: activity)!) * 0.1), value: showActivitys)
                    }
                }
                
                Spacer()
                
                // Continue button - only shown when an activity is selected
                if selectedActivity != nil {
                    Button(action: {
                        // Save selection
                        onethingguardmodel.triggerHapticFeedback()
                        selectedOneThingID = selectedActivity?.id.uuidString ?? ""
                        lastSelectionTimeStamp = Date().timeIntervalSince1970
                        
                        // Set currentView to present CameraView
                        if let activity = selectedActivity {
                            currentView = .camera(activity: activity)
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity,  minHeight: 25)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                   
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .onAppear {
                showTitle = true
                showActivitys = true
            }
        }
    }
}


