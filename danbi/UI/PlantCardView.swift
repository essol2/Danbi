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
    @Binding var showingEditPlant: Bool
    @State private var showWaterComplete = false
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0

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
                        ZStack {
                            // 물방울 퍼지는 효과
                            Circle()
                                .stroke(Color(red: 0.55, green: 0.65, blue: 0.55), lineWidth: 2)
                                .frame(width: 56, height: 56)
                                .scaleEffect(rippleScale)
                                .opacity(rippleOpacity)

                            Circle()
                                .fill(Color(red: 0.65, green: 0.72, blue: 0.65))
                                .frame(width: 56, height: 56)
                                .scaleEffect(showWaterComplete ? 0.9 : 1.0)

                            // 아이콘 전환
                            Image(systemName: showWaterComplete ? "checkmark" : "drop.fill")
                                .font(.system(size: showWaterComplete ? 22 : 24, weight: showWaterComplete ? .bold : .regular))
                                .foregroundColor(.white)
                                .scaleEffect(showWaterComplete ? 1.1 : 1.0)
                        }
                    }
                    .buttonStyle(.plain)
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
//                        let daysUntilWater = plant.wateringInterval - plant.daysSinceWatered
//                        Text("\(daysUntilWater)일마다")
//                            .font(.system(size: 15, weight: .medium))
//                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        Text("\(plant.wateringInterval)일마다")
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
        guard !showWaterComplete else { return }

        plant.lastWatered = Date()
        try? modelContext.save()

        print("🌱 [\(plant.name)] 물주기 완료")
        print("   - lastWatered: \(plant.lastWatered)")
        print("   - daysSinceWatered: \(plant.daysSinceWatered)")

        // 알림 재예약
        plant.updateWateringNotification()

        // 버튼 축소 + 체크마크 전환
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            showWaterComplete = true
        }

        // 물방울 퍼지는 효과
        rippleScale = 1.0
        rippleOpacity = 0.6
        withAnimation(.easeOut(duration: 0.6)) {
            rippleScale = 2.0
            rippleOpacity = 0
        }

        // 원래 상태로 복귀
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showWaterComplete = false
            }
        }
    }
}
