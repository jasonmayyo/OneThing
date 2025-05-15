//
//  OneThingGuardFlowView.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/15.
//

import SwiftUI

struct OneThingGuardFlowView: View {
    @State private var currentView: ContentView.CurrentView = .oneThingPicker
    
    var body: some View {
        VStack {
            switch currentView {
            case .oneThingPicker:
                OneThingPickerView(currentView: $currentView)
            case .camera(let activity):
                CameraView(selectedActivity: activity, currentView: $currentView)
            case .scanning(let image, let activity):
                ScanningPlaceholderView(image: image, activity: activity, currentView: $currentView)
            case .results(let isSuccess, let confidence, let activityName, let appName, let analysisDetail, let failureReasons):
                ResultsView(
                    isSuccess: isSuccess,
                    confidence: confidence,
                    activityName: activityName,
                    appName: appName,
                    currentView: $currentView,
                    analysisDetail: analysisDetail,
                    failureReasons: failureReasons
                )
            }
        }
    }
}

#Preview {
    OneThingGuardFlowView()
        .environmentObject(OneThingGuardModel())
}
