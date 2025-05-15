//
//  BlockView.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/11.
//

import SwiftUI

struct AppBlock: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    var isBlocked: Bool = false
}

struct BlockView: View {
    @State private var selectedApp: AppBlock?
    @State private var showingSheet = false
    
    let apps: [AppBlock] = [
        AppBlock(name: "Instagram", color: .purple),
        AppBlock(name: "TikTok", color: .black),
        AppBlock(name: "Twitter", color: .blue),
        AppBlock(name: "Facebook", color: .blue),
        AppBlock(name: "YouTube", color: .red),
        AppBlock(name: "Reddit", color: .orange),
        AppBlock(name: "Snapchat", color: .yellow),
        AppBlock(name: "WhatsApp", color: .green)
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Earn Your Scroll")
                            .font(.title).bold()
                            .foregroundColor(.white)
                        
                        Text("Choose which apps to guard until you've done your One Thing.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // App List
                    VStack(spacing: 12) {
                        ForEach(apps) { app in
                            Button(action: {
                                selectedApp = app
                                showingSheet = true
                            }) {
                                HStack {
                                    // App Icon
                                    ZStack {
                                        Circle()
                                            .fill(app.color.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                        Image(app.name)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                    // App Name
                                    Text(app.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    // Toggle
                                    Image(systemName: app.isBlocked ? "lock.fill" : "lock.open.fill")
                                        .foregroundColor(app.isBlocked ? .green : .white.opacity(0.5))
                                        .font(.title3)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $showingSheet) {
            if let app = selectedApp {
                BlockAppSheet(app: app)
            }
        }
    }
}

struct BlockAppSheet: View {
    let app: AppBlock
    @Environment(\.dismiss) var dismiss
    @State private var isBlocked = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    // App Icon
                    ZStack {
                        Circle()
                            .fill(app.color.opacity(0.2))
                            .frame(width: 100, height: 100)
                        Image(app.name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }
                    
                    // App Name
                    Text(app.name)
                        .font(.title).bold()
                        .foregroundColor(.white)
                    
                    // Description
                    Text("Block this app until you've completed your One Thing for today.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Toggle
                    Toggle(isOn: $isBlocked) {
                        Text(isBlocked ? "Blocked" : "Not Blocked")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

#Preview {
    BlockAppSheet(app: AppBlock(name: "Instagram", color: .red))
}
