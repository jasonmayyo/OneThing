//
//  OneThingGuardModel.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/02.
//

import SwiftUI
import UIKit


class OneThingGuardModel: ObservableObject {
    init() {}
    
    // Function to trigger haptic feedback
    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare() // Prepare the generator for better responsiveness
        generator.impactOccurred()
    }
}
