//
//  Plant.swift
//  danbi
//
//  Created by 이은솔 on 1/27/26.
//

import Foundation
import SwiftData

@Model
final class Plant {
    var id: UUID
    var name: String
    var scientificName: String
    var lastWatered: Date
    var wateringInterval: Int // days
    var imageData: Data?
    
    init(name: String, scientificName: String, lastWatered: Date, wateringInterval: Int, imageData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.scientificName = scientificName
        self.lastWatered = lastWatered
        self.wateringInterval = wateringInterval
        self.imageData = imageData
    }
    
    // 물을 줘야 하는지 계산
    var needsWater: Bool {
        let daysSinceWatered = Calendar.current.dateComponents([.day], from: lastWatered, to: Date()).day ?? 0
        return daysSinceWatered >= wateringInterval
    }
    
    // 마지막 물주기로부터 경과한 날짜
    var daysSinceWatered: Int {
        Calendar.current.dateComponents([.day], from: lastWatered, to: Date()).day ?? 0
    }
    
    // 진행률 계산 (0.0 ~ 1.0)
    var wateringProgress: Double {
        let days = Double(daysSinceWatered)
        let interval = Double(wateringInterval)
        return min(days / interval, 1.0)
    }
    
    // 물주기 날짜가 변경될 때 알림 자동 업데이트
    func updateWateringNotification() {
        NotificationManager.shared.scheduleWateringNotification(for: self)
    }
}

