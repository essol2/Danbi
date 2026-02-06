//
//  ContentView.swift
//  danbi
//
//  Created by 이은솔 on 1/27/26.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase // 앱 상태 감지
    @Query(sort: \Plant.sortOrder) private var plants: [Plant]
    @State private var showingAddPlant = false
    @State private var showingSettings = false
    @State private var refreshID = UUID() // 뷰 리프레시용
    
    // 1분마다 뷰 갱신을 위한 타이머
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var plantsNeedingWater: Int {
        plants.filter { $0.needsWater }.count
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.95, green: 0.95, blue: 0.93)
                .ignoresSafeArea()
            
            if !(plants.isEmpty) {
                
                // Plant cards list with header inside
                List {
                    // Header section
                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            MainHeaderView(showingSettings: $showingSettings)
                                .padding(.top, 30)
                            
                            // Water notification banner
                            let (emoji, message, textColor, bgColor) = plantsNeedingWater > 0
                            ? ("💧", "오늘은 \(plantsNeedingWater)번 단비를 내려야해요!", Color(red: 0.549, green: 0.608, blue: 0.647), Color(red: 0.549, green: 0.608, blue: 0.647).opacity(0.2))
                            : ("☀️", "오늘은 물 줄 식물이 없어요!", Color(red: 0.780, green: 0.710, blue: 0.549), Color(red: 0.780, green: 0.710, blue: 0.549).opacity(0.2))
                            
                            HStack(spacing: 12) {
                                Text(emoji)
                                    .font(.system(size: 16))
                                    .foregroundColor(textColor)
                                
                                Text(message)
                                    .font(.system(size: 16))
                                    .foregroundColor(textColor)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(bgColor)
                            .cornerRadius(16)
                            .padding(.top, 24)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                    
                    // Plant cards
                    ForEach(plants) { plant in
                        PlantCardEditWrapper(plant: plant, modelContext: modelContext, onDelete: {
                            deletePlant(plant)
                        })
                            .listRowBackground(Color(red: 0.95, green: 0.95, blue: 0.93))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24))
                    }
                    .onMove(perform: movePlant)
                
//                    AdBannerView()
//                        .frame(width: AdSizeBanner.size.width, height: AdSizeBanner.size.height)
//                        .padding(.horizontal, 20)
                    
                    Color.clear
                        .frame(height: 100)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(red: 0.95, green: 0.95, blue: 0.93))
                
            } else {
                // No data view
                VStack(spacing: 0) {
                    MainHeaderView(showingSettings: $showingSettings)
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                    
                    // No data content
                    NoDataView()
                }
            }
                
            // Floating Add Button
            VStack {
                Spacer()
                
                Button(action: {
                    showingAddPlant = true
                }) {
                    Text("반려식물 추가하기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0.55, green: 0.65, blue: 0.55))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .blur(radius: showingAddPlant ? 10 : 0)
        .fullScreenCover(isPresented: $showingAddPlant) {
            AddPlantView()
                .background(ClearBackgroundView())
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            // 디버깅: 저장된 식물 데이터 확인
            print("=== 앱 실행 시 식물 데이터 ===")
            for plant in plants {
                print("🌿 \(plant.name)")
                print("   - lastWatered: \(plant.lastWatered)")
                print("   - daysSinceWatered: \(plant.daysSinceWatered)")
                print("   - wateringInterval: \(plant.wateringInterval)")
                print("   - needsWater: \(plant.needsWater)")
            }
            print("============================")

            // 앱 실행 시 모든 알림 재예약
            if UserDefaults.standard.bool(forKey: "notificationsEnabled") || UserDefaults.standard.object(forKey: "notificationsEnabled") == nil {
                NotificationManager.shared.rescheduleAllNotifications(plants: plants)
            }
        }
        .onReceive(timer) { _ in
            // 1분마다 뷰 갱신
            refreshID = UUID()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // 앱이 포그라운드로 돌아오면 뷰 갱신 + 알림 재예약
            if newPhase == .active {
                print("🔄 앱이 활성화됨 - 뷰 갱신 및 알림 재예약")
                refreshID = UUID()

                // 알림 재예약 (날짜가 바뀌었을 수 있으므로)
                if UserDefaults.standard.bool(forKey: "notificationsEnabled") || UserDefaults.standard.object(forKey: "notificationsEnabled") == nil {
                    NotificationManager.shared.rescheduleAllNotifications(plants: plants)
                }
            }
        }
        .id(refreshID) // refreshID가 변경되면 뷰 전체가 다시 그려짐
    }
    
    private func movePlant(from source: IndexSet, to destination: Int) {
        var reorderedPlants = Array(plants)
        reorderedPlants.move(fromOffsets: source, toOffset: destination)
        for (index, plant) in reorderedPlants.enumerated() {
            plant.sortOrder = index
        }
        try? modelContext.save()
    }

    private func deletePlant(_ plant: Plant) {
        withAnimation {
            // 알림 취소
            NotificationManager.shared.cancelNotification(for: plant)
            
            modelContext.delete(plant)
            try? modelContext.save()
        }
    }
}

// 투명한 배경을 위한 헬퍼 뷰
struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct PlantCardEditWrapper: View {
    let plant: Plant
    let modelContext: ModelContext
    let onDelete: () -> Void
    @State private var showingEditPlant = false

    var body: some View {
        PlantCardView(plant: plant, modelContext: modelContext, showingEditPlant: $showingEditPlant)
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button {
                    showingEditPlant = true
                } label: {
                    Label("수정", systemImage: "pencil")
                }
                .tint(Color(red: 0.55, green: 0.65, blue: 0.55))
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("삭제", systemImage: "trash.fill")
                }
            }
            .fullScreenCover(isPresented: $showingEditPlant) {
                AddPlantView(plantToEdit: plant)
                    .background(ClearBackgroundView())
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
