import SwiftUI
import Combine // Import Combine for ObservableObject

// ViewModel to manage the state and timer for the BottomSheet
class BottomSheetViewModel: ObservableObject {
    // Array of status messages to cycle through
    let statusMessages = ["Processing image...", "Analyzing details...", "Processing image...",
                          "Scanning...", "Detecting objects...", "Finalizing results...",
                          "Loading results...", "Almost done..."]

    // Published property to hold the current message index
    // SwiftUI views observing this object will update when this changes
    @Published var currentMessageIndex = 0

    // Store the timer cancellable instance
    private var timerCancellable: AnyCancellable?

    init() {
        startTimer()
    }

    func startTimer() {
        // Invalidate existing timer if any
        timerCancellable?.cancel()

        // Create and start the timer using Timer.publish
        timerCancellable = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                // Update the index, wrapping around the array count
                self.currentMessageIndex = (self.currentMessageIndex + 1) % self.statusMessages.count
                 print("Timer fired: New index \(self.currentMessageIndex)") // Debug print
            }
    }

    // Make sure to cancel the timer when the ViewModel is deinitialized
    deinit {
        print("BottomSheetViewModel deinit, cancelling timer.")
        timerCancellable?.cancel()
    }

    // Computed property to easily get the current message
    var currentMessage: String {
        // Basic bounds check, though modulus should prevent out-of-bounds
        guard currentMessageIndex >= 0 && currentMessageIndex < statusMessages.count else {
            return "Loading..." // Fallback message
        }
        return statusMessages[currentMessageIndex]
    }
}


// Your main view
struct ScanningPlaceholderView: View {
    // The image to be displayed in the background
    var image: UIImage?
    var activity: Activity
    
    // Add a binding for currentView
    @Binding var currentView: ContentView.CurrentView

    // State variables for the scanning dots animation
    @State private var scanningDots: [ScanDot] = []
    // Use @StateObject to create and keep the ViewModel alive
    // It will persist even if ScanningPlaceholderView is recreated
    @StateObject private var bottomSheetViewModel = BottomSheetViewModel()

    // Store the dot timer cancellable instance to manage its lifecycle
    @State private var dotTimerCancellable: Timer?

    // State for pulsing animation of the green dot
    @State private var pulseAnimation: Bool = false

    var body: some View {
        ZStack {
            // Image area with scan dots - Now the base layer
            ZStack {
                // Background image or gray placeholder
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it fills
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.8))
                }

                // Scanning dots
                ForEach(scanningDots) { dot in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .position(dot.position)
                        .opacity(dot.opacity)
                        // Add animation for opacity changes
                        .animation(.easeInOut(duration: 0.4), value: dot.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Make sure image ZStack fills the space
            .ignoresSafeArea() // Allow image to go edge-to-edge

            VStack {
                HStack(spacing: 15) {
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .scaleEffect(pulseAnimation ? 1.25 : 1.0) // Apply pulsing effect

                    // Text displaying the current status message from the ViewModel
                    Text(bottomSheetViewModel.currentMessage) // Use the ViewModel directly
                        .font(.body)
                        .foregroundColor(.white) // Change text to white
                        // Ensure text updates smoothly
                        .id("status_\(bottomSheetViewModel.currentMessageIndex)") // Use .id

                  
                }
                .padding(.horizontal, 20) // Reduced horizontal padding for capsule
                .padding(.vertical, 10) // Reduced vertical padding for capsule
                // Background for the sheet
                .background(
                    Capsule()
                        .fill(.black.opacity(0.4)) // Semi-transparent black capsule
                )
                Spacer()
            }

            
                
            

        }
        .onAppear {
            startScanningAnimation()
            // Ensure the bottom sheet timer is running (it starts on init, but good practice)
             bottomSheetViewModel.startTimer()

            // Start the pulsing animation
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulseAnimation.toggle()
            }
            
            // Start the image analysis
            analyzeImageWithGPT()
        }
        .onDisappear {
             // Stop the dot timer when the view disappears
             stopScanningAnimation()
             // ViewModel's deinit will handle its timer cancellation
        }
    }

    // Start the scanning animation
    private func startScanningAnimation() {
        // Clear existing dots
        scanningDots.removeAll()
        // Invalidate previous timer if exists
        dotTimerCancellable?.invalidate()

        // Add initial dots
        addRandomDots(count: 5) // Start with a few dots

        // Add dots periodically
        dotTimerCancellable = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
             withAnimation(.easeInOut(duration: 0.5)) {
                // Add new dots
                self.addRandomDots(count: 1)

                // Remove old dots if there are too many
                if self.scanningDots.count > 15 {
                    self.scanningDots.removeFirst(1)
                }

                // Update opacity for dots animation (fade effect)
                for i in 0..<self.scanningDots.count {
                    // Make older dots slightly dimmer maybe? Or just random.
                    self.scanningDots[i].opacity = Double.random(in: 0.3...0.9)
                }
            }
        }
         // Ensure the timer runs on the main loop for UI updates
         if let timer = dotTimerCancellable {
              RunLoop.current.add(timer, forMode: .common)
         }
    }

     // Stop the scanning animation timer
    private func stopScanningAnimation() {
        dotTimerCancellable?.invalidate()
        dotTimerCancellable = nil
        print("Dot timer stopped.")
    }

    // Add random dots to the scan area
    private func addRandomDots(count: Int) {
        for _ in 0..<count {
            // Use GeometryReader or screen bounds carefully
            // UIScreen.main.bounds might not be accurate in all contexts (like split view)
            // For full screen, it's generally okay.
            let screenWidth = UIScreen.main.bounds.width
            // Adjust height calculation - maybe subtract bottom sheet height estimate?
            let screenHeight = UIScreen.main.bounds.height - 150 // Approximate available height

            let randomX = CGFloat.random(in: 20...(screenWidth - 20))
            // Ensure Y stays within the visible area above the sheet
            let randomY = CGFloat.random(in: 20...(screenHeight > 20 ? screenHeight : 20))

            let newDot = ScanDot(
                id: UUID(),
                position: CGPoint(x: randomX, y: randomY),
                opacity: 1.0 // Start fully opaque, timer loop will adjust
            )

            scanningDots.append(newDot)
        }
    }

    // Add a function to send the image to GPT for analysis
    private func analyzeImageWithGPT() {
        guard let image = image else { return }
        
        Task {
            do {
                // Call the GPTVisionService to analyze the image
                let (confidence, description) = try await GPTVisionService.shared.analyzeImage(image, activity: activity.name)
                
                // Navigate to ResultsView on the main thread
                DispatchQueue.main.async {
                    // Assuming currentView is passed as a binding
                    currentView = .results(isSuccess: confidence > 50, confidence: confidence, activityName: activity.name, appName: "OneThing")
                }
            } catch {
                // Handle error
                print("Error analyzing image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    // Navigate to ResultsView with failure
                    currentView = .results(isSuccess: false, confidence: 0, activityName: activity.name, appName: "OneThing")
                }
            }
        }
    }
}

// Your RoundedCorner Shape remains the same
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Data structure for scanning dots
struct ScanDot: Identifiable {
    let id: UUID
    let position: CGPoint
    var opacity: Double
}

