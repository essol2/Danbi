//
//  SampleData.swift
//  danbi
//
//  Created by 이은솔 on 1/27/26.
//

import Foundation
import SwiftData

extension ModelContext {
    func addSamplePlants() {
        let calendar = Calendar.current
        
        // Sample plants
        let monstera = Plant(
            name: "나의 첫 몬스테라",
            scientificName: "스위스 치즈 식물",
            lastWatered: calendar.date(byAdding: .day, value: -2, to: Date())!,
            wateringInterval: 7
        )
        
        let pothos = Plant(
            name: "골든 포토스",
            scientificName: "진권수현에게 선물받은 아이",
            lastWatered: calendar.date(byAdding: .day, value: -5, to: Date())!,
            wateringInterval: 5
        )
        
        let snakePlant = Plant(
            name: "스네이크 플랜트",
            scientificName: "예민한 아이. 햇빛 조절 필수",
            lastWatered: calendar.date(byAdding: .day, value: -10, to: Date())!,
            wateringInterval: 14
        )
        
        let fiddleLeaf = Plant(
            name: "Fiddle Leaf Fig",
            scientificName: "Ficus lyrata",
            lastWatered: calendar.date(byAdding: .day, value: -4, to: Date())!,
            wateringInterval: 7
        )
        
        insert(monstera)
        insert(pothos)
        insert(snakePlant)
        insert(fiddleLeaf)
        
        try? save()
    }
}
