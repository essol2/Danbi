//
//  RewardedAdManager.swift
//  danbi
//
//  Created by Claude on 2/2/26.
//

import Foundation
import GoogleMobileAds
import UIKit

class RewardedAdManager: NSObject, ObservableObject {
    // 싱글톤 인스턴스
    static let shared = RewardedAdManager()

    // 보상형 전면 광고 인스턴스 (RewardedInterstitialAd)
    private var rewardedInterstitialAd: RewardedInterstitialAd?

    // 광고 로딩 상태
    @Published var isLoadingAd = false

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

        rewardedInterstitialAd.present(from: rootViewController) { [weak self] in
            // 광고 시청 완료 - 보상 지급
            print("🎁 광고 시청 완료! 보상 지급")
            completion(true)

            // 다음 광고를 위해 미리 로드
            self?.rewardedInterstitialAd = nil
            self?.loadAd()
        }
    }

    // MARK: - 광고 사용 가능 여부 확인
    var isAdReady: Bool {
        return rewardedInterstitialAd != nil
    }
}
