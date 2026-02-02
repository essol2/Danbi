//
//  AdBannerView.swift
//  danbi
//
//  Created by 이은솔 on 2/1/26.
//

import Foundation
import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewControllerRepresentable {
    // 구글 제공 테스트 배너 ID
    let adUnitID = "ca-app-pub-4144682979193082/4816730171"

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let bannerView = BannerView(adSize: AdSizeBanner)

        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = viewController
        
        // 뷰 컨트롤러에 배너 추가
        viewController.view.addSubview(bannerView)
        bannerView.load(Request())
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
