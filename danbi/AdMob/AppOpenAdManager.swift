//
//  AppOpenAdManager.swift
//  danbi
//
//  Created by Claude on 2/2/26.
//

import Foundation
import GoogleMobileAds
import UIKit

class AppOpenAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    // 싱글톤 인스턴스
    static let shared = AppOpenAdManager()
    
    // 앱 오프닝 광고 인스턴스
    private var appOpenAd: AppOpenAd?
    
    // 광고 로딩 상태
    @Published var isLoadingAd = false
    
    // 광고가 표시 중인지 여부
    @Published var isShowingAd = false
    
    // 광고 유닛 ID
    // 테스트 ID (구글 제공): ca-app-pub-3940256099942544/5575463023
    // 실제 ID: ca-app-pub-4144682979193082/1585673757
//    private let adUnitID = "ca-app-pub-3940256099942544/5575463023" // 테스트용
    private let adUnitID = "ca-app-pub-4144682979193082/4095810916" // 운영용
    
    // 광고 로드 시간 추적 (4시간마다 새로고침)
    private var loadTime = Date()
    
    // 광고 유효 시간 (4시간 = 14400초)
    private let adExpirationTime: TimeInterval = 14400
    
    private override init() {
        super.init()
    }
    
    // MARK: - 광고 로드
    func loadAd(completion: (() -> Void)? = nil) {
        // 이미 로딩 중이거나 광고가 있으면 리턴
        guard !isLoadingAd, appOpenAd == nil else { 
            completion?()
            return 
        }
        
        isLoadingAd = true
        print("🔄 앱 오프닝 광고 로딩 시작...")
        
        AppOpenAd.load(
            with: adUnitID,
            request: Request()
        ) { [weak self] ad, error in
            guard let self = self else { return }
            
            self.isLoadingAd = false
            
            if let error = error {
                print("❌ 앱 오프닝 광고 로드 실패: \(error.localizedDescription)")
                completion?()
                return
            }
            
            print("✅ 앱 오프닝 광고 로드 성공")
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
            
            // 로드 완료 콜백 실행
            completion?()
        }
    }
    
    // MARK: - 광고 표시
    func showAdIfAvailable() {
        // 광고가 이미 표시 중이면 리턴
        guard !isShowingAd else {
            print("⚠️ 광고가 이미 표시 중입니다.")
            return
        }
        
        // 광고가 없으면 새로 로드
        guard let appOpenAd = appOpenAd else {
            print("⚠️ 표시할 광고가 없습니다. 새로 로드합니다.")
            loadAd()
            return
        }
        
        // 광고가 만료되었는지 확인
        if wasLoadTimeLessThanNHoursAgo() {
            print("ℹ️ 광고가 유효합니다. 표시합니다.")
            
            guard let rootViewController = UIApplication.shared.getRootViewController() else {
                print("❌ Root View Controller를 찾을 수 없습니다.")
                self.appOpenAd = nil
                loadAd()
                return
            }
            
            isShowingAd = true
            appOpenAd.present(from: rootViewController)
        } else {
            print("⚠️ 광고가 만료되었습니다. 새로 로드합니다.")
            self.appOpenAd = nil
            loadAd()
        }
    }
    
    // MARK: - 광고 유효성 확인
    private func wasLoadTimeLessThanNHoursAgo() -> Bool {
        let now = Date()
        let timeInterval = now.timeIntervalSince(loadTime)
        return timeInterval < adExpirationTime
    }
    
    // MARK: - FullScreenContentDelegate
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("📊 광고 노출 기록됨")
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("👆 광고 클릭됨")
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ 광고 표시 실패: \(error.localizedDescription)")
        isShowingAd = false
        appOpenAd = nil
        loadAd()
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("🎬 광고 표시 시작")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ 광고 닫힘")
        isShowingAd = false
        appOpenAd = nil
        // 다음 광고를 위해 미리 로드
        loadAd()
    }
}

// MARK: - UIApplication Extension
extension UIApplication {
    func getRootViewController() -> UIViewController? {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        
        return getTopViewController(from: rootViewController)
    }
    
    private func getTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return getTopViewController(from: presentedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController,
           let topViewController = navigationController.topViewController {
            return getTopViewController(from: topViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return getTopViewController(from: selectedViewController)
        }
        
        return viewController
    }
}
