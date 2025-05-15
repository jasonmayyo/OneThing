//
//  ProfileView.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/11.
//

import SwiftUI

struct ProfileView: View {
    // Example data
    let guardedApps = ["Instagram", "YouTube", "TikTok", "Reddit"]
    let streak = 7
    let completedCount = 23
    let appVersion = "1.0.0"
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Title
                    Text("Profile")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .padding(.top, 24)
                        .padding(.horizontal)

                    // Stats Card
                    HStack(spacing: 0) {
                        profileStat(icon: "lock", value: "4", label: "Guarded Apps")
                        Divider().frame(height: 60).background(Color.white.opacity(0.1))
                        profileStat(icon: "flame.fill", value: String(streak), label: "Streak")
                        Divider().frame(height: 60).background(Color.white.opacity(0.1))
                        profileStat(icon: "checkmark.seal.fill", value: String(completedCount), label: "Completed")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(24)
                    .padding(.horizontal)

                    // Guarded Apps Row
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Guarded Apps")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack(spacing: 12) {
                            ForEach(guardedApps, id: \.self) { app in
                                Image(app)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color.white.opacity(0.08)))
                            }
                            Spacer()
                            Text("\(guardedApps.count) apps")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // One Thing Completed
                    VStack(alignment: .leading, spacing: 8) {
                        Text("One Thing Completed")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("\(completedCount) times")
                                .foregroundColor(.white)
                                .font(.body)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // Notifications
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                            Text("Reminders enabled")
                                .foregroundColor(.white)
                                .font(.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // Account
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account")
                            .font(.headline)
                            .foregroundColor(.white)
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("Upgrade to Pro")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing)
                                    .opacity(0.7)
                            )
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)

                    // Help & Legal
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Help & Legal")
                            .font(.headline)
                            .foregroundColor(.white)
                        profileLinkRow(icon: "questionmark.circle", label: "FAQs")
                        profileLinkRow(icon: "exclamationmark.triangle", label: "Report an Error")
                        profileLinkRow(icon: "doc.text", label: "Terms of Use")
                        profileLinkRow(icon: "hand.raised", label: "Privacy Policy")
                    }
                    .padding(.horizontal)

                    // App Version
                    HStack {
                        Spacer()
                        Text("App Version \(appVersion)")
                            .foregroundColor(.white.opacity(0.3))
                            .font(.footnote)
                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }

    func profileStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            Text(value)
                .font(.title2).bold()
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }

    func profileLinkRow(icon: String, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 28)
            Text(label)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "arrow.up.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

#Preview {
    ProfileView()
}
