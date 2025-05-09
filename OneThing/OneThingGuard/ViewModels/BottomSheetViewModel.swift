//
//  BottomSheetViewModel.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/09.
//

import SwiftUI
import Combine 
import UIKit

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
