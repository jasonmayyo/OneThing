//
//  PhotoCaptureDelegate.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/09.
//

import SwiftUI
import AVFoundation

// Delegate for handling photo capture
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    weak var viewModel: CameraViewModel?

    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error getting image data")
            return
        }
        
        if var image = UIImage(data: imageData) {
            // Check if the image was taken with front camera and needs flipping
            
                // Flip the image horizontally to match the preview
                image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
            
            
            DispatchQueue.main.async {
                self.viewModel?.capturedImage = image
                self.viewModel?.navigateToScanning = true
            }
        }
    }
}


