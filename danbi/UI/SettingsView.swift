//
//  SettingsView.swift
//  danbi
//
//  Created by 이은솔 on 1/29/26.
//

import SwiftUI
import SwiftData
import SafariServices

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var plants: [Plant]
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    // 인앱 브라우저 상태 관리
    @State private var showingSafari = false
    @State private var safariURL: URL?
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.95, green: 0.95, blue: 0.93)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
//                    VStack(alignment: .leading, spacing: 8) {
//                        HStack(spacing: 12) {
//                            Image(systemName: "leaf.fill")
//                                .font(.system(size: 28))
//                                .foregroundColor(Color(red: 0.55, green: 0.65, blue: 0.55))
//
//                            Text("Danbi")
//                                .font(.system(size: 32, weight: .bold))
//                                .foregroundColor(.black)
//                        }
//
//                        Text("Manage your preferences")
//                            .font(.system(size: 16))
//                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
//                    }
//                    .padding(.horizontal, 24)
//                    .padding(.top, 60)
                    
                    // 식물 예호가 섹션 (식물 개수 표시)
//                    VStack(alignment: .leading, spacing: 12) {
//                        HStack {
//                            Circle()
//                                .fill(Color(red: 0.65, green: 0.72, blue: 0.65))
//                                .frame(width: 60, height: 60)
//                                .overlay(
//                                    Image(systemName: "leaf.fill")
//                                        .font(.system(size: 28))
//                                        .foregroundColor(.white)
//                                )
//
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("식물 예호가")
//                                    .font(.system(size: 18, weight: .semibold))
//                                    .foregroundColor(.black)
//
//                                Text("내 정원에 \(plants.count)개의 식물")
//                                    .font(.system(size: 15))
//                                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
//                            }
//
//                            Spacer()
//
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
//                        }
//                        .padding(20)
//                        .background(Color.white)
//                        .cornerRadius(16)
//                    }
//                    .padding(.horizontal, 24)
                    
                    // 알림 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("알림")
                            .font(.custom("MemomentKkukkukkR", size: 14))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                            .padding(.horizontal, 24)
                        
                        HStack {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                                .frame(width: 40)
                            
                            Text("물주기 알림")
                                .font(.custom("MemomentKkukkukkR", size: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                                .tint(Color(red: 0.55, green: 0.65, blue: 0.55))
                                .onChange(of: notificationsEnabled) { oldValue, newValue in
                                    if newValue {
                                        // 알림 켜기 - 모든 식물 알림 재예약
                                        NotificationManager.shared.rescheduleAllNotifications(plants: plants)
                                    } else {
                                        // 알림 끄기 - 모든 알림 취소
                                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                    }
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 60)
                    
//                    // 테마 섹션
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("테마")
//                            .font(.system(size: 14, weight: .medium))
//                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
//                            .padding(.horizontal, 24)
//
//                        HStack {
//                            Image(systemName: "moon.fill")
//                                .font(.system(size: 20))
//                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
//                                .frame(width: 40)
//
//                            Text("다크 모드")
//                                .font(.system(size: 16))
//                                .foregroundColor(.black)
//
//                            Spacer()
//
//                            Toggle("", isOn: $darkModeEnabled)
//                                .labelsHidden()
//                                .tint(Color(red: 0.55, green: 0.65, blue: 0.55))
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 16)
//                        .background(Color.white)
//                        .cornerRadius(16)
//                        .padding(.horizontal, 24)
//                    }
                    
                    // 지원 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("지원")
                            .font(.custom("MemomentKkukkukkR", size: 14))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                if let url = URL(string: "https://forms.gle/PwM5X6pGdRcgPjFJ6") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                                        .frame(width: 40)
                                    
                                    Text("개발자에게 의견 보내기")
                                        .font(.custom("MemomentKkukkukkR", size: 16))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            Button(action: {
                                // Danbi 정보 - 인앱 브라우저로 열기
                                if let url = URL(string: "https://danbi-app.web.app") {
                                    safariURL = url
                                    showingSafari = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                                        .frame(width: 40)
                                    
                                    Text("Danbi 정보")
                                        .font(.custom("MemomentKkukkukkR", size: 16))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    }
                    
                    // 앱 버전
                    HStack {
                        Text("앱 버전")
                            .font(.custom("MemomentKkukkukkR", size: 15))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.custom("MemomentKkukkukkR", size: 15))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    
                    // Footer
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("Made with")
                                .font(.custom("MemomentKkukkukkR", size: 14))
                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.55, green: 0.65, blue: 0.55))
                            
                            Text("by Danbi Team")
                                .font(.custom("MemomentKkukkukkR", size: 14))
                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    
                    Color.clear.frame(height: 40)
                }
            }
            
            // 닫기 버튼
//            VStack {
//                HStack {
//                    Spacer()
//
//                    Button(action: {
//                        dismiss()
//                    }) {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 20, weight: .medium))
//                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
//                            .frame(width: 44, height: 44)
//                            .background(Color.white)
//                            .clipShape(Circle())
//                    }
//                    .padding(.trailing, 24)
//                    .padding(.top, 60)
//                }
//
//                Spacer()
//            }
        }
        .sheet(isPresented: $showingSafari) {
            if let url = safariURL {
                SafariView(url: url)
            }
        }
    }
}

// SafariViewController를 SwiftUI에서 사용하기 위한 Wrapper
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredControlTintColor = UIColor(red: 0.55, green: 0.65, blue: 0.55, alpha: 1.0)
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // 업데이트 필요 없음
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Plant.self, inMemory: true)
}
