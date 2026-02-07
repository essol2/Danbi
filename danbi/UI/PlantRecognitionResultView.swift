//
//  PlantRecognitionResultView.swift
//  danbi
//
//  Created by 이은솔 on 2/7/26.
//

import SwiftUI

struct PlantRecognitionResultView: View {
    let result: PlantRecognitionResult
    let onConfirm: (String) -> Void
    let onDismiss: () -> Void

    @State private var searchText = ""
    @State private var showAllPlants = false

    private var filteredPlants: [(korean: String, english: String)] {
        if searchText.isEmpty {
            return showAllPlants
                ? PlantKeywordDictionary.commonHouseplants
                : Array(PlantKeywordDictionary.commonHouseplants.prefix(8))
        } else {
            return PlantKeywordDictionary.search(query: searchText)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            switch result {
            case .identified(let results):
                // PlantNet API로 정확한 식물 인식 성공
                identifiedView(results: results)

            case .plantDetected:
                // API 실패 → 목록에서 선택
                plantListView

            case .notPlant:
                // 식물이 아닌 것으로 판단
                notPlantView
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    // MARK: - API 인식 성공 뷰

    @ViewBuilder
    private func identifiedView(results: [PlantIdentificationResult]) -> some View {
        if let best = results.first {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(Color(red: 0.55, green: 0.65, blue: 0.55))

            Text("혹시 \(best.koreanName)인가요?\n단비가 찾아냈어요!")
                .font(.custom("MemomentKkukkukkR", size: 18))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Button(action: { onConfirm(best.koreanName) }) {
                Text("네, 맞아요!")
                    .font(.custom("MemomentKkukkukkR", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.55, green: 0.65, blue: 0.55))
                    .cornerRadius(12)
            }

            // 다른 후보가 있으면 표시
            if results.count > 1 {
                HStack(spacing: 8) {
                    ForEach(results.dropFirst().prefix(2), id: \.scientificName) { candidate in
                        Button(action: { onConfirm(candidate.koreanName) }) {
                            Text(candidate.koreanName)
                                .font(.custom("MemomentKkukkukkR", size: 14))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                .cornerRadius(10)
                        }
                    }
                }
            }

            Button(action: onDismiss) {
                Text("아니에요, 직접 입력할게요")
                    .font(.custom("MemomentKkukkukkR", size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            }
        }
    }

    // MARK: - 목록 선택 뷰 (폴백)

    private var plantListView: some View {
        Group {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(Color(red: 0.55, green: 0.65, blue: 0.55))

            Text("식물이 보여요!\n어떤 식물인지 알려주세요")
                .font(.custom("MemomentKkukkukkR", size: 18))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // 검색 바
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))

                TextField("식물 이름 검색", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.96, green: 0.96, blue: 0.96))
            .cornerRadius(12)

            // 식물 목록
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(filteredPlants, id: \.korean) { plant in
                        Button(action: { onConfirm(plant.korean) }) {
                            HStack {
                                Text(plant.korean)
                                    .font(.custom("MemomentKkukkukkR", size: 16))
                                    .foregroundColor(.black)

                                Spacer()

                                Text(plant.english)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                            .cornerRadius(10)
                        }
                    }

                    if filteredPlants.isEmpty && !searchText.isEmpty {
                        Text("검색 결과가 없어요")
                            .font(.custom("MemomentKkukkukkR", size: 14))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            .padding(.vertical, 12)
                    }

                    if searchText.isEmpty && !showAllPlants {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showAllPlants = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("더 많은 식물 보기")
                                    .font(.custom("MemomentKkukkukkR", size: 14))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(Color(red: 0.55, green: 0.65, blue: 0.55))
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .frame(maxHeight: 280)

            Button(action: onDismiss) {
                Text("직접 입력할게요")
                    .font(.custom("MemomentKkukkukkR", size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            }
        }
    }

    // MARK: - 식물 아님 뷰

    private var notPlantView: some View {
        Group {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 36))
                .foregroundColor(Color(red: 0.78, green: 0.71, blue: 0.55))

            Text("처음 보는 친구라\n단비가 당황했어요!")
                .font(.custom("MemomentKkukkukkR", size: 18))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("식물 종류를 직접 알려주실래요?")
                .font(.custom("MemomentKkukkukkR", size: 14))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))

            Button(action: onDismiss) {
                Text("알겠어요!")
                    .font(.custom("MemomentKkukkukkR", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.78, green: 0.71, blue: 0.55))
                    .cornerRadius(12)
            }
        }
    }
}
