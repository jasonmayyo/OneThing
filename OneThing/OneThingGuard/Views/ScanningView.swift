import SwiftUI
import Combine // Import Combine for ObservableObject
import UIKit // Needed for UIImage and Haptics


// Your main view
struct ScanningPlaceholderView: View {
    // The image to be displayed in the background
    var image: UIImage?
    var activity: Activity
    
    // Binding for navigation state
    @Binding var currentView: ContentView.CurrentView

    // State variables for the scanning dots animation
    @State private var scanningDots: [ScanDot] = []
    
    // Use @StateObject to create and keep the ViewModel alive
    @StateObject private var bottomSheetViewModel = BottomSheetViewModel()

    // Store the dot timer cancellable instance to manage its lifecycle
    @State private var dotTimerCancellable: Timer?

    // State for pulsing animation of the green dot
    @State private var pulseAnimation: Bool = false
    
    // Haptic Engine
    @State private var hapticGenerator: UIImpactFeedbackGenerator? = nil

    var body: some View {
        ZStack {
            // Image area
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
                
                // Draw Dots and Ripples together
                ForEach(scanningDots) { dot in
                    // Use ZStack for layering: Ripple behind Dot
                    ZStack {
                        // The infinite ripple effect
                        RippleView(position: dot.position)
                        
                        // The static white dot
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .position(dot.position)
                            .opacity(dot.opacity) // Still allow dot opacity to change if needed
                            .animation(.easeInOut(duration: 0.4), value: dot.opacity)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Make sure image ZStack fills the space
            .ignoresSafeArea() // Allow image to go edge-to-edge

            // --- Status Bar --- 
            VStack {
                HStack(spacing: 15) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .scaleEffect(pulseAnimation ? 1.25 : 1.0)

                    Text(bottomSheetViewModel.currentMessage)
                        .font(.body)
                        .foregroundColor(.white)
                        .id("status_\(bottomSheetViewModel.currentMessageIndex)")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(.black.opacity(0.4)))
                Spacer()
            }.padding(.top)
            // --- End Status Bar --- 
        }
        .onAppear {
            startScanningAnimation()
            bottomSheetViewModel.startTimer()
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulseAnimation.toggle()
            }
            // Prepare haptics
            if hapticGenerator == nil {
                hapticGenerator = UIImpactFeedbackGenerator(style: .light) // .light is subtle
                hapticGenerator?.prepare()
            }
            analyzeImageWithGPT()
        }
        .onDisappear {
             stopScanningAnimation()
             // ViewModel deinit handles its timer
        }
    }

    // Start the scanning animation
    private func startScanningAnimation() {
        scanningDots.removeAll()
        dotTimerCancellable?.invalidate()
        
        addRandomDots(count: 0)
        
        dotTimerCancellable = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
             withAnimation(.easeInOut(duration: 0.5)) {
                self.addRandomDots(count: 1)
                if self.scanningDots.count > 15 {
                    self.scanningDots.removeFirst(1)
                }
                for i in 0..<self.scanningDots.count {
                    self.scanningDots[i].opacity = Double.random(in: 0.3...0.9)
                }
            }
        }
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
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height - 150 // Approximate
            let randomX = CGFloat.random(in: 20...(screenWidth - 20))
            let randomY = CGFloat.random(in: 20...(screenHeight > 20 ? screenHeight : 20))
            let position = CGPoint(x: randomX, y: randomY)
            
            let newDot = ScanDot(position: position, opacity: 1.0)
            scanningDots.append(newDot)
            
            // Trigger haptic feedback
            hapticGenerator?.impactOccurred(intensity: 0.7) // Adjust intensity (0.0 to 1.0)
        }
    }

    // Add a function to send the image to GPT for analysis
    private func analyzeImageWithGPT() {
        guard let image = image else { return }
        
        Task {
            do {
                let (confidence, description) = try await GPTVisionService.shared.analyzeImage(image, activity: activity.name)
                DispatchQueue.main.async {
                    currentView = .results(isSuccess: confidence > 50, confidence: confidence, activityName: activity.name, appName: "OneThing")
                }
            } catch {
                print("Error analyzing image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    currentView = .results(isSuccess: false, confidence: 0, activityName: activity.name, appName: "OneThing")
                }
            }
        }
    }
}

// Updated View for the animated ripple effect
struct RippleView: View {
    let position: CGPoint // Pass position directly
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0.75 // Start slightly transparent
    
    var body: some View {
        Circle()
            .stroke(Color.white.opacity(0.8), lineWidth: 1) // Thinner, slightly transparent stroke
            .scaleEffect(scale)
            .opacity(opacity)
            .frame(width: 10, height: 10) // Base size like the CSS
            .position(position)
            .onAppear { // Animate on appear
                // Use the specific repeating animation from CSS
                withAnimation(.easeOut(duration: 1).repeatForever(autoreverses: false)) {
                    scale = 5.0 // Target scale (50/10)
                    opacity = 0.0 // Target opacity
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
    let id = UUID()
    let position: CGPoint
    var opacity: Double
}

// Updated Preview provider
struct ScanningPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        // Example activity for preview
        let previewActivity = Activity(emoji: "📚", name: "Reading")
        // Safely unwrap the placeholder image
        if let previewImage = UIImage(systemName: "photo") {
            ScanningPlaceholderView(
                image: previewImage, 
                activity: previewActivity,
                // Provide a constant binding with the non-nil image
                currentView: .constant(.scanning(image: previewImage, activity: previewActivity))
            )
            .preferredColorScheme(.dark)
        } else {
            Text("Error: Could not load preview image.")
        }
    }
}

