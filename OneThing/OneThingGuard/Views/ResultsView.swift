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
    @State private var showContent: Bool = false
    
    // Haptic Engine
    @State private var hapticGenerator: UIImpactFeedbackGenerator? = nil
    
    // State for animations
    @State private var startSuccessAnimation: Bool = false // Consolidated animation trigger
    @State private var dayStreak: Int = 3 // Placeholder for streak data
    
    var body: some View {
        ZStack {
            // Background Color
            Color.black.ignoresSafeArea()
            
            if isSuccess {
                // --- Success View --- 
                VStack() {
                    Spacer()
                    
                    // Fire Emoji
                    Text("🔥")
                        .font(.system(size: 150))
                        .scaleEffect(startSuccessAnimation ? 1 : 0.1)
                        .rotationEffect(startSuccessAnimation ? .degrees(0) : .degrees(-20))
                        .opacity(startSuccessAnimation ? 1 : 0)
                        .shadow(color: .orange.opacity(0.7), radius: startSuccessAnimation ? 85 : 0, x: 0, y: 0)
                        .animation(.interpolatingSpring(stiffness: 100, damping: 10).delay(0.2), value: startSuccessAnimation)
                    
                    VStack(spacing: 0) {
                        // Day Streak Number
                        Text("\(dayStreak)") // Use streak variable
                            .font(.system(size: 80, weight: .black))
                            .foregroundColor(.white)
                            .padding(.bottom, -10) // Apply negative bottom padding
                            .opacity(startSuccessAnimation ? 1 : 0)
                            .offset(y: startSuccessAnimation ? 0 : 20)
                            .animation(.easeInOut(duration: 0.6).delay(0.4), value: startSuccessAnimation)
                        
                        // Day Streak Label
                        Text("DAY STREAK")
                            .font(.title)
                            .foregroundColor(.white)
                            .bold()
                            .opacity(startSuccessAnimation ? 1 : 0)
                            .offset(y: startSuccessAnimation ? 0 : 20)
                            .animation(.easeInOut(duration: 0.6).delay(0.5), value: startSuccessAnimation)
                    }
                    
                    
                    Spacer()
                    
                    // Contribution Grid
                    contributionGridView()
                        .padding(.horizontal, 20)
                        .opacity(startSuccessAnimation ? 1 : 0)
                        .offset(y: startSuccessAnimation ? 0 : 20)
                        .animation(.easeInOut(duration: 0.6).delay(0.6), value: startSuccessAnimation)
                        
                    Spacer()
                    Spacer()
                    
                    // Unlock Button (Same as before, just styled)
                    HStack {
                        Spacer()
                        Button(action: {
                            print("Unlock \(appName)")
                            let currentTime = Date().timeIntervalSince1970
                            let sharedDefaults = UserDefaults(suiteName: "group.com.jasonmayo.OneThingApp")
                            sharedDefaults?.set(currentTime, forKey: "LastBreakTime")
                            sharedDefaults?.set(true, forKey: "UserAllowedBreak")
                            sharedDefaults?.synchronize()
                            
                            if let appName = sharedDefaults?.string(forKey: "LastGuardedApp") {
                                UIApplication.shared.open(getAppURL(for: appName), options: [:])
                            }
                            // Dismiss view? Decide navigation
                            // currentView = .someOtherView // Or maybe dismiss if presented modally
                        }) {
                            Text("Unlock \(appName)")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }.padding()
                    
                }
                .onAppear {
                    // Tiny delay ensures view is ready before animating
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        startSuccessAnimation = true
                    }
                } 
                 
            } else {
                // --- New Failure View --- 
                VStack() {
                    Text("Caught You!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeInOut(duration: 1.5).delay(0.2), value: showContent)
                        .padding(.top)
                    
                    Text("You're not doing your one thing. And that's a problem.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeInOut(duration: 1.5).delay(0.3), value: showContent)
                        .padding(.bottom, 30)
                    
                    
                    VStack() {
                        
                           
                        
                        // Placeholder reasons list
                        let reasons = [
                            "No sweat. No reps. No movement.",
                            "Your heart rate is Netflix, not cardio.",
                            "We see a couch, those don't build muscle.",
                            "We checked the background. Zero gym vibes.",
                            "We see pillows, not progress.",
                            "You dont have any gym wear on.",
                            "You're not even sweating.",
                        ]
                        
                        ForEach(reasons.indices, id: \.self) { index in
                            let reason = reasons[index]
                            HStack(spacing: 12) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                    // Red glow effect
                                    .shadow(color: .red.opacity(0.8), radius: 8)
                                    
                                Text(reason)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(10)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            // Stagger animation based on index
                            .animation(.easeInOut(duration: 3).delay(0.4 + Double(index) * 2), value: showContent)
                            .onAppear { // Add onAppear to each reason HStack
                                // Calculate the delay for this specific item
                                let delay = 0.4 + Double(index) * 2
                                // Schedule haptic feedback to occur when animation starts
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    self.hapticGenerator?.impactOccurred()
                                }
                            }
                        }
                        
                        
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    Text("But you thought we wouldn't notice")
                        .font(.headline)
                        .foregroundColor(.white)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        // Delay until after last reason (index 6) fades in
                        .animation(.easeInOut(duration: 3).delay(15.5), value: showContent)
                    // Retake Photo Button
                    HStack {
                        Spacer()
                        Button(action: {
                            print("Retake Photo")
                            if let activity = findActivity(byName: activityName) {
                                 currentView = .camera(activity: activity)
                            } else {
                                print("Error: Could not find activity named \(activityName)")
                                currentView = .oneThingPicker
                            }
                        }) {
                            Text("Retake Photo")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        // Delay until after the text above fades in
                        .animation(.easeInOut(duration: 3).delay(15.7), value: showContent)
                        Spacer()
                    }.padding(.horizontal)
                        .padding(.bottom)
                    
                }
                .onAppear { 
                    showContent = true // Trigger animations
                    // Prepare haptic generator only once when the failure view appears
                    if hapticGenerator == nil {
                        hapticGenerator = UIImpactFeedbackGenerator(style: .soft) // Use .soft for a gentle tap
                        hapticGenerator?.prepare()
                    }
                }
            }
        }
    }
    
    // --- Helper View for Contribution Grid ---
    @ViewBuilder
    private func contributionGridView() -> some View {
        // Define grid layout for 90 cells (14 columns for ~2 weeks per row)
        let totalCells = 90 // Approx 3 months
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 14) // 14 columns, small column spacing
        
        VStack(alignment: .leading, spacing: 6) { // Add spacing for title
            Text("3 months of doing that One Thing")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 5) // Align roughly with grid start
                .padding(.bottom, 5)
        
            LazyVGrid(columns: columns, spacing: 2) { // Slightly larger row spacing
                ForEach(0..<totalCells, id: \.self) { index in
                    Rectangle()
                        // Color based on index (simulate first few days filled)
                        .fill(index < dayStreak ? Color.white.opacity(0.9) : Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit) // Use aspect ratio to fill flexible width
                        .cornerRadius(2) // Restore corner radius
                }
            }
        }
        .padding(15) // Keep padding AROUND the outer VStack
        .background(
            RoundedRectangle(cornerRadius: 10) // Rounded background shape
                .fill(Color.gray.opacity(0.15)) // Darker gray background
        )
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

#Preview {
    // Preview both states
    Group {
        // Success Case Preview
        ResultsView(isSuccess: false, confidence: 18, activityName: "gyming", appName: "Instagram", currentView: .constant(.oneThingPicker))

        
    }
}
