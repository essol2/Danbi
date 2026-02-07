//
//  PlantNetService.swift
//  danbi
//
//  Created by 이은솔 on 2/7/26.
//

import Foundation
import UIKit

/// Pl@ntNet API 응답 모델
struct PlantNetResponse: Codable {
    let bestMatch: String?
    let results: [PlantNetResult]?
    let remainingIdentificationRequests: Int?
}

struct PlantNetResult: Codable {
    let score: Double
    let species: PlantNetSpecies
}

struct PlantNetSpecies: Codable {
    let scientificNameWithoutAuthor: String
    let scientificName: String
    let commonNames: [String]?
    let genus: PlantNetTaxon?
    let family: PlantNetTaxon?
}

struct PlantNetTaxon: Codable {
    let scientificName: String
}

/// 식물 인식 결과
struct PlantIdentificationResult {
    let koreanName: String
    let englishName: String
    let scientificName: String
    let confidence: Double
}

/// Pl@ntNet API 서비스
class PlantNetService {
    static let shared = PlantNetService()

    // ⚠️ 여기에 Pl@ntNet API 키를 입력하세요
    // https://my.plantnet.org 에서 무료로 발급받을 수 있습니다
    private let apiKey = "2b10SsyOqzJcAKQ8iByuoliQu"
    private let baseURL = "https://my-api.plantnet.org/v2/identify/all"

    private init() {}

    /// API 키가 설정되었는지 확인
    var isAPIKeyConfigured: Bool {
        return apiKey != "YOUR_API_KEY_HERE" && !apiKey.isEmpty
    }

    /// 이미지로 식물 인식 요청
    func identify(image: UIImage, completion: @escaping (Result<[PlantIdentificationResult], PlantNetError>) -> Void) {
        guard isAPIKeyConfigured else {
            print("⚠️ PlantNet API 키가 설정되지 않음")
            completion(.failure(.apiKeyNotConfigured))
            return
        }

        // JPEG 이미지 데이터 생성
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("❌ 이미지 변환 실패")
            completion(.failure(.imageConversionFailed))
            return
        }

        // URL 구성
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "api-key", value: apiKey),
            URLQueryItem(name: "lang", value: "en"),
            URLQueryItem(name: "nb-results", value: "3")
        ]

        guard let url = components.url else {
            completion(.failure(.invalidURL))
            return
        }

        // Multipart form data 요청 생성
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15

        var body = Data()

        // 이미지 파트
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"images\"; filename=\"plant.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // organs 파트 (auto로 설정)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"organs\"\r\n\r\n".data(using: .utf8)!)
        body.append("auto\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        print("🌐 PlantNet API 요청 중... URL: \(url.absoluteString)")
        print("🌐 이미지 크기: \(imageData.count / 1024)KB")

        URLSession.shared.dataTask(with: request) { data, response, error in
            // 네트워크 오류
            if let error = error {
                print("❌ PlantNet 네트워크 오류: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }

            // HTTP 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 PlantNet 응답 코드: \(httpResponse.statusCode)")

                // 에러 응답 바디 로깅
                if httpResponse.statusCode != 200, let data = data,
                   let bodyString = String(data: data, encoding: .utf8) {
                    print("📡 PlantNet 응답 바디: \(bodyString)")
                }

                switch httpResponse.statusCode {
                case 429:
                    print("⚠️ PlantNet 일일 한도 초과 (429)")
                    DispatchQueue.main.async {
                        completion(.failure(.quotaExceeded))
                    }
                    return
                case 401:
                    print("❌ PlantNet API 키 오류 (401)")
                    DispatchQueue.main.async {
                        completion(.failure(.apiKeyNotConfigured))
                    }
                    return
                case 404:
                    // 404는 "식물을 인식하지 못함"일 수 있음
                    print("❌ PlantNet 404 - 식물 인식 불가 또는 엔드포인트 오류")
                    DispatchQueue.main.async {
                        completion(.failure(.plantNotRecognized))
                    }
                    return
                case 200:
                    break // 성공
                default:
                    print("❌ PlantNet 서버 오류 (\(httpResponse.statusCode))")
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(httpResponse.statusCode)))
                    }
                    return
                }
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            // JSON 파싱
            do {
                let response = try JSONDecoder().decode(PlantNetResponse.self, from: data)

                if let remaining = response.remainingIdentificationRequests {
                    print("📊 PlantNet 남은 요청 수: \(remaining)")
                }

                guard let results = response.results, !results.isEmpty else {
                    print("❌ PlantNet 인식 결과 없음")
                    DispatchQueue.main.async {
                        completion(.failure(.plantNotRecognized))
                    }
                    return
                }

                // 결과 변환
                let identifications = results.map { result -> PlantIdentificationResult in
                    // 한국어 이름: 딕셔너리 매핑 우선, 없으면 영어 common name 사용
                    let koreanName = PlantKeywordDictionary.findKoreanName(for: result.species.scientificNameWithoutAuthor)
                        ?? result.species.commonNames?.first
                        ?? result.species.scientificNameWithoutAuthor

                    let englishName = result.species.commonNames?.first(where: { $0.range(of: "[a-zA-Z]", options: .regularExpression) != nil })
                        ?? result.species.scientificNameWithoutAuthor

                    return PlantIdentificationResult(
                        koreanName: koreanName,
                        englishName: englishName,
                        scientificName: result.species.scientificNameWithoutAuthor,
                        confidence: result.score
                    )
                }

                // 디버깅
                print("🌿 PlantNet 인식 결과:")
                for (i, id) in identifications.enumerated() {
                    print("   \(i+1). \(id.koreanName) (\(id.scientificName)) - \(String(format: "%.1f%%", id.confidence * 100))")
                }

                DispatchQueue.main.async {
                    completion(.success(identifications))
                }
            } catch {
                print("❌ PlantNet JSON 파싱 오류: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.parsingError))
                }
            }
        }.resume()
    }
}

/// PlantNet 오류 유형
enum PlantNetError: Error {
    case apiKeyNotConfigured
    case imageConversionFailed
    case invalidURL
    case networkError(String)
    case quotaExceeded
    case serverError(Int)
    case noData
    case parsingError
    case plantNotRecognized

    var isQuotaExceeded: Bool {
        if case .quotaExceeded = self { return true }
        return false
    }
}
