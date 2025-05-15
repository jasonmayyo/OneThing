//
//  MainTabView.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/11.
//

import SwiftUI

enum MainTab {
    case home, blocks, profile
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        HStack(spacing: 0) {
            tabBarItem(tab: .home, icon: "circle", label: "Home")
            tabBarItem(tab: .blocks, icon: "lock.fill", label: "Blocks")
            tabBarItem(tab: .profile, icon: "person.crop.circle", label: "Profile")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(.black).ignoresSafeArea(edges: .bottom))
        .overlay(Divider().background(Color.white.opacity(0.08)), alignment: .top)
    }

    @ViewBuilder
    private func tabBarItem(tab: MainTab, icon: String? = nil, customIcon: AnyView? = nil, label: String) -> some View {
        Button(action: {
            if selectedTab != tab {
                haptic.prepare()
                haptic.impactOccurred()
                selectedTab = tab
            }
        }) {
            VStack(spacing: 2) {
                if let customIcon = customIcon {
                    customIcon
                        .foregroundColor(selectedTab == tab ? Color.white : Color.white.opacity(0.7))
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? Color.white : Color.white.opacity(0.7))
                }
                Text(label)
                    .font(.caption2)
                    .foregroundColor(selectedTab == tab ? Color.white : Color.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .blocks:
                    BlockView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 70)
            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    MainTabView()
} 
