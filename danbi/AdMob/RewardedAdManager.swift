//
//  RewardedAdManager.swift
//  danbi
//
//  Created by Claude on 2/2/26.
//

import Foundation
import GoogleMobileAds
import UIKit

class RewardedAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    // 싱글톤 인스턴스
    static let shared = RewardedAdManager()

    // 보상형 전면 광고 인스턴스 (RewardedInterstitialAd)
    private var rewardedInterstitialAd: RewardedInterstitialAd?

    // 광고 로딩 상태
    @Published var isLoadingAd = false

    // 광고 완료 콜백 (광고 dismiss 후 호출)
    private var adCompletion: ((Bool) -> Void)?
    private var didEarnReward = false

    // 광고 유닛 ID
    // 테스트 ID (구글 제공): ca-app-pub-3940256099942544/6978759866
    // 실제 ID: ca-app-pub-4144682979193082/8526010513
//    private let adUnitID = "ca-app-pub-3940256099942544/6978759866" // 테스트용
    private let adUnitID = "ca-app-pub-4144682979193082/8526010513" // 운영용

    private override init() {
        super.init()
    }

    // MARK: - 광고 로드
    func loadAd(completion: (() -> Void)? = nil) {
        // 이미 로딩 중이면 리턴
        guard !isLoadingAd else {
            completion?()
            return
        }

        isLoadingAd = true
        print("🔄 보상형 전면 광고 로딩 시작...")

        RewardedInterstitialAd.load(
            with: adUnitID,
            request: Request()
        ) { [weak self] ad, error in
            guard let self = self else { return }

            self.isLoadingAd = false

            if let error = error {
                print("❌ 보상형 전면 광고 로드 실패: \(error.localizedDescription)")
                completion?()
                return
            }

            print("✅ 보상형 전면 광고 로드 성공")
            self.rewardedInterstitialAd = ad
            self.rewardedInterstitialAd?.fullScreenContentDelegate = self
            completion?()
        }
    }

    // MARK: - 광고 표시
    func showAd(completion: @escaping (Bool) -> Void) {
        guard let rewardedInterstitialAd = rewardedInterstitialAd else {
            print("⚠️ 표시할 보상형 전면 광고가 없습니다.")
            completion(false)
            // 광고가 없으면 새로 로드
            loadAd()
            return
        }

        guard let rootViewController = UIApplication.shared.getRootViewController() else {
            print("❌ Root View Controller를 찾을 수 없습니다.")
            completion(false)
            return
        }

        print("🎬 보상형 전면 광고 표시 시작")

        // 콜백과 보상 상태 저장
        self.adCompletion = completion
        self.didEarnReward = false

        rewardedInterstitialAd.present(from: rootViewController) { [weak self] in
            // 보상 획득 기록 (광고 dismiss 후에 실제 처리)
            print("🎁 광고 시청 완료! 보상 획득")
            self?.didEarnReward = true
        }
    }

    // MARK: - FullScreenContentDelegate

    /// 광고가 화면에서 완전히 닫힌 후 호출
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📺 광고 UI 닫힘 완료")

        // 광고 dismiss 완료 후 completion 호출
        let rewarded = didEarnReward
        DispatchQueue.main.async { [weak self] in
            self?.adCompletion?(rewarded)
            self?.adCompletion = nil
            self?.didEarnReward = false
        }

        // 다음 광고를 위해 미리 로드
        rewardedInterstitialAd = nil
        loadAd()
    }

    /// 광고 표시 실패
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ 광고 표시 실패: \(error.localizedDescription)")

        DispatchQueue.main.async { [weak self] in
            self?.adCompletion?(false)
            self?.adCompletion = nil
            self?.didEarnReward = false
        }

        // 다음 광고를 위해 미리 로드
        rewardedInterstitialAd = nil
        loadAd()
    }

    // MARK: - 광고 사용 가능 여부 확인
    var isAdReady: Bool {
        return rewardedInterstitialAd != nil
    }
}
