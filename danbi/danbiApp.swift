//
//  danbiApp.swift
//  danbi
//
//  Created by 이은솔 on 1/27/26.
//

import SwiftUI
import SwiftData
import UserNotifications
import GoogleMobileAds

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
        
        // 앱 오프닝 광고 미리 로드 (표시는 danbiApp에서 처리)
        AppOpenAdManager.shared.loadAd()
        
        return true
    }
    
    // 앱이 백그라운드에서 포그라운드로 돌아올 때 호출
    func applicationDidBecomeActive(_ application: UIApplication) {
        // 백그라운드에서 돌아올 때는 광고를 표시하지 않음
        print("📱 앱이 활성화됨 - 광고 표시 안 함 (백그라운드 복귀)")
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

@main
struct danbiApp: App {
    // AppDelegate 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // 앱 생명주기 감지
    @Environment(\.scenePhase) private var scenePhase
    
    // 스플래시/광고 로딩 상태
    @State private var isAdLoading = true
    @State private var showMainContent = false
    
    init() {
        // AdMob 초기화
        MobileAds.shared.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showMainContent {
                    ContentView()
                        .onAppear {
                            // 앱 실행 시 뱃지 초기화
                            clearBadge()
                        }
                        .transition(.opacity)
                } else {
                    SplashView(isLoading: $isAdLoading)
                        .transition(.opacity)
                }
            }
            .onAppear {
                // 광고 로드 완료 후 메인 화면으로 전환
                checkAdLoadingStatus()
            }
        }
        .modelContainer(for: Plant.self)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // 앱이 활성화될 때마다 뱃지 초기화
            if newPhase == .active {
                clearBadge()
                // 백그라운드에서 돌아올 때는 광고 표시 안 함 (처음 실행시에만 표시)
            }
        }
    }
    
    // 광고 로딩 상태 체크
    private func checkAdLoadingStatus() {
        // 광고 로딩 상태를 주기적으로 확인
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            // 광고가 로드되었거나 로딩 중이 아니면
            if !AppOpenAdManager.shared.isLoadingAd {
                timer.invalidate()
                isAdLoading = false
                
                // 0.5초 후 광고 표시 시도 및 메인 화면 전환
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AppOpenAdManager.shared.showAdIfAvailable()
                    
                    // 광고 표시 후 메인 화면으로 전환
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMainContent = true
                        }
                    }
                }
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


