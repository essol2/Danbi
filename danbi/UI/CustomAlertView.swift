//
//  CustomAlertView.swift
//  danbi
//
//  Created by Claude on 2/2/26.
//

import SwiftUI

struct CustomAlertView: View {
    let icon: String // SF Symbol 이름
    let title: String
    let message: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let primaryAction: () -> Void
    let secondaryAction: (() -> Void)?
    
    @Binding var isPresented: Bool
    
    init(
        isPresented: Binding<Bool>,
        icon: String = "play.circle.fill",
        title: String,
        message: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String? = String(localized: "취소"),
        primaryAction: @escaping () -> Void,
        secondaryAction: (() -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.icon = icon
        self.title = title
        self.message = message
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
    var body: some View {
        ZStack {
            // 배경 어둡게
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isPresented = false
                    }
                    secondaryAction?()
                }
            
            // Alert 컨텐츠
            VStack(spacing: 24) {
                // 아이콘
                ZStack {
                    Circle()
                        .fill(Color(red: 0.65, green: 0.72, blue: 0.65).opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundColor(Color(red: 0.65, green: 0.72, blue: 0.65))
                }
                .padding(.top, 8)
                
                VStack(spacing: 12) {
                    // 제목
                    Text(title)
                        .font(.custom("MemomentKkukkukkR", size: 22))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    // 메시지
                    Text(message)
                        .font(.custom("MemomentKkukkukkR", size: 16))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                // 버튼들
                VStack(spacing: 12) {
                    // Primary 버튼
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isPresented = false
                        }
                        primaryAction()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                            
                            Text(primaryButtonTitle)
                                .font(.custom("MemomentKkukkukkR", size: 18))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0.65, green: 0.72, blue: 0.65))
                        .cornerRadius(16)
                    }
                    
                    // Secondary 버튼 (옵션)
                    if let secondaryButtonTitle = secondaryButtonTitle {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isPresented = false
                            }
                            secondaryAction?()
                        }) {
                            Text(secondaryButtonTitle)
                                .font(.custom("MemomentKkukkukkR", size: 18))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
            .scaleEffect(isPresented ? 1.0 : 0.8)
            .opacity(isPresented ? 1.0 : 0.0)
        }
    }
}

// MARK: - View Extension for easy usage
extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        icon: String = "play.circle.fill",
        title: String,
        message: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String? = String(localized: "취소"),
        primaryAction: @escaping () -> Void,
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue {
                CustomAlertView(
                    isPresented: isPresented,
                    icon: icon,
                    title: title,
                    message: message,
                    primaryButtonTitle: primaryButtonTitle,
                    secondaryButtonTitle: secondaryButtonTitle,
                    primaryAction: primaryAction,
                    secondaryAction: secondaryAction
                )
                .transition(.opacity.combined(with: .scale))
                .zIndex(999)
            }
        }
        .animation(.easeOut(duration: 0.2), value: isPresented.wrappedValue)
    }
}
