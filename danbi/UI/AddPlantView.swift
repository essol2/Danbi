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

    // 수정 모드용 - 기존 식물이 있으면 수정 모드
    var plantToEdit: Plant?
    var isEditMode: Bool { plantToEdit != nil }

    @State private var plantName = ""
    @State private var species = ""
    @State private var wateringInterval: Double = 7
    @State private var note = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .camera
    @State private var showImageSourceAlert = false
    @State private var showAdAlert = false // 광고 보기 알림
    @State private var isLoadingAd = false // 광고 로딩 상태

    // 식물 AI 인식
    @State private var recognitionResult: PlantRecognitionResult? = nil
    @State private var isClassifying = false
    @State private var showRecognitionResult = false
    @State private var isLoadingCareInfo = false
    @State private var careInfoNotFound = false
    @FocusState private var isSpeciesFieldFocused: Bool
    
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
                    Text(isEditMode ? String(localized: "반려 식물 수정") : String(localized: "반려 식물 추가"))
                        .font(.custom("MemomentKkukkukkR", size: 24))
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
                                .font(.custom("MemomentKkukkukkR", size: 15))
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
                                            .font(.custom("MemomentKkukkukkR", size: 15))
                                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                    }
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // 식물 AI 인식 로딩
                        if isClassifying {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(Color(red: 0.55, green: 0.65, blue: 0.55))
                                Text("단비가 식물을 살펴보는 중...")
                                    .font(.custom("MemomentKkukkukkR", size: 14))
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }

                        // 식물 AI 인식 결과
                        if showRecognitionResult, let result = recognitionResult {
                            PlantRecognitionResultView(
                                result: result,
                                onConfirm: { koreanName in
                                    species = koreanName
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        showRecognitionResult = false
                                    }
                                    fetchPlantCareInfo(for: koreanName)
                                },
                                onDismiss: {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        showRecognitionResult = false
                                    }
                                    isSpeciesFieldFocused = true
                                }
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Plant Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("식물 이름")
                                .font(.custom("MemomentKkukkukkR", size: 15))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))

                            TextField("ex. 나의 첫 몬스테라", text: $plantName)
                                .font(.custom("MemomentKkukkukkR", size: 16))
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
                                .font(.custom("MemomentKkukkukkR", size: 15))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))

                            TextField("ex. 몬스테라", text: $species)
                                .font(.custom("MemomentKkukkukkR", size: 16))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.clear, lineWidth: 0)
                                )
                                .focused($isSpeciesFieldFocused)
                        }
                        
                        // Watering Frequency
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("물 주기")
                                    .font(.custom("MemomentKkukkukkR", size: 15))
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))

                                Spacer()

                                Text("오늘부터 매 \(Int(wateringInterval))일마다")
                                    .font(.custom("MemomentKkukkukkR", size: 14))
                                    .foregroundColor(.black)
                                    .frame(width: 150, alignment: .trailing)
                            }
                           
                            Slider(value: $wateringInterval, in: 1...90, step: 1)
                                .accentColor(Color(red: 0.55, green: 0.65, blue: 0.55))

                        }

                        // 관리법 로딩 / 결과 없음
                        if isLoadingCareInfo {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(Color(red: 0.55, green: 0.65, blue: 0.55))
                                Text("관리법을 찾고 있어요...")
                                    .font(.custom("MemomentKkukkukkR", size: 14))
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                        } else if careInfoNotFound {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 0.7, green: 0.65, blue: 0.5))
                                Text("관리법을 찾지 못했어요. 직접 입력해주세요!")
                                    .font(.custom("MemomentKkukkukkR", size: 13))
                                    .foregroundColor(Color(red: 0.7, green: 0.65, blue: 0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                            .transition(.opacity)
                        }

                        // Note
                        VStack(alignment: .leading, spacing: 8) {
                            Text("비고")
                                .font(.custom("MemomentKkukkukkR", size: 15))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))

                            TextEditor(text: $note)
                                .font(.custom("MemomentKkukkukkR", size: 15))
                                .foregroundColor(.black)
                                .frame(minHeight: 100)
                                .padding(12)
                                .scrollContentBackground(.hidden)
                                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                .cornerRadius(12)
                                .overlay(alignment: .topLeading) {
                                    if note.isEmpty {
                                        Text("관리법, 특이사항 등을 자유롭게 메모하세요")
                                            .font(.custom("MemomentKkukkukkR", size: 15))
                                            .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                }
                
                // Add/Edit Button
                Button(action: {
                    if isEditMode {
                        updatePlant()
                    } else {
                        // 3개 이상일 때 광고 표시
                        if plants.count >= 3 {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            showAdAlert = true
                        } else {
                            addPlant()
                        }
                    }
                }) {
                    Text(isEditMode ? String(localized: "수정 완료") : String(localized: "+ 추가"))
                        .font(.custom("MemomentKkukkukkR", size: 18))
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
            title: String(localized: "식물 등록 한도"),
            message: String(localized: "무료로 3개까지 등록할 수 있어요.\n추가 등록을 위해 짧은 광고를 시청해주세요!"),
            primaryButtonTitle: String(localized: "광고 보기"),
            secondaryButtonTitle: String(localized: "취소"),
            primaryAction: {
                showRewardedAd()
            },
            secondaryAction: {
                print("🚫 광고 보기 취소")
            }
        )
        .onChange(of: selectedImage) { oldImage, newImage in
            guard let image = newImage, !isEditMode else { return }
            // 수정 모드가 아닐 때만 AI 인식 실행
            isClassifying = true
            showRecognitionResult = false

            PlantClassifier.shared.classify(image: image) { result in
                recognitionResult = result
                isClassifying = false
                withAnimation(.easeOut(duration: 0.3)) {
                    showRecognitionResult = true
                }
            }
        }
        .onAppear {
            // 보상형 광고 미리 로드
            RewardedAdManager.shared.loadAd()

            // 수정 모드일 때 기존 데이터 로드
            if let plant = plantToEdit {
                plantName = plant.name
                species = plant.scientificName
                wateringInterval = Double(plant.wateringInterval)
                note = plant.note
                if let imageData = plant.imageData {
                    selectedImage = UIImage(data: imageData)
                }
            }
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
            imageData: imageData,
            sortOrder: plants.count,
            note: note
        )

        modelContext.insert(newPlant)
        try? modelContext.save()

        // 알림 예약
        newPlant.updateWateringNotification()

        dismiss()
    }

    private func updatePlant() {
        guard let plant = plantToEdit else { return }

        var imageData: Data?
        if let selectedImage = selectedImage {
            imageData = selectedImage.jpegData(compressionQuality: 0.8)
        }

        plant.name = plantName
        plant.scientificName = species
        plant.wateringInterval = Int(wateringInterval)
        plant.imageData = imageData
        plant.note = note

        try? modelContext.save()

        // 알림 재예약
        plant.updateWateringNotification()

        dismiss()
    }
    
    private func fetchPlantCareInfo(for plantName: String) {
        guard PerenualService.shared.isAPIKeyConfigured else { return }

        isLoadingCareInfo = true
        careInfoNotFound = false

        // 한국어 이름 → Perenual 검색용 영어 일반명으로 변환
        let searchName: String
        if let commonName = PlantKeywordDictionary.perenualSearchName[plantName] {
            searchName = commonName
        } else if let plant = PlantKeywordDictionary.commonHouseplants.first(where: { $0.korean == plantName }) {
            searchName = plant.english
        } else {
            searchName = plantName
        }

        // 학명을 fallback 검색어로 준비 (commonHouseplants의 english가 학명인 경우)
        let fallbackName: String?
        if let plant = PlantKeywordDictionary.commonHouseplants.first(where: { $0.korean == plantName }) {
            // perenualSearchName과 다른 경우에만 fallback으로 사용
            fallbackName = plant.english != searchName ? plant.english : nil
        } else {
            fallbackName = nil
        }

        PerenualService.shared.searchPlantCare(name: searchName, fallbackName: fallbackName) { careInfo in
            isLoadingCareInfo = false

            guard let info = careInfo else {
                withAnimation(.easeOut(duration: 0.2)) {
                    careInfoNotFound = true
                }
                return
            }

            // 비고란에 관리법 자동 입력 (기존 내용이 없을 때만)
            if note.isEmpty {
                withAnimation(.easeOut(duration: 0.2)) {
                    note = info.koreanCareNote
                }
            }

            // 물주기 추천값 자동 설정 (기본값 7일일 때만)
            if let days = info.recommendedWateringDays, wateringInterval == 7 {
                withAnimation(.easeOut(duration: 0.2)) {
                    wateringInterval = Double(days)
                }
            }
        }
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
