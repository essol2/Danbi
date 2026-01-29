//
//  danbiApp.swift
//  danbi
//
//  Created by 이은솔 on 1/27/26.
//

import SwiftUI
import SwiftData

//@main
//struct danbiApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .onAppear {
//                    // 앱 최초 실행 시 샘플 데이터 추가
//                    addSampleDataIfNeeded()
//                }
//        }
//        .modelContainer(for: Plant.self)
//    }
//    
//    private func addSampleDataIfNeeded() {
//        let container = try? ModelContainer(for: Plant.self)
//        guard let context = container?.mainContext else { return }
//        
//        // 데이터가 없으면 샘플 데이터 추가
//        let descriptor = FetchDescriptor<Plant>()
//        let existingPlants = try? context.fetch(descriptor)
//        
//        if existingPlants?.isEmpty ?? true {
//            context.addSamplePlants()
//        }
//    }
//}

@main
struct danbiApp: App {
    init() {
        // 알림 권한 요청
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Plant.self)
    }
}


