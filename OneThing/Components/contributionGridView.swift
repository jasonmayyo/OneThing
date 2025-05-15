//
//  contributionGridView.swift
//  OneThing
//
//  Created by Jason Mayo on 2025/05/10.
//

import SwiftUI

struct ContributionGridView: View {
    var filledCells: Int
    var totalCells: Int = 90 // Default to 3 months
    var columns: Int = 14
    var body: some View {
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 2), count: columns)
        VStack(alignment: .leading, spacing: 6) {
            Text("Goal: 3 months of doing One Thing daily")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 5)
                .padding(.bottom, 5)
            LazyVGrid(columns: gridColumns, spacing: 2) {
                ForEach(0..<totalCells, id: \.self) { index in
                    Rectangle()
                        .fill(index < filledCells ? 
                              Color.white.opacity(0.9)
                              : Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(2)
                        
                }
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.15))
        )
    }
}

#Preview {
    ContributionGridView(filledCells: 3)
}
