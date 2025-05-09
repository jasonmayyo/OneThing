import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var animate: Bool = false
    @State private var showScanningView = false
    @EnvironmentObject var onethingguardmodel: OneThingGuardModel
    
    // Add parameters for selectedActivity and currentView
    var selectedActivity: Activity
    @Binding var currentView: ContentView.CurrentView

    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()
            
            // Glass/blur effect overlay with cutout for scanner area
            BlurBackgroundView(animate: $animate)
                .ignoresSafeArea()
            
            // UI Elements
            VStack {
                // Top text
                Text("TIME TO SHOW SOME EVIDENCE 📸")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Text("\(selectedActivity.emoji) \(selectedActivity.name)")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.2))
                    )
                
                Spacer()
                
                // Camera button
                Button(action: {
                    viewModel.capturePhoto()
                    onethingguardmodel.triggerHapticFeedback()
                }) {
                    ZStack {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                    }
                }
                .padding(.bottom, 50)
                
            }.padding(.top, 30)
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.checkPermissions()
            viewModel.setupCamera(position: .front)
            
            // Start animation timer
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.9)) {
                    animate.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.navigateToScanning) {
            if let image = viewModel.capturedImage {
                ScanningPlaceholderView(image: image, activity: selectedActivity, currentView: $currentView)
            }
        }
        .onChange(of: viewModel.navigateToScanning) { newValue in
            showScanningView = newValue
        }
    }
}

struct BlurBackgroundView: View {
    @Binding var animate: Bool
    
    // Dynamic size calculations
    private var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    private var baseWidth: CGFloat {
        screenSize.width * 0.90
    }
    
    private var baseHeight: CGFloat {
        screenSize.height * 0.67
    }
    
    private var animatedWidth: CGFloat {
        baseWidth * 1.02
    }
    
    private var animatedHeight: CGFloat {
        baseHeight * 1.02
    }
    
    var body: some View {
        ZStack {
            // Create the blur effect with a cutout for the scanner area
            ZStack {
                // Background blur for the entire screen
                Rectangle()
                    .fill(.ultraThinMaterial).opacity(0.7)
                    
                
                // Cutout for the scanner area
                Rectangle()
                    .frame(width: animate ? animatedWidth : baseWidth,
                           height: animate ? animatedHeight : baseHeight)
                    .blendMode(.destinationOut)
                    .cornerRadius(20)
            }
            .compositingGroup()
            .ignoresSafeArea()
            
            // Scanner area corners
            ScannerAreaView(animate: $animate)
        }
    }
}

struct ScannerAreaView: View {
    @Binding var animate: Bool
    
    // Dynamic size calculations
    private var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    private var baseWidth: CGFloat {
        screenSize.width * 0.75
    }
    
    private var baseHeight: CGFloat {
        screenSize.height * 0.6
    }
    
    private var animatedWidth: CGFloat {
        baseWidth * 1.02
    }
    
    private var animatedHeight: CGFloat {
        baseHeight * 1.02
    }

    var body: some View {
        ZStack {
            // Cutout rectangle
            Rectangle()
                .blendMode(.destinationOut)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: animate ? animatedWidth : baseWidth,
                       height: animate ? animatedHeight : baseHeight)
            
            // Corner elements - fixed positioning
            Group {
                // Top Left Corner
                EdgeRectangleView(animate: $animate)
                    .rotationEffect(.degrees(180))
                    .position(x: animate ? 10 : 10, y: animate ? 10 : 10)
                    
                
                // Top Right Corner
                EdgeRectangleView(animate: $animate)
                    .rotationEffect(.degrees(270))
                    .position(x: animate ? animatedWidth - 10 : baseWidth - 10, y: animate ? 10 : 10)
                
                // Bottom Right Corner
                EdgeRectangleView(animate: $animate)
                    .rotationEffect(.degrees(0))
                    .position(x: animate ? animatedWidth - 10 : baseWidth - 10, y: animate ? animatedHeight - 10 : baseHeight - 10)
                
                // Bottom Left Corner
                EdgeRectangleView(animate: $animate)
                    .rotationEffect(.degrees(90))
                    .position(x: animate ? 10 : 10, y: animate ? animatedHeight - 10 : baseHeight - 10)
            }
        }
        .compositingGroup()
        .frame(width: animate ? animatedWidth : baseWidth, height: animate ? animatedHeight : baseHeight)
        .animation(.easeInOut(duration: 0.9), value: animate)
    }
}

struct EdgeRectangleView: View {
    @Binding var animate: Bool
    
    var body: some View {
        // Modified to only show partial strokes for corners
        RoundedRectangle(cornerRadius: 20)
            .trim(from: 0, to: 0.25) // Only show quarter of the rectangle for corner effect
            .stroke(
                Color.white,
                style: StrokeStyle(
                    lineWidth: 6,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(width: 80, height: 80) // Slightly larger to make corners more visible
    }
}

// Camera preview using UIViewRepresentable
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}



