//
//  HomeView.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/10.
//

import SwiftUI
import Charts

struct HomeView: View {
    // Sample data for the graph
    let weeklyData: [(date: Date, value: Double)] = [
        (Calendar.current.date(byAdding: .day, value: -6, to: Date())!, 0.8),
        (Calendar.current.date(byAdding: .day, value: -5, to: Date())!, 0.1),
        (Calendar.current.date(byAdding: .day, value: -4, to: Date())!, 0.7),
        (Calendar.current.date(byAdding: .day, value: -3, to: Date())!, 0.95),
        (Calendar.current.date(byAdding: .day, value: -2, to: Date())!, 0.85),
        (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 0.9),
        (Date(), 1.0)
    ]
    
    // Add these properties to HomeView
    private var weekDays: [String] {
        let symbols = Calendar.current.shortWeekdaySymbols
        return Array(symbols[1...]) + [symbols[0]] // ["Mon", ..., "Sun"]
    }
    private var todayIndex: Int {
        let idx = Calendar.current.component(.weekday, from: Date()) - 2
        return idx < 0 ? 6 : idx // handle Sunday as last
    }
    // Define a struct for OneThing
    struct OneThing {
        let emoji: String
        let label: String
    }
    private var oneThings: [OneThing?] {
        [
            OneThing(emoji: "💪", label: "Gym"),
            OneThing(emoji: "📚", label: "Reading"),
            OneThing(emoji: "🍎", label: "Eat a Fruit"),
            OneThing(emoji: "🥛", label: "Drink water"),
            OneThing(emoji: "🎹", label: "Play Piano"),
            nil,
            nil
        ]
    }
    private var completed: [Bool] {
        [true, true, false, false, false, false, false]
    }
    // Helper to get the dates for the current week (Monday to Sunday)
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // weekday: 1 = Sunday, 2 = Monday, ...
        let daysFromMonday = (weekday + 5) % 7 // 0 for Monday
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading) {
                    // Top Row
                    HStack {
                        VStack(alignment: .leading) {
                            // Glowing white circle (logo)
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.white.opacity(0.7), radius: 20)
                            }
                            // Premium Weekly label with chevron
                            HStack(spacing: 4) {
                                Text("Weekly")
                                    .font(.caption).bold()
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                        }
                        
                        Spacer()
                        // Flame emoji with glow and 3 DAYS
                        VStack(spacing: 4) {
                            Text("🔥")
                                .font(.system(size: 38))
                                .shadow(color: Color.orange, radius: 8)
                            Text("3 DAYS")
                                .font(.caption).bold()
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Redesigned Weekly Schedule Section
                    VStack(alignment: .leading, spacing: 0) {
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(0..<7, id: \.self) { i in
                                    let isToday = i == todayIndex
                                    let isPast = i < todayIndex
                                    let isUpcoming = i > todayIndex
                                    let thing = oneThings.indices.contains(i) ? oneThings[i] : nil
                                    let isCompleted = completed.indices.contains(i) ? completed[i] : false
                                    let date = weekDates[i]
                                    let dateString = formattedDate(date)
                                    let dayString = weekDays[i]
                                    
                                    VStack(spacing: 10) {
                                        // Day and Date on one line
                                        HStack(spacing: 4) {
                                            Text(dayString)
                                                .font(.subheadline).bold()
                                                .foregroundColor(isToday ? .white : .white.opacity(0.7))
                                            Text(dateString)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        // Emoji in glowing circle
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.white.opacity(0.18), Color.white.opacity(0.05)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 54, height: 54)
                                                .shadow(color: isToday ? Color.white.opacity(0.5) : Color.clear, radius: 12)
                                            if let thing = thing {
                                                Text(thing.emoji)
                                                    .font(.system(size: 32))
                                            } else {
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                        // One Thing label
                                        if let thing = thing {
                                            Text(thing.label)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                                .frame(maxWidth: 110)
                                        } else {
                                            Text("")
                                        }
                                        // Status badge or button
                                        if isPast || isToday {
                                            if let _ = thing {
                                                if isCompleted {
                                                    Label(isToday ? "Done Today" : "Completed", systemImage: "checkmark.seal.fill")
                                                        .font(.caption2.bold())
                                                        .foregroundColor(.green)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 4)
                                                        .background(Color.green.opacity(0.15))
                                                        .clipShape(Capsule())
                                                } else if isToday {
                                                    Text("In Progress")
                                                        .font(.caption2.bold())
                                                        .foregroundColor(.yellow)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 4)
                                                        .background(Color.yellow.opacity(0.15))
                                                        .clipShape(Capsule())
                                                } else {
                                                    Text("Missed")
                                                        .font(.caption2.bold())
                                                        .foregroundColor(.red)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 4)
                                                        .background(Color.red.opacity(0.15))
                                                        .clipShape(Capsule())
                                                }
                                            }
                                        } else if isUpcoming {
                                            if let _ = thing {
                                                Text("Upcomming")
                                                    .font(.caption2.bold())
                                                    .foregroundColor(.blue)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Color.blue.opacity(0.15))
                                                    .clipShape(Capsule())
                                            } else {
                                                Button(action: {}) {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "plus.circle")
                                                        Text("Choose")
                                                    }
                                                    .font(.caption2.bold())
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Color.white.opacity(0.12))
                                                    .clipShape(Capsule())
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                    .frame(width: 140) // fixed width for all cards
                                    .padding(.vertical, 18)
                                    .padding(.horizontal, 0)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        isToday ? Color.white.opacity(0.18) : Color.white.opacity(0.10),
                                                        Color.white.opacity(0.04)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .shadow(color: isToday ? Color.white.opacity(0.25) : Color.clear, radius: 10, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(isToday ? Color.white : Color.clear, lineWidth: isToday ? 2.5 : 0)
                                    )
                                }
                            }
                        }
                        .frame(height: 210)
                    }
                    .padding(.leading)
                    .padding(.bottom)
                   

                    ContributionGridView(filledCells: 3)
                        .padding(.horizontal)

                    // Growth Footprint Section
                    VStack(alignment: .leading) {
                        Text("Your Growth Footprint")
                            .font(.headline).bold()
                            .foregroundColor(.white)
                        Text("Here's how your daily actions are building a new you.")
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.7))
                        VStack(alignment: .leading, spacing: 10) {
                            growthBar(emoji: "💪", label: "Gym", value: 30, max: 30, color: .white)
                            growthBar(emoji: "📚", label: "Reading", value: 10, max: 30, color: .white)
                            growthBar(emoji: "🍎", label: "Eat a Fruit", value: 9, max: 30, color: .white)
                            growthBar(emoji: "🥛", label: "Drink water", value: 3, max: 30, color: .white)
                            growthBar(emoji: "🎹", label: "Practice Piano", value: 3, max: 30, color: .white)
                            growthBar(emoji: "🚶‍♂️", label: "Go for a Walk", value: 1, max: 30, color: .white)
                            growthBar(emoji: "🔒", label: "Deep Work", value: 0, max: 30, color: .white)
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)

                    Spacer()
                }
            }
        }
    }
    
    private static let dayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()
    private func formattedDate(_ date: Date) -> String {
        Self.dayDateFormatter.string(from: date)
    }

    // Growth bar for the Growth Footprint section
    func growthBar(emoji: String, label: String, value: Int, max: Int, color: Color) -> some View {
        HStack() {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 50, height: 50)
                Text(emoji)
                    .font(.title2)
            }
            .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(label)
                    .foregroundColor(.white)
                    .font(.headline)
                GeometryReader { geometry in
                    HStack {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(color)
                                .frame(width: CGFloat(value) / CGFloat(max) * (geometry.size.width - 40), height: 8)
                        }
                        Text("\(value)")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .frame(height: 8)
                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
}
