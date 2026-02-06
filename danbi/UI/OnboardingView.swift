//
//  OnboardingView.swift
//  danbi
//
//  Created by 이은솔 on 2/6/26.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.93)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // 앱 로고
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(red: 0.65, green: 0.72, blue: 0.65))
                    }

                    Text("단비")
                        .font(.custom("MemomentKkukkukkR", size: 32))
                        .foregroundColor(.black)

                    Text("나의 반려식물에게 내리는 단비")
                        .font(.custom("MemomentKkukkukkR", size: 16))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                }

                Spacer()
                    .frame(height: 48)

                // 기능 설명
                VStack(spacing: 20) {
                    OnboardingFeatureRow(
                        icon: "plus.circle.fill",
                        title: "반려식물 추가",
                        description: "반려식물을 등록하고 관리하세요"
                    )

                    OnboardingFeatureRow(
                        icon: "drop.fill",
                        title: "물주기 기록",
                        description: "물방울 버튼으로 물준 기록을 남기세요"
                    )

                    OnboardingFeatureRow(
                        icon: "hand.draw.fill",
                        title: "스와이프",
                        description: "좌우로 스와이프해서 수정하거나 삭제하세요"
                    )

                    OnboardingFeatureRow(
                        icon: "arrow.up.arrow.down",
                        title: "순서 변경",
                        description: "길게 눌러 드래그로 순서를 바꾸세요"
                    )
                }
                .padding(.horizontal, 32)

                Spacer()

                // 시작하기 버튼
                Button(action: {
                    hasSeenOnboarding = true
                    dismiss()
                }) {
                    Text("시작하기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0.55, green: 0.65, blue: 0.55))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(red: 0.65, green: 0.72, blue: 0.65).opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.55, green: 0.65, blue: 0.55))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("MemomentKkukkukkR", size: 18))
                    .foregroundColor(.black)

                Text(description)
                    .font(.custom("MemomentKkukkukkR", size: 14))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }

            Spacer()
        }
    }
}
