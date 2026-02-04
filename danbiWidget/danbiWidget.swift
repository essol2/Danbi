//
//  danbiWidget.swift
//  danbiWidget
//
//  Created by Claude on 2/2/26.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Entry
struct PlantEntry: TimelineEntry {
    let date: Date
    let plantsNeedingWater: Int
}

// MARK: - Widget Timeline Provider
struct PlantProvider: TimelineProvider {
    // 위젯 미리보기용
    func placeholder(in context: Context) -> PlantEntry {
        PlantEntry(date: Date(), plantsNeedingWater: 2)
    }
    
    // 위젯 갤러리 스냅샷
    func getSnapshot(in context: Context, completion: @escaping (PlantEntry) -> Void) {
        let entry = PlantEntry(date: Date(), plantsNeedingWater: 2)
        completion(entry)
    }
    
    // 실제 타임라인
    func getTimeline(in context: Context, completion: @escaping (Timeline<PlantEntry>) -> Void) {
        let plantsNeedingWater = fetchPlantsNeedingWater()
        
        let currentDate = Date()
        let entry = PlantEntry(date: currentDate, plantsNeedingWater: plantsNeedingWater)
        
        // 다음 업데이트: 자정 (매일 갱신)
        let nextMidnight = Calendar.current.startOfDay(for: currentDate.addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        
        completion(timeline)
    }
    
    // SwiftData에서 식물 데이터 가져오기
    private func fetchPlantsNeedingWater() -> Int {
        do {
            let container = try ModelContainer(for: Plant.self)
            let context = ModelContext(container)
            
            let descriptor = FetchDescriptor<Plant>()
            let plants = try context.fetch(descriptor)
            
            return plants.filter { plant in
                let daysSinceWatered = Calendar.current.dateComponents([.day], from: plant.lastWatered, to: Date()).day ?? 0
                return daysSinceWatered >= plant.wateringInterval
            }.count
        } catch {
            print("❌ 위젯 데이터 로드 실패: \(error)")
            return 0
        }
    }
}

// MARK: - Small Widget View (2x2)
struct PlantWidgetSmallView: View {
    let entry: PlantEntry

    private let bgColor = Color(red: 0.95, green: 0.95, blue: 0.93)
    private let accentColor = Color(red: 0.65, green: 0.72, blue: 0.65)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 상단: 물방울 아이콘 + 앱 이름
            HStack(spacing: 5) {
                // 물방울 아이콘 (둥근 배경)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)

                    Image(systemName: "drop.fill")
                        .font(.system(size: 12))
                        .foregroundColor(accentColor)
                }

                Text("Danbi")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
            }

            Spacer()

            // 숫자
            Text("\(entry.plantsNeedingWater)")
                .font(.system(size: 38, weight: .bold))
                .foregroundColor(accentColor)

            // 메시지
            Text(entry.plantsNeedingWater > 0 ? "반려식물이\n단비를 기다려요!" : "물 줄\n반려식물이 없어요!")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(accentColor)
                .lineLimit(2)
                .lineSpacing(0)
        }
        .padding(8)
        .containerBackground(bgColor, for: .widget)
    }
}

// MARK: - Medium Widget View (4x2)
struct PlantWidgetMediumView: View {
    let entry: PlantEntry

    private let bgColor = Color(red: 0.95, green: 0.95, blue: 0.93)
    private let accentColor = Color(red: 0.65, green: 0.72, blue: 0.65)
    private let grayColor = Color(red: 0.6, green: 0.6, blue: 0.6)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // 상단: 물방울 아이콘 + 앱 이름
                HStack(spacing: 6) {
                    // 물방울 아이콘 (둥근 배경)
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)

                        Image(systemName: "drop.fill")
                            .font(.system(size: 14))
                            .foregroundColor(accentColor)
                    }

                    Text("Danbi")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                }

                Spacer()

                // 숫자 + 선인장 이모지
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(entry.plantsNeedingWater)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(accentColor)

                    Text("🌵")
                        .font(.system(size: 22))
                        .padding(.bottom, 2)
                }

                // 메시지
                Text(entry.plantsNeedingWater > 0 ? "반려식물이 단비를 기다려요!" : "물 줄 반려식물이 없어요!")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(accentColor)
            }

            Spacer()

            // 오른쪽: Today 레이블
            VStack {
                Text("Today")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(grayColor)

                Spacer()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(bgColor, for: .widget)
    }
}

// MARK: - Large Widget View (4x4)
struct PlantWidgetLargeView: View {
    let entry: PlantEntry

    private let bgColor = Color(red: 0.95, green: 0.95, blue: 0.93)
    private let accentColor = Color(red: 0.65, green: 0.72, blue: 0.65)
    private let grayColor = Color(red: 0.6, green: 0.6, blue: 0.6)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단: 아이콘 + 앱 이름 + Today
            HStack {
                HStack(spacing: 10) {
                    // 물방울 아이콘 (둥근 배경)
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)

                        Image(systemName: "drop.fill")
                            .font(.system(size: 22))
                            .foregroundColor(accentColor)
                    }

                    Text("Danbi")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }

                Spacer()

                Text("Today")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(grayColor)
            }

            Spacer()

            // 중앙: 숫자 + 선인장 이모지
            HStack(alignment: .bottom, spacing: 10) {
                Text("\(entry.plantsNeedingWater)")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(accentColor)

                Text("🌵")
                    .font(.system(size: 48))
                    .padding(.bottom, 8)
            }

            // 하단: 메시지
            Text(entry.plantsNeedingWater > 0 ? "반려식물이 단비를 기다려요!" : "물 줄 반려식물이 없어요!")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(accentColor)

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(bgColor, for: .widget)
    }
}

// MARK: - Widget Configuration
struct danbiWidget: Widget {
    let kind: String = "danbiWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlantProvider()) { entry in
            GeometryReader { geometry in
                // 위젯 크기에 따라 다른 뷰 표시
                if geometry.size.width < 200 {
                    PlantWidgetSmallView(entry: entry)
                } else if geometry.size.width < 350 {
                    PlantWidgetMediumView(entry: entry)
                } else {
                    PlantWidgetLargeView(entry: entry)
                }
            }
        }
        .configurationDisplayName("단비")
        .description("오늘 물 줘야 하는 식물 수를 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
