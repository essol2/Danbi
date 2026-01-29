//
//  PlantCardView.swift
//  danbi
//
//  Created by 이은솔 on 1/27/26.
//

import Foundation
import SwiftUI
import SwiftData

struct PlantCardView: View {
    let plant: Plant
    let modelContext: ModelContext
    
    var body: some View {
        VStack(spacing: 0) {
            // Plant image
            if let imageData = plant.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 280)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                Image("defaultImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 280)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.88, green: 0.90, blue: 0.88))
                    .clipped()
            }
            
            // Plant info
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plant.name)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text(plant.scientificName)
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                    
                    Spacer()
                    
                    // Water button
                    Button(action: {
                        waterPlant()
                    }) {
                        Circle()
                            .fill(Color(red: 0.65, green: 0.72, blue: 0.65))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.88, green: 0.90, blue: 0.88))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.65, green: 0.72, blue: 0.65))
                            .frame(width: geometry.size.width * plant.wateringProgress, height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Last watered info
                HStack {
                    Text("\(plant.daysSinceWatered)일 전에 물을 줬어요!")
                        .font(.system(size: 15))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    
                    Spacer()
                    
                    if plant.needsWater {
                        Text("오늘 물주는 날!")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(red: 0.65, green: 0.72, blue: 0.65))
                    } else {
                        let daysUntilWater = plant.wateringInterval - plant.daysSinceWatered
                        Text("\(daysUntilWater)일마다")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Color.white)
        }
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    
    private func waterPlant() {
        plant.lastWatered = Date()
        try? modelContext.save()
        
        // 알림 재예약
        plant.updateWateringNotification()
    }
}
