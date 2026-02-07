//
//  PerenualService.swift
//  danbi
//
//  Created by 이은솔 on 2/7/26.
//

import Foundation

/// Perenual API 식물 상세 정보
struct PlantCareInfo {
    let commonName: String
    let scientificName: String
    let watering: String              // "Frequent", "Average", "Minimum"
    let wateringBenchmark: String?    // "5-7 days" 등
    let sunlight: [String]            // ["Full sun", "Part shade"]
    let cycle: String?                // "Perennial", "Annual"
    let careGuide: String?            // 관리 가이드 텍스트
    let pruningMonth: [String]?       // 가지치기 월
    let growthRate: String?           // "High", "Medium", "Low"
    let maintenance: String?          // "High", "Medium", "Low"
    let poisonousToHumans: Bool?
    let poisonousToPets: Bool?

    /// 한국어 관리법 텍스트 생성
    var koreanCareNote: String {
        var lines: [String] = []

        // 물 주기
        let wateringKorean: String
        switch watering.lowercased() {
        case "frequent": wateringKorean = "자주 (흙이 마르면 바로)"
        case "average": wateringKorean = "보통 (흙 표면이 마르면)"
        case "minimum": wateringKorean = "적게 (흙이 완전히 마르면)"
        case "none": wateringKorean = "거의 필요 없음"
        default: wateringKorean = watering
        }

        if let benchmark = wateringBenchmark, !benchmark.isEmpty {
            lines.append("💧 물 주기: \(wateringKorean) (\(benchmark))")
        } else {
            lines.append("💧 물 주기: \(wateringKorean)")
        }

        // 햇빛
        if !sunlight.isEmpty {
            let sunlightKorean = sunlight.map { level -> String in
                switch level.lowercased() {
                case "full sun": return "직사광선"
                case "part shade", "sun-part shade": return "반양지"
                case "full shade": return "그늘"
                default: return level
                }
            }.joined(separator: ", ")
            lines.append("☀️ 햇빛: \(sunlightKorean)")
        }

        // 성장 속도
        if let rate = growthRate, !rate.isEmpty {
            let rateKorean: String
            switch rate.lowercased() {
            case "high": rateKorean = "빠름"
            case "moderate", "medium": rateKorean = "보통"
            case "low": rateKorean = "느림"
            default: rateKorean = rate
            }
            lines.append("🌱 성장 속도: \(rateKorean)")
        }

        // 관리 난이도
        if let maint = maintenance, !maint.isEmpty {
            let maintKorean: String
            switch maint.lowercased() {
            case "high": maintKorean = "높음"
            case "moderate", "medium": maintKorean = "보통"
            case "low": maintKorean = "낮음"
            default: maintKorean = maint
            }
            lines.append("🔧 관리 난이도: \(maintKorean)")
        }

        // 독성
        if let poisonousHuman = poisonousToHumans, poisonousHuman {
            lines.append("⚠️ 사람에게 독성 있음")
        }
        if let poisonousPet = poisonousToPets, poisonousPet {
            lines.append("🐾 반려동물에게 독성 있음")
        }

        return lines.joined(separator: "\n")
    }

    /// 물주기 추천 일수 (슬라이더용)
    var recommendedWateringDays: Int? {
        // wateringBenchmark에서 숫자 추출 (예: "5-7 days" → 6)
        if let benchmark = wateringBenchmark {
            let numbers = benchmark.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap { Int($0) }
                .filter { $0 > 0 }

            if numbers.count >= 2 {
                return (numbers[0] + numbers[1]) / 2  // 평균
            } else if let first = numbers.first {
                return first
            }
        }

        // benchmark 없으면 watering 레벨로 추정
        switch watering.lowercased() {
        case "frequent": return 3
        case "average": return 7
        case "minimum": return 14
        default: return nil
        }
    }
}

/// Perenual API 응답 모델
private struct PerenualListResponse: Codable {
    let data: [PerenualPlant]?
}

private struct PerenualPlant: Codable {
    let id: Int
    let common_name: String?
    let scientific_name: [String]?
    let watering: String?
    let sunlight: FlexibleStringArray?
    let cycle: String?
}

/// API에서 String 또는 [String]으로 올 수 있는 필드 처리
private struct FlexibleStringArray: Codable {
    let values: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode([String].self) {
            values = array
        } else if let single = try? container.decode(String.self) {
            values = single.isEmpty ? [] : [single]
        } else {
            values = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }
}

/// Perenual API 서비스
class PerenualService {
    static let shared = PerenualService()

    // ⚠️ 여기에 Perenual API 키를 입력하세요
    // https://perenual.com 에서 무료로 발급받을 수 있습니다
    private let apiKey = "sk-tKNu69874f19ae06414721"
    private let baseURL = "https://perenual.com/api/v2"

    private init() {}

    /// API 키가 설정되었는지 확인
    var isAPIKeyConfigured: Bool {
        return apiKey != "YOUR_PERENUAL_API_KEY" && !apiKey.isEmpty
    }

    /// 식물 이름으로 관리법 검색 (fallbackName으로 재검색 지원)
    func searchPlantCare(name: String, fallbackName: String? = nil, completion: @escaping (PlantCareInfo?) -> Void) {
        guard isAPIKeyConfigured else {
            print("⚠️ Perenual API 키 미설정")
            completion(nil)
            return
        }

        performSearch(name: name) { [weak self] careInfo in
            if let info = careInfo {
                completion(info)
            } else if let fallback = fallbackName, fallback != name {
                // 첫 번째 검색 실패 시 fallback 이름으로 재검색
                print("🔄 Perenual 재검색 시도: \(fallback)")
                self?.performSearch(name: fallback, completion: completion)
            } else {
                completion(nil)
            }
        }
    }

    /// 내부 검색 실행 (검색 결과에서 바로 관리법 생성 - 무료 플랜 호환)
    private func performSearch(name: String, completion: @escaping (PlantCareInfo?) -> Void) {
        let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let listURL = "\(baseURL)/species-list?key=\(apiKey)&q=\(query)"

        guard let url = URL(string: listURL) else {
            completion(nil)
            return
        }

        print("🌿 Perenual 식물 검색: \(name)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Perenual 검색 실패: \(error?.localizedDescription ?? "")")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // 디버깅: HTTP 상태 코드 & 응답 바디
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Perenual 응답 코드: \(httpResponse.statusCode)")
            }
            if let bodyString = String(data: data, encoding: .utf8) {
                print("📡 Perenual 응답 바디: \(bodyString.prefix(500))")
            }

            do {
                let listResponse = try JSONDecoder().decode(PerenualListResponse.self, from: data)
                guard let plant = listResponse.data?.first else {
                    print("❌ Perenual 검색 결과 없음: \(name)")
                    DispatchQueue.main.async { completion(nil) }
                    return
                }

                print("✅ Perenual 식물 찾음: \(plant.common_name ?? "") (ID: \(plant.id))")

                // 검색 결과에서 바로 PlantCareInfo 생성
                let careInfo = PlantCareInfo(
                    commonName: plant.common_name ?? "",
                    scientificName: plant.scientific_name?.first ?? "",
                    watering: plant.watering ?? "Average",
                    wateringBenchmark: nil,
                    sunlight: plant.sunlight?.values ?? [],
                    cycle: plant.cycle,
                    careGuide: nil,
                    pruningMonth: nil,
                    growthRate: nil,
                    maintenance: nil,
                    poisonousToHumans: nil,
                    poisonousToPets: nil
                )

                print("✅ Perenual 관리법 조회 완료:")
                print("   💧 물주기: \(careInfo.watering)")
                print("   ☀️ 햇빛: \(careInfo.sunlight)")
                print("   📝 추천 주기: \(careInfo.recommendedWateringDays ?? 0)일")

                DispatchQueue.main.async {
                    completion(careInfo)
                }
            } catch {
                print("❌ Perenual 파싱 오류: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}
