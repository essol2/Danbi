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
    
    @State private var plantName = ""
    @State private var species = ""
    @State private var wateringInterval: Double = 7
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .camera
    @State private var showImageSourceAlert = false
    
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
                        VStack(alignment: .leading, spacing: 16) {
                            Text("물 주기")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            
                            HStack {
                                Slider(value: $wateringInterval, in: 1...30, step: 1)
                                    .accentColor(Color(red: 0.55, green: 0.65, blue: 0.55))
                                
                                Text("매 \(Int(wateringInterval)) 일마다")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                    .frame(width: 120, alignment: .trailing)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                }
                
                // Add Button
                Button(action: {
                    addPlant()
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
}

#Preview {
    AddPlantView()
        .modelContainer(for: Plant.self, inMemory: true)
}
