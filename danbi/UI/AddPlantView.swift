//
//  AddPlantView.swift
//  danbi
//
//  Created by 이은솔 on 1/27/26.
//

import Foundation
import SwiftUI
import SwiftData

struct AddPlantView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant] // 기존 식물 갯수 확인용
    
    @State private var plantName = ""
    @State private var species = ""
    @State private var wateringInterval: Double = 7
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .camera
    @State private var showImageSourceAlert = false
    @State private var showAdAlert = false // 광고 보기 알림
    @State private var isLoadingAd = false // 광고 로딩 상태
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Modal content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("반려 식물 추가")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Plant Image
                        VStack(alignment: .leading, spacing: 8) {
                            Text("식물 사진")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            
                            Button(action: {
                                showImageSourceAlert = true
                            }) {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(12)
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                        
                                        Text("사진 추가하기")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                    }
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Plant Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("식물 이름")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            
                            TextField("ex. 난의 첫 몬스테라", text: $plantName)
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.clear, lineWidth: 0)
                                )
                        }
                        
                        // Species
                        VStack(alignment: .leading, spacing: 8) {
                            Text("식물 종류")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            
                            TextField("ex. Monstera Deliciosa", text: $species)
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.clear, lineWidth: 0)
                                )
                        }
                        
                        // Watering Frequency
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("물 주기")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                
                                Spacer()
                                
                                Text("오늘부터 매 \(Int(wateringInterval)) 일마다")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.black)
                                    .frame(width: 120, alignment: .trailing)
                            }
                           
                            Slider(value: $wateringInterval, in: 1...90, step: 1)
                                .accentColor(Color(red: 0.55, green: 0.65, blue: 0.55))
                            
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                }
                
                // Add Button
                Button(action: {
                    // 3개 이상일 때 광고 표시
                    if plants.count >= 3 {
                        showAdAlert = true
                    } else {
                        addPlant()
                    }
                }) {
                    Text("+ 추가")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0.75, green: 0.82, blue: 0.75))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .disabled(plantName.isEmpty || species.isEmpty)
                .opacity(plantName.isEmpty || species.isEmpty ? 0.5 : 1.0)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white)
                    .ignoresSafeArea(edges: .bottom)
            )
            .offset(y: 40)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: imageSourceType)
        }
        .alert("사진 선택", isPresented: $showImageSourceAlert) {
            Button("카메라") {
                imageSourceType = .camera
                showImagePicker = true
            }
            Button("갤러리") {
                imageSourceType = .photoLibrary
                showImagePicker = true
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("사진을 가져올 방법을 선택하세요")
        }
        .customAlert(
            isPresented: $showAdAlert,
            icon: "play.circle.fill",
            title: "식물 등록 한도",
            message: "무료로 3개까지 등록할 수 있어요.\n추가 등록을 위해 짧은 광고를 시청해주세요!",
            primaryButtonTitle: "광고 보기",
            secondaryButtonTitle: "취소",
            primaryAction: {
                showRewardedAd()
            },
            secondaryAction: {
                print("🚫 광고 보기 취소")
            }
        )
        .onAppear {
            // 보상형 광고 미리 로드
            RewardedAdManager.shared.loadAd()
        }
    }
    
    private func addPlant() {
        var imageData: Data?
        if let selectedImage = selectedImage {
            imageData = selectedImage.jpegData(compressionQuality: 0.8)
        }
        
        let newPlant = Plant(
            name: plantName,
            scientificName: species,
            lastWatered: Date(),
            wateringInterval: Int(wateringInterval),
            imageData: imageData
        )
        
        modelContext.insert(newPlant)
        try? modelContext.save()
        
        // 알림 예약
        newPlant.updateWateringNotification()
        
        dismiss()
    }
    
    private func showRewardedAd() {
        isLoadingAd = true
        
        RewardedAdManager.shared.showAd { success in
            isLoadingAd = false
            
            if success {
                // 광고 시청 성공 - 식물 추가
                print("✅ 광고 시청 완료 - 식물 추가 허용")
                addPlant()
            } else {
                // 광고 시청 실패 또는 중단
                print("❌ 광고 시청 실패 - 식물 추가 취소")
            }
        }
    }
}

#Preview {
    AddPlantView()
        .modelContainer(for: Plant.self, inMemory: true)
}
