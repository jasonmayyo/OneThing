import SwiftUI

struct SplashScreenView: View {
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

    init(isAnimationComplete: Binding<Bool>) {
        self._isAnimationComplete = isAnimationComplete
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                // Only show the logo and pulse (no scribble)
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
            .onAppear {
                // Immediately show the logo and start the animation sequence
                self.showLogo = true
                self.logoOpacity = 1.0
                self.logoScale = 1.0
                self.pulseScale = 1.0
                self.pulseOpacity = 0.0
                self.logoMainGlowRadius = 10
                self.logoMainGlowOpacity = 0.5
                self.pulseHapticTrigger = 0
                startLogoAnimationSequence()
            }
            .sensoryFeedback(.impact(weight: .heavy), trigger: pulseHapticTrigger)
        }
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
