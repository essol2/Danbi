//
//  PlantClassifier.swift
//  danbi
//
//  Created by 이은솔 on 2/7/26.
//

import Foundation
import UIKit
import CoreML
import Vision

/// 식물 인식 결과
enum PlantRecognitionResult {
    /// PlantNet API로 정확한 식물 인식 성공
    case identified(results: [PlantIdentificationResult])
    /// API 실패 → MobileNet으로 식물 감지됨 → 목록에서 선택
    case plantDetected
    /// 식물이 아닌 것으로 판단
    case notPlant
}

class PlantClassifier {
    static let shared = PlantClassifier()

    private var model: VNCoreMLModel?

    private init() {
        loadModel()
    }

    private func loadModel() {
        do {
            let config = MLModelConfiguration()
            let mlModel = try MobileNetV2FP16(configuration: config).model
            model = try VNCoreMLModel(for: mlModel)
            print("✅ MobileNetV2 모델 로드 완료")
        } catch {
            print("❌ MobileNetV2 모델 로드 실패: \(error.localizedDescription)")
        }
    }

    /// 이미지 분류 - PlantNet API 우선, 실패 시 MobileNet 폴백
    func classify(image: UIImage, completion: @escaping (PlantRecognitionResult) -> Void) {
        // 1단계: PlantNet API 시도
        if PlantNetService.shared.isAPIKeyConfigured {
            print("🌐 PlantNet API로 식물 인식 시도...")
            PlantNetService.shared.identify(image: image) { [weak self] result in
                switch result {
                case .success(let identifications):
                    // API 인식 성공
                    if !identifications.isEmpty && identifications[0].confidence >= 0.10 {
                        completion(.identified(results: identifications))
                    } else {
                        // 신뢰도가 너무 낮으면 목록 선택으로 폴백
                        print("⚠️ PlantNet 신뢰도 낮음 → 목록 선택으로 폴백")
                        self?.fallbackToMobileNet(image: image, completion: completion)
                    }
                case .failure(let error):
                    // API 실패 → MobileNet 폴백
                    print("⚠️ PlantNet API 실패 (\(error)) → MobileNet 폴백")
                    self?.fallbackToMobileNet(image: image, completion: completion)
                }
            }
        } else {
            // API 키 미설정 → MobileNet 직접 사용
            print("⚠️ PlantNet API 키 미설정 → MobileNet 사용")
            fallbackToMobileNet(image: image, completion: completion)
        }
    }

    /// MobileNet 폴백 - 식물 감지 여부만 판단
    private func fallbackToMobileNet(image: UIImage, completion: @escaping (PlantRecognitionResult) -> Void) {
        guard let model = model else {
            print("❌ 모델이 로드되지 않음")
            completion(.notPlant)
            return
        }

        guard let ciImage = CIImage(image: image) else {
            print("❌ CIImage 변환 실패")
            completion(.notPlant)
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  error == nil else {
                print("❌ 분류 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                DispatchQueue.main.async { completion(.notPlant) }
                return
            }

            // 상위 10개 결과에서 식물 관련 키워드 검색
            let topResults = results.prefix(10)
            let hasPlant = topResults.contains { observation in
                let label = observation.identifier.lowercased()
                return PlantKeywordDictionary.isPlantRelated(label: label) && observation.confidence >= 0.05
            }

            // 디버깅
            print("🔍 MobileNetV2 상위 5개 결과:")
            for result in results.prefix(5) {
                let isPlant = PlantKeywordDictionary.isPlantRelated(label: result.identifier.lowercased())
                print("   \(isPlant ? "🌿" : "  ") \(result.identifier): \(String(format: "%.2f%%", result.confidence * 100))")
            }
            print("   → 식물 감지: \(hasPlant ? "✅" : "❌")")

            DispatchQueue.main.async {
                completion(hasPlant ? .plantDetected : .notPlant)
            }
        }

        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ Vision 요청 실패: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.notPlant) }
            }
        }
    }
}
