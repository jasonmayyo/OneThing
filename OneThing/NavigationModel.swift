import Foundation
import SwiftUI

enum NavigationDestination {
    case oneThingView
    case oneThingGuardFlowView
}

class NavigationModel: ObservableObject {
    static let shared = NavigationModel()
    
    @Published var currentDestination: NavigationDestination? = nil
    
    private init() {}
    
    func navigate(to destination: NavigationDestination) {
        self.currentDestination = destination
    }
} 
