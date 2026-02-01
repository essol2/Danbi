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
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🚀 앱 시작 - 알림 권한 요청 시작")
        
        // Delegate 설정 - Foreground에서도 알림 받기 위해 필수
        UNUserNotificationCenter.current().delegate = self
        
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
    
    // 🔧 Foreground에서 알림 표시하기 위한 메서드
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📲 Foreground 알림 도착: \(notification.request.content.title)")
        // iOS 14+ 에서 banner, sound, badge 모두 표시
        completionHandler([.banner, .sound, .badge])
    }
    
    // 알림을 탭했을 때 처리 (선택사항)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("👆 알림 탭됨: \(response.notification.request.content.title)")
        completionHandler()
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
    
    // 앱 생명주기 감지
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 앱 실행 시 뱃지 초기화
                    clearBadge()
                }
        }
        .modelContainer(for: Plant.self)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // 앱이 활성화될 때마다 뱃지 초기화
            if newPhase == .active {
                clearBadge()
            }
        }
    }
    
    // 뱃지 초기화 함수
    private func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("⚠️ 뱃지 초기화 실패: \(error.localizedDescription)")
            } else {
                print("✅ 뱃지 초기화 완료")
            }
        }
        
        // 전달된 알림도 모두 제거
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}


