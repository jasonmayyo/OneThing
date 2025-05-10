//
//  ScanningViewModel.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/09.
//

import SwiftUI

struct ScanResult {
    let isSuccess: Bool
    let confidence: Int
    let activityName: String
    let appName: String
    let analysisDetail: String
    let failureReasons: [String]?
}
