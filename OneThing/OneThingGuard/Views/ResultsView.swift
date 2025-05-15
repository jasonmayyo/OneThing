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

    // NEW: To hold data from GPTVisionService
    var analysisDetail: String
    var failureReasons: [String]?

    @State private var showContent: Bool = false
    
    // Haptic Engine
    @State private var hapticGenerator: UIImpactFeedbackGenerator? = nil
    
    // State for animations
    @State private var startSuccessAnimation: Bool = false // Consolidated animation trigger
    @State private var dayStreak: Int = 3 // Placeholder for streak data
    
    // Add new animation states
    @State private var flameScale: CGFloat = 0.1
    @State private var flameOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0
    @State private var showFinalContent: Bool = false
    
    // Add new animation states for vibration
    @State private var flameRotation: Double = 0
    @State private var flameVibration: Bool = false
    
    var body: some View {
        ZStack {
            // Background Color
            Color.black.ignoresSafeArea()
            
            if isSuccess {
                // --- Success View --- 
                ZStack {
                    // Pulse Effect (Full Screen)
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.orange.opacity(0.8),
                                    Color.orange.opacity(0.4),
                                    Color.orange.opacity(0.0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .scaleEffect(pulseScale)
                        .opacity(pulseOpacity)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        .opacity(showFinalContent ? 0 : 1)
                    
                    // Initial Flame View
                    if !showFinalContent {
                        Text("🔥")
                            .font(.system(size: 150))
                            .scaleEffect(flameScale)
                            .rotationEffect(.degrees(flameScale == 1 ? 0 : -20))
                            .opacity(flameOpacity)
                            .shadow(color: .orange.opacity(0.7), radius: flameScale == 1 ? 85 : 0)
                    }
                    
                    // Final Content
                    VStack {
                        if showFinalContent {
                            Spacer()
                            
                            // Final Flame
                            Text("🔥")
                                .font(.system(size: 120))
                                .shadow(color: .orange.opacity(0.7), radius: 40)
                                .opacity(showFinalContent ? 1 : 0)
                                .offset(y: showFinalContent ? 0 : 20)
                            
                            // Day Streak Number
                            Text("\(dayStreak)")
                                .font(.system(size: 80, weight: .black))
                                .foregroundColor(.white)
                                .padding(.bottom, -10)
                                .opacity(showFinalContent ? 1 : 0)
                                .offset(y: showFinalContent ? 0 : 20)
                            
                            // Day Streak Label
                            Text("DAY STREAK")
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                                .opacity(showFinalContent ? 1 : 0)
                                .offset(y: showFinalContent ? 0 : 20)
                            
                            Spacer()
                            
                            // Contribution Grid
                            contributionGridView()
                                .padding(.horizontal, 20)
                                .opacity(showFinalContent ? 1 : 0)
                                .offset(y: showFinalContent ? 0 : 20)
                            
                            Spacer()
                            Spacer()
                            
                            // Unlock Button
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

                                    NavigationModel.shared.navigate(to: .oneThingView)
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
                                .opacity(showFinalContent ? 1 : 0)
                                Spacer()
                            }
                            .padding()
                            .opacity(showFinalContent ? 1 : 0)
                        }
                    }
                }
                .onAppear {
                    // Prepare haptic generator
                    hapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
                    hapticGenerator?.prepare()
                    
                    // Initial flame animation
                    withAnimation(.interpolatingSpring(stiffness: 100, damping: 10).delay(0.2)) {
                        flameScale = 1.0
                        flameOpacity = 1.0
                    }
                    
                    // Trigger haptic feedback when pulse begins
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        hapticGenerator?.impactOccurred(intensity: 1.0)
                    }
                    
                    // Quick pulse animation
                    withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                        pulseScale = 3.0
                        pulseOpacity = 0.8
                    }
                    
                    // Start slow fade out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeOut(duration: 0.8)) {
                            flameOpacity = 0
                        }
                    }
                    
                    // Show final content after animations
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            showFinalContent = true
                        }
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
                        // Use the dynamic analysisDetail from GPTVisionService
                        .overlay(Text(self.analysisDetail)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    .opacity(showContent ? 1 : 0)
                                    .offset(y: showContent ? 0 : 20)
                                    .animation(.easeInOut(duration: 1.5).delay(0.3), value: showContent)
                        )
                        .opacity(0) // Keep original text, but hide it, overlay new one for animation
                        .padding(.bottom, 30)
                    
                    
                    VStack() {
                        
                           
                        // Use actual failureReasons from GPTVisionService
                        let actualReasonsToShow = self.failureReasons ?? []
                        
                        // Placeholder reasons list
                        // let reasons = [
                        //     "No sweat. No reps. No movement.",
                        //     "Your heart rate is Netflix, not cardio.",
                        //     "We see a couch, those don't build muscle.",
                        //     "We checked the background. Zero gym vibes.",
                        //     "We see pillows, not progress.",
                        //     "You dont have any gym wear on.",
                        //     "You're not even sweating.",
                        // ]
                        
                        ForEach(actualReasonsToShow.indices, id: \.self) { index in
                            let reason = actualReasonsToShow[index]
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
            Text("Goal: 3 months of doing One Thing daily")
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
        ResultsView(isSuccess: true, 
                    confidence: 85, 
                    activityName: "Reading", 
                    appName: "YouTube", 
                    currentView: .constant(.oneThingPicker),
                    analysisDetail: "The user appears to be holding a book and focusing.",
                    failureReasons: nil)

    }
}
