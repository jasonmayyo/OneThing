//
//  CameraViewModel.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/09.
//

import SwiftUI
import AVFoundation

// ViewModel to handle camera operations
class CameraViewModel: ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var capturedImage: UIImage? = nil
    @Published var navigateToScanning: Bool = false
    private var photoOutput = AVCapturePhotoOutput()
    private var photoCaptureDelegate: PhotoCaptureDelegate?

    init() {
        self.photoCaptureDelegate = PhotoCaptureDelegate(viewModel: self)
    }

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera(position: .front)
                    }
                }
            }
        case .denied, .restricted:
            return
        @unknown default:
            return
        }
    }
    
    func setupCamera(position: AVCaptureDevice.Position) {
        session.beginConfiguration()
        
        // Remove existing inputs
        if let inputs = session.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                session.removeInput(input)
            }
        }
        
        // Configure the capture device
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            print("Failed to get camera device")
            session.commitConfiguration()
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
            session.commitConfiguration()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        if let delegate = self.photoCaptureDelegate {
            photoOutput.capturePhoto(with: settings, delegate: delegate)
        } else {
            print("Error: PhotoCaptureDelegate not initialized.")
        }
    }
}
