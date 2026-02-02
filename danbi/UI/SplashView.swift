//
//  SplashView.swift
//  danbi
//
//  Created by Claude on 2/2/26.
//

import SwiftUI

struct SplashView: View {
    @Binding var isLoading: Bool
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0.0
    @State private var animatingDot1 = false
    @State private var animatingDot2 = false
    @State private var animatingDot3 = false
    
    var body: some View {
        ZStack {
            // 배경색
            Color(red: 0.95, green: 0.98, blue: 0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 로고 아이콘
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(red: 0.65, green: 0.72, blue: 0.65))
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .padding(.bottom, 40)
                
                // 앱 이름
                Text("단비")
                    .font(.custom("MemomentKkukkukkR", size: 36))
                    .foregroundColor(.black)
                    .opacity(logoOpacity)
                
                // 부제
                Text("나의 반려식물에게 내리는 단비")
                    .font(.custom("MemomentKkukkukkR", size: 18))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    .padding(.top, 8)
                    .opacity(logoOpacity)
                
                Spacer()
                
                // 로딩 인디케이터 (3개의 점)
                if isLoading {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(red: 0.65, green: 0.72, blue: 0.65))
                            .frame(width: 12, height: 12)
                            .scaleEffect(animatingDot1 ? 1.3 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(0),
                                value: animatingDot1
                            )
                        
                        Circle()
                            .fill(Color(red: 0.65, green: 0.72, blue: 0.65))
                            .frame(width: 12, height: 12)
                            .scaleEffect(animatingDot2 ? 1.3 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(0.2),
                                value: animatingDot2
                            )
                        
                        Circle()
                            .fill(Color(red: 0.65, green: 0.72, blue: 0.65))
                            .frame(width: 12, height: 12)
                            .scaleEffect(animatingDot3 ? 1.3 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(0.4),
                                value: animatingDot3
                            )
                    }
                    .padding(.bottom, 100)
                    .onAppear {
                        animatingDot1 = true
                        animatingDot2 = true
                        animatingDot3 = true
                    }
                }
            }
        }
        .onAppear {
            // 로고 애니메이션
            withAnimation(.easeOut(duration: 0.8)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}
