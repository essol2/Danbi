//
//  AnimatedOnboardingView.swift
//  danbi
//
//  Created by 이은솔 on 2/11/26.
//

import SwiftUI

// MARK: - Design Tokens
private let primaryGreen = Color(red: 0.55, green: 0.65, blue: 0.55)
private let lightGreen = Color(red: 0.65, green: 0.72, blue: 0.65)
private let backgroundBeige = Color(red: 0.95, green: 0.95, blue: 0.93)
private let subtitleGray = Color(red: 0.6, green: 0.6, blue: 0.6)
private let customFont = "MemomentKkukkukkR"

// MARK: - AnimatedOnboardingView
struct AnimatedOnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            backgroundBeige.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    OnboardingAddPlantPage()
                        .tag(0)
                    OnboardingPhotoRecognitionPage()
                        .tag(1)
                    OnboardingEditSwipePage()
                        .tag(2)
                    OnboardingDeleteSwipePage()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                // 페이지 인디케이터 + 버튼
                VStack(spacing: 24) {
                    // 페이지 인디케이터
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? primaryGreen : primaryGreen.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }

                    // 다음 / 시작하기 버튼
                    Button(action: {
                        if currentPage < 3 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        } else {
                            hasSeenOnboarding = true
                            dismiss()
                        }
                    }) {
                        Text(currentPage < 3 ? String(localized: "다음") : String(localized: "시작하기"))
                            .font(.custom(customFont, size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(primaryGreen)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Page 1: 식물 추가하기
private struct OnboardingAddPlantPage: View {
    @State private var isTapping = false
    @State private var showRipple = false
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // 제목
            Text("식물을 추가해보세요")
                .font(.custom(customFont, size: 28))
                .foregroundColor(.black)

            Text("아래 버튼을 눌러\n반려식물을 등록하세요")
                .font(.custom(customFont, size: 16))
                .foregroundColor(subtitleGray)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            Spacer().frame(height: 60)

            // 버튼 + 탭 애니메이션
            ZStack {
                // Ripple 효과
                RoundedRectangle(cornerRadius: 16)
                    .stroke(primaryGreen, lineWidth: 2)
                    .frame(height: 56)
                    .padding(.horizontal, 24)
                    .scaleEffect(showRipple ? 1.08 : 1.0)
                    .opacity(showRipple ? 0 : 0.5)

                // 모의 버튼
                Text("반려식물 추가하기")
                    .font(.custom(customFont, size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(primaryGreen)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 24)
                    .scaleEffect(isTapping ? 0.97 : 1.0)

                // 손가락 아이콘
                Image(systemName: "hand.point.up.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.black.opacity(0.55))
                    .offset(x: 20, y: 44)
                    .scaleEffect(isTapping ? 0.85 : 1.0)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            isVisible = true
            startTapAnimation()
        }
        .onDisappear {
            isVisible = false
        }
    }

    private func startTapAnimation() {
        guard isVisible else { return }

        // 첫 번째 탭은 0.5초 후
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            performTap()
        }
    }

    private func performTap() {
        guard isVisible else { return }

        // 탭 다운
        withAnimation(.easeInOut(duration: 0.2)) {
            isTapping = true
        }

        // Ripple 시작
        showRipple = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.6)) {
                showRipple = true
            }
        }

        // 탭 릴리즈
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isTapping = false
            }
        }

        // 반복 (2초 주기)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            performTap()
        }
    }
}

// MARK: - Page 2: 사진으로 식물 종류 찾기
private struct OnboardingPhotoRecognitionPage: View {
    @State private var isVisible = false
    @State private var showFlash = false
    @State private var showResult = false
    @State private var resultOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // 제목
            Text("사진으로 식물을 알아보세요")
                .font(.custom(customFont, size: 28))
                .foregroundColor(.black)

            Text("식물 사진을 찍으면\n종류와 관리법을 알려드려요")
                .font(.custom(customFont, size: 16))
                .foregroundColor(subtitleGray)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            Spacer().frame(height: 40)

            // 모의 사진 등록 UI
            ZStack {
                // 사진 영역
                VStack(spacing: 0) {
                    // 카메라 영역
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.96, green: 0.96, blue: 0.96))
                            .frame(height: 180)

                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(subtitleGray)

                            Text("사진 추가하기")
                                .font(.custom(customFont, size: 16))
                                .foregroundColor(subtitleGray)
                        }

                        // 플래시 효과
                        if showFlash {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .frame(height: 180)
                                .opacity(showFlash ? 0.8 : 0)
                        }
                    }

                    // 인식 결과 영역
                    if showResult {
                        HStack(spacing: 12) {
                            // 로딩 → 결과 전환
                            Image(systemName: "leaf.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(primaryGreen)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("몬스테라")
                                    .font(.custom(customFont, size: 18))
                                    .foregroundColor(.black)
                                Text("관리법: 7일마다 물주기")
                                    .font(.custom(customFont, size: 14))
                                    .foregroundColor(subtitleGray)
                            }

                            Spacer()

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(primaryGreen)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                        .padding(.top, 12)
                        .opacity(resultOpacity)
                    }
                }
                .padding(.horizontal, 24)

                // 손가락 아이콘 (사진 영역 탭)
                if !showResult {
                    Image(systemName: "hand.point.up.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.black.opacity(0.55))
                        .offset(x: 20, y: 20)
                }
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            isVisible = true
            startAnimation()
        }
        .onDisappear {
            isVisible = false
        }
    }

    private func startAnimation() {
        guard isVisible else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            performCycle()
        }
    }

    private func performCycle() {
        guard isVisible else { return }

        // 리셋
        showFlash = false
        showResult = false
        resultOpacity = 0

        // Phase 1: 플래시 (사진 촬영 시뮬레이션)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            guard isVisible else { return }
            withAnimation(.easeOut(duration: 0.15)) {
                showFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showFlash = false
                }
            }
        }

        // Phase 2: 결과 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard isVisible else { return }
            showResult = true
            withAnimation(.easeOut(duration: 0.5)) {
                resultOpacity = 1.0
            }
        }

        // Phase 3: 유지 후 반복
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            guard isVisible else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                resultOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                performCycle()
            }
        }
    }
}

// MARK: - Page 3: 우측 스와이프 수정
private struct OnboardingEditSwipePage: View {
    @State private var swipeOffset: CGFloat = 0
    @State private var handOffset: CGFloat = 0
    @State private var handOpacity: Double = 0
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("오른쪽으로 밀어 수정하기")
                .font(.custom(customFont, size: 28))
                .foregroundColor(.black)

            Text("식물 카드를 오른쪽으로 밀면\n수정할 수 있어요")
                .font(.custom(customFont, size: 16))
                .foregroundColor(subtitleGray)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            Spacer().frame(height: 40)

            // 스와이프 데모 영역
            ZStack(alignment: .leading) {
                // 뒤에 숨겨진 수정 액션
                HStack {
                    VStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("수정")
                            .font(.custom(customFont, size: 13))
                            .foregroundColor(.white)
                    }
                    .frame(width: 70, height: 80)
                    .background(primaryGreen)
                    .cornerRadius(12)
                    .padding(.leading, 28)
                    .opacity(Double(min(swipeOffset / 80.0, 1.0)))

                    Spacer()
                }

                // 식물 카드 (우측으로 이동)
                MockPlantCard()
                    .padding(.horizontal, 24)
                    .offset(x: swipeOffset)

                // 손가락 애니메이션
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.black.opacity(0.55))
                    .offset(x: handOffset, y: 70)
                    .opacity(handOpacity)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            isVisible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateSwipe()
            }
        }
        .onDisappear {
            isVisible = false
        }
    }

    private func animateSwipe() {
        guard isVisible else { return }

        let screenWidth = UIScreen.main.bounds.width

        // 초기 상태
        swipeOffset = 0
        handOffset = screenWidth * 0.3
        handOpacity = 1.0

        // Phase 1: 손가락이 우측으로 이동하면서 카드도 함께 이동
        withAnimation(.easeInOut(duration: 0.8)) {
            swipeOffset = 80
            handOffset = screenWidth * 0.55
        }

        // Phase 2: 잠시 유지 후 리셋
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeInOut(duration: 0.4)) {
                swipeOffset = 0
                handOpacity = 0
            }
        }

        // Phase 3: 반복
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            animateSwipe()
        }
    }
}

// MARK: - Page 4: 좌측 스와이프 삭제
private struct OnboardingDeleteSwipePage: View {
    @State private var swipeOffset: CGFloat = 0
    @State private var handOffset: CGFloat = 0
    @State private var handOpacity: Double = 0
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("왼쪽으로 밀어 삭제하기")
                .font(.custom(customFont, size: 28))
                .foregroundColor(.black)

            Text("식물 카드를 왼쪽으로 밀면\n삭제할 수 있어요")
                .font(.custom(customFont, size: 16))
                .foregroundColor(subtitleGray)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            Spacer().frame(height: 40)

            // 스와이프 데모 영역
            ZStack(alignment: .trailing) {
                // 뒤에 숨겨진 삭제 액션
                HStack {
                    Spacer()

                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("삭제")
                            .font(.custom(customFont, size: 13))
                            .foregroundColor(.white)
                    }
                    .frame(width: 70, height: 80)
                    .background(Color.red)
                    .cornerRadius(12)
                    .padding(.trailing, 28)
                    .opacity(Double(min(abs(swipeOffset) / 80.0, 1.0)))
                }

                // 식물 카드 (좌측으로 이동)
                MockPlantCard()
                    .padding(.horizontal, 24)
                    .offset(x: swipeOffset)

                // 손가락 애니메이션 (좌우 반전)
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.black.opacity(0.55))
                    .scaleEffect(x: -1, y: 1)
                    .offset(x: handOffset, y: 70)
                    .opacity(handOpacity)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            isVisible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateSwipe()
            }
        }
        .onDisappear {
            isVisible = false
        }
    }

    private func animateSwipe() {
        guard isVisible else { return }

        let screenWidth = UIScreen.main.bounds.width

        // 초기 상태
        swipeOffset = 0
        handOffset = screenWidth * -0.3
        handOpacity = 1.0

        // Phase 1: 손가락이 좌측으로 이동하면서 카드도 함께 이동
        withAnimation(.easeInOut(duration: 0.8)) {
            swipeOffset = -80
            handOffset = screenWidth * -0.55
        }

        // Phase 2: 잠시 유지 후 리셋
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeInOut(duration: 0.4)) {
                swipeOffset = 0
                handOpacity = 0
            }
        }

        // Phase 3: 반복
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            animateSwipe()
        }
    }
}

// MARK: - Mock Plant Card
private struct MockPlantCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // 모의 이미지 영역
            ZStack {
                Color(red: 0.88, green: 0.90, blue: 0.88)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 40))
                    .foregroundColor(lightGreen.opacity(0.5))
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)

            // 모의 정보 영역
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("몬스테라")
                            .font(.custom(customFont, size: 20))
                            .foregroundColor(.black)
                        Text("Monstera deliciosa")
                            .font(.custom(customFont, size: 14))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    }

                    Spacer()

                    // 모의 물주기 버튼
                    Circle()
                        .fill(lightGreen)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "drop.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // 모의 프로그레스 바
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.88, green: 0.90, blue: 0.88))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(lightGreen)
                        .frame(width: 80, height: 6)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                HStack {
                    Text("3일 전에 물을 줬어요!")
                        .font(.custom(customFont, size: 13))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    Spacer()
                    Text("7일마다")
                        .font(.custom(customFont, size: 13))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .background(Color.white)
        }
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}
