//
//  danbiApp.swift
//  danbi
//
//  Created by 이은솔 on 1/27/26.
//

import SwiftUI
import SwiftData
import UserNotifications

// AppDelegate 추가
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🚀 앱 시작 - 알림 권한 요청 시작")
        
        // ⚠️ 중요: 시스템이 준비될 시간을 주기 위해 2초 딜레이
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("⏰ 2초 후 - 지금 권한 요청")
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        print("✅ 알림 권한 허용됨 (AppDelegate)")
                    } else {
                        print("❌ 알림 권한 거부됨 (AppDelegate)")
                    }
                    if let error = error {
                        print("⚠️ 알림 권한 오류 (AppDelegate): \(error.localizedDescription)")
                    }
                }
            }
        }
        
        return true
    }
}

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
    // AppDelegate 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Plant.self)
    }
}


