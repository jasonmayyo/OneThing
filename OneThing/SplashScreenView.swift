import SwiftUI

struct SplashScreenView: View {
    @State private var scribblePoints: [CGPoint] = []
    @State private var isScribbling = false
    @State private var currentScribbleSegmentIndex = 0 // Renamed for clarity
    @State private var actualTotalSegments = 0          // Will be set based on actual points
    // private let totalScribbleSegments = 100 // This will be dynamic now
    private let animationTimer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect() // Faster timer

    @State private var scribbleOrigin: CGPoint = .zero // Will be screen center for the ball
    @State private var scribbleOpacity: Double = 1.0 // For fading out the scribble

    // Placeholder for the final logo (circle)
    @State private var showLogo = false
    @State private var logoScale: CGFloat = 0.01
    @State private var logoOpacity: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.0

    @State private var logoMainGlowRadius: CGFloat = 0
    @State private var logoMainGlowOpacity: Double = 0.0

    @State private var pulseHapticTrigger: Int = 0 // For triggering haptic feedback
    @Binding var isAnimationComplete: Bool // Binding to notify when animation is done

    init(isAnimationComplete: Binding<Bool>) { // Add initializer for the binding
        self._isAnimationComplete = isAnimationComplete
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                // Scribble Path - using Chaikin-like algorithm for smoothing
                Path { path in
                    guard scribblePoints.count >= 2 else {
                        if let p0 = scribblePoints.first { path.move(to: p0) }
                        return
                    }

                    if scribblePoints.count < 3 { // Not enough points for the main curve logic, just draw a line
                        path.move(to: scribblePoints[0])
                        path.addLine(to: scribblePoints[1])
                        return
                    }

                    // Start at the first point
                    path.move(to: scribblePoints[0])
                    // Line to the midpoint of the first segment P0-P1
                    let firstMidPoint = CGPoint(x: (scribblePoints[0].x + scribblePoints[1].x) / 2, y: (scribblePoints[0].y + scribblePoints[1].y) / 2)
                    path.addLine(to: firstMidPoint)

                    // For points P_i, P_{i+1}, P_{i+2}, the curve is from Mid(P_i, P_{i+1}) to Mid(P_{i+1}, P_{i+2}) using P_{i+1} as control.
                    // Loop until the point before the last segment, as we need three points (i, i+1, i+2)
                    for i in 0..<(scribblePoints.count - 2) {
                        let p_control = scribblePoints[i+1] // This is the control point P_{i+1}
                        let p_next_segment_end = scribblePoints[i+2]
                        
                        // The destination of this curve is the midpoint of the segment p_control to p_next_segment_end
                        let midPointNext = CGPoint(x: (p_control.x + p_next_segment_end.x) / 2, y: (p_control.y + p_next_segment_end.y) / 2)
                        path.addQuadCurve(to: midPointNext, control: p_control)
                    }

                    // Line from the last midpoint curve ended at, to the very last point P_n
                    // The last curve ended at Mid(P(n-2), P(n-1)). We need to connect to P(n-1).
                    // (Corrected: last point is scribblePoints.last!, not scribblePoints[count-2])
                    // The loop goes up to i = count - 3.
                    // Last iteration: i = count - 3. p_control = P(count-2), p_next_segment_end = P(count-1).
                    // Curve ends at Mid(P(count-2), P(count-1)).
                    path.addLine(to: scribblePoints.last!)
                }
                .trim(from: 0, to: actualTotalSegments > 0 ? CGFloat(currentScribbleSegmentIndex) / CGFloat(actualTotalSegments) : 0)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .opacity(scribbleOpacity) // Apply opacity to the scribble path
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onAppear {
                    // Scribble ball forms in the center of the screen
                    self.scribbleOrigin = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    // Line starts from the very left edge, vertically centered
                    let leftEdgeStart = CGPoint(x: 0, y: geometry.size.height / 2)
                    
                    self.scribblePoints = [leftEdgeStart, self.scribbleOrigin] // Initial path: edge to center
                    
                    // Generate points for the scribble ball around the center origin
                    let numberOfBallPoints = 50 // Reduced number of points for a shorter, less dense scribble
                    let ballMaxRadius = min(geometry.size.width, geometry.size.height) / 4 // Radius for the ball
                    generateScribblePoints(center: self.scribbleOrigin, count: numberOfBallPoints, maxRadius: ballMaxRadius)
                    
                    self.actualTotalSegments = self.scribblePoints.count > 1 ? self.scribblePoints.count - 1 : 0
                    self.currentScribbleSegmentIndex = 0 // Reset animation index
                    self.scribbleOpacity = 1.0 // Ensure scribble is visible initially
                    self.showLogo = false      // Ensure logo is hidden initially
                    self.logoOpacity = 0.0
                    self.logoScale = 0.01
                    self.pulseScale = 1.0
                    self.pulseOpacity = 0.0
                    self.logoMainGlowRadius = 0 // Reset glow
                    self.logoMainGlowOpacity = 0.0 // Reset glow
                    self.pulseHapticTrigger = 0 // Reset haptic trigger

                    self.isScribbling = true
                }
                .onReceive(animationTimer) { _ in
                    if isScribbling {
                        if self.currentScribbleSegmentIndex < self.actualTotalSegments {
                            self.currentScribbleSegmentIndex += 1
                        } else {
                            isScribbling = false
                            // Start transition to logo
                            withAnimation(.easeIn(duration: 0.5)) {
                                showLogo = true
                                logoOpacity = 1.0
                                logoScale = 1.0
                                scribbleOpacity = 0.0 // Fade out scribble as logo appears
                                // Initial glow appearance
                                logoMainGlowRadius = 10
                                logoMainGlowOpacity = 0.5
                            }
                            // Then start ripple & glow, then shrink
                            startLogoAnimationSequence()
                        }
                    }
                }

                // Logo (Circle for now)
                if showLogo {
                    // Pulse Circle (underneath the main logo)
                    Circle()
                        .fill(Color.white)
                        .frame(width: min(geometry.size.width, geometry.size.height) / 4, height: min(geometry.size.width, geometry.size.height) / 4)
                        .scaleEffect(pulseScale)
                        .opacity(pulseOpacity)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                    // Main Logo Circle
                    Circle()
                        .fill(Color.white)
                        .frame(width: min(geometry.size.width, geometry.size.height) / 4, height: min(geometry.size.width, geometry.size.height) / 4)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .shadow(color: Color.white.opacity(logoMainGlowOpacity), radius: logoMainGlowRadius, x: 0, y: 0)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            .sensoryFeedback(.impact(weight: .heavy), trigger: pulseHapticTrigger) // Heavy vibration on pulse
        }
    }

    func generateScribblePoints(center: CGPoint, count: Int, maxRadius: CGFloat) {
        // 'points' are generated relative to 'center', these will be appended to self.scribblePoints
        // The first point of the ball segment could be considered 'center' itself or points starting around it.
        // This function generates `count` additional points around `center`.
        var localPoints: [CGPoint] = []
        var lastAngle: CGFloat = CGFloat.random(in: 0...(2 * .pi)) // Start with a random angle

        for i in 0..<count {
            // Make radius grow but also have some randomness to fill the "ball"
            let radiusFactor = CGFloat(i + 1) / CGFloat(count) // 0 to 1
            let currentRadius = maxRadius * (0.3 + radiusFactor * 0.7) * (0.8 + CGFloat.random(in: 0...0.4))


            // Ensure the angle changes significantly but not too erratically for a scribble
            let angleChange = CGFloat.random(in: -CGFloat.pi/1.2...CGFloat.pi/1.2) // Wider, more chaotic turns
            lastAngle += angleChange

            // Add some spiraling effect, can be minor for a dense scribble
            let spiralFactor: CGFloat = 0.1 // How much it spirals
            let angle = lastAngle + spiralFactor * CGFloat(i)

            let x = center.x + cos(angle) * currentRadius
            let y = center.y + sin(angle) * currentRadius
            localPoints.append(CGPoint(x: x, y: y))
        }
        self.scribblePoints.append(contentsOf: localPoints)
    }

    func startLogoAnimationSequence() {
        // Logo initial state for this function: scale 1.0, opacity 1.0
        // Glow initial state (set when logo appears): radius 10, opacity 0.5
        // Pulse initial state (will be set during animation): scale 1.0, opacity 0.0

        let firstLogoPopDelay = 0.5 // This delay is from when this function is CALLED.
                                  // Logo and initial glow are already visible.

        let logoRippleDuration1 = 0.3
        let logoRippleDuration2 = 0.2
        let logoSpringDuration = 0.4 // Approximate for spring

        let pulseAppearDuration = 0.2
        let pulseExpandDuration = 1.5
        let pulseInitialOpacity = 0.4
        let targetPulseScale: CGFloat = 15.0 // Large scale for screen coverage

        // 1. Logo Ripple Animation & Glow Intensification
        withAnimation(.easeInOut(duration: logoRippleDuration1).delay(firstLogoPopDelay)) {
            logoScale = 1.2
            logoMainGlowRadius = 20  // Intensify glow
            logoMainGlowOpacity = 0.7 // Intensify glow
        }
        withAnimation(.easeInOut(duration: logoRippleDuration2).delay(firstLogoPopDelay + logoRippleDuration1)) {
            logoScale = 0.9
            // Glow can slightly reduce here or hold
            logoMainGlowRadius = 18
            logoMainGlowOpacity = 0.65
        }
        withAnimation(.spring(response: logoSpringDuration, dampingFraction: 0.4).delay(firstLogoPopDelay + logoRippleDuration1 + logoRippleDuration2)) {
            logoScale = 1.1
            logoMainGlowRadius = 22 // Another bump in glow
            logoMainGlowOpacity = 0.75
        }
        let finalLogoRippleDelay = firstLogoPopDelay + logoRippleDuration1 + logoRippleDuration2 + logoSpringDuration
        withAnimation(.spring(response: logoSpringDuration, dampingFraction: 0.5).delay(finalLogoRippleDelay)) {
            logoScale = 1.0
            logoMainGlowRadius = 15 // Settle glow
            logoMainGlowOpacity = 0.6 // Settle glow
        }

        // 2. Pulse Animation
        // Reset pulse scale and make it appear quickly
        self.pulseScale = 1.0 // Ensure it starts from base size for the animation
        withAnimation(.easeIn(duration: pulseAppearDuration).delay(firstLogoPopDelay)) {
            self.pulseOpacity = pulseInitialOpacity
        }
        // Expand and fade out pulse
        withAnimation(.easeOut(duration: pulseExpandDuration).delay(firstLogoPopDelay + pulseAppearDuration * 0.5)) { // Start expansion slightly into or after appearing
            self.pulseHapticTrigger += 1 // Trigger haptic right as this animation visually starts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.075) { // Second trigger for emphasis
                self.pulseHapticTrigger += 1
            }
            self.pulseScale = targetPulseScale
            self.pulseOpacity = 0.0
        }

        // 3. Hold briefly (after logo ripple settles) & Fade out Glow
        let logoRippleSettleTime = finalLogoRippleDelay + logoSpringDuration // Approximate time logo ripple ends
        let holdDuration = 1.0
        let finalShrinkDelay = logoRippleSettleTime + holdDuration
        let finalShrinkDuration = 0.7

        withAnimation(.easeOut(duration: 0.3).delay(logoRippleSettleTime + holdDuration * 0.5)) { // Start fading glow during hold
            logoMainGlowOpacity = 0.0
            // Optionally, reduce glow radius as well or let it fade with opacity
            // logoMainGlowRadius = 5
        }

        // 4. Shrink and Disappear Logo
        withAnimation(.easeIn(duration: finalShrinkDuration).delay(finalShrinkDelay)) {
            logoScale = 0.01
            logoOpacity = 0.0
        }

        // Notify completion after the last animation is scheduled to start
        DispatchQueue.main.asyncAfter(deadline: .now() + finalShrinkDelay + finalShrinkDuration) {
            self.isAnimationComplete = true
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a constant binding for the preview
        SplashScreenView(isAnimationComplete: .constant(false))
    }
} 
