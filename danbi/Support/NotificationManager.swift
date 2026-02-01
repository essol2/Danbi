//
//  NotificationManager.swift
//  danbi
//
//  Created by 이은솔 on 1/29/26.
//

import Foundation
import UserNotifications
import SwiftData

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    // 알림 권한 요청
    func requestAuthorization() {
        // 메인 스레드에서 실행
        DispatchQueue.main.async {
            // 먼저 현재 권한 상태 확인
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("현재 알림 권한 상태: \(settings.authorizationStatus.rawValue)")
                
                // 권한이 결정되지 않았을 때만 요청
                if settings.authorizationStatus == .notDetermined {
                    // 메인 스레드에서 권한 요청
                    DispatchQueue.main.async {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                            DispatchQueue.main.async {
                                if granted {
                                    print("✅ 알림 권한 허용됨")
                                } else {
                                    print("❌ 알림 권한 거부됨")
                                }
                                if let error = error {
                                    print("⚠️ 알림 권한 오류: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                } else if settings.authorizationStatus == .denied {
                    print("⚠️ 알림 권한이 거부되어 있습니다. 시스템 환경설정에서 변경하세요.")
                } else if settings.authorizationStatus == .authorized {
                    print("✅ 알림 권한이 이미 허용되어 있습니다.")
                }
            }
        }
    }
    
    // 특정 식물의 물주기 알림 예약
    func scheduleWateringNotification(for plant: Plant) {
        // 기존 알림 취소
        cancelNotification(for: plant)
        
        // 다음 물주기 날짜 계산
        let nextWateringDate = Calendar.current.date(
            byAdding: .day,
            value: plant.wateringInterval - plant.daysSinceWatered,
            to: Date()
        )
        
        guard let wateringDate = nextWateringDate else { return }
        
        // 이미 지난 날짜면 알림 예약 안 함
        if wateringDate <= Date() {
            return
        }
        
        // 알림 내용 설정
        let content = UNMutableNotificationContent()
        content.title = "💧 물 줄 시간이에요!"
        content.body = "\(plant.name)에게 단비를 내려주세요"
        content.sound = .default
        content.badge = 1
        
        // 알림 시간 설정 (아침 9시)
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: wateringDate)
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // 알림 요청 생성
        let identifier = "watering-\(plant.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // 알림 예약
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 예약 실패: \(error.localizedDescription)")
            } else {
                print("\(plant.name) 알림 예약 완료: \(wateringDate)")
            }
        }
    }
    
    // 특정 식물의 알림 취소
    func cancelNotification(for plant: Plant) {
        let identifier = "watering-\(plant.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // 모든 식물의 알림 다시 예약
    func rescheduleAllNotifications(plants: [Plant]) {
        // 모든 기존 알림 취소
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // 각 식물에 대해 알림 예약
        for plant in plants {
            scheduleWateringNotification(for: plant)
        }
    }
    
    // 예약된 알림 확인 (디버깅용)
    func printPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("=== 예약된 알림 목록 ===")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let date = trigger.nextTriggerDate() {
                    print("\(request.identifier): \(date)")
                }
            }
            print("총 \(requests.count)개의 알림")
        }
    }
}
