//
//  PlantKeywordDictionary.swift
//  danbi
//
//  Created by 이은솔 on 2/7/26.
//

import Foundation

struct PlantKeywordDictionary {

    // MARK: - 식물 감지용 키워드 (MobileNetV2 ImageNet 라벨)

    /// MobileNetV2가 식물 관련으로 분류할 수 있는 라벨 키워드들
    private static let plantRelatedKeywords: Set<String> = [
        // 꽃
        "daisy", "sunflower", "rose", "tulip", "dandelion", "lily",
        "orchid", "poppy", "lotus", "hibiscus", "lavender", "jasmine",

        // 채소/과일 (식물의 일부)
        "bell pepper", "cauliflower", "broccoli", "artichoke", "cardoon",
        "fig", "banana", "lemon", "orange", "strawberry", "pineapple",
        "rapeseed", "corn", "mushroom", "acorn", "cucumber", "zucchini",
        "head cabbage", "spaghetti squash", "butternut squash",

        // 화분/식물 관련 일반 클래스
        "flowerpot", "pot, flower pot", "vase",

        // 나무/자연
        "alp", "hay", "ear",
        "cliff", "valley", "lakeside", "seashore",
    ]

    /// MobileNetV2 라벨이 식물 관련인지 확인
    static func isPlantRelated(label: String) -> Bool {
        let lowered = label.lowercased()
        for keyword in plantRelatedKeywords {
            if lowered.contains(keyword) {
                return true
            }
        }
        return false
    }

    // MARK: - 인기 반려식물 목록

    /// 인기 반려식물 전체 목록 (검색 및 선택용)
    static let commonHouseplants: [(korean: String, english: String)] = [
        // 인기 실내 식물
        ("몬스테라", "Monstera Deliciosa"),
        ("스킨답서스", "Epipremnum aureum"),
        ("고무나무", "Ficus elastica"),
        ("산세베리아", "Sansevieria"),
        ("스투키", "Sansevieria cylindrica"),
        ("행운목", "Dracaena fragrans"),
        ("파키라", "Pachira aquatica"),
        ("아레카야자", "Dypsis lutescens"),
        ("개운죽", "Dracaena sanderiana"),
        ("알로에", "Aloe vera"),
        ("선인장", "Cactaceae"),
        ("다육이", "Succulent"),
        ("아이비", "Hedera helix"),
        ("테이블야자", "Chamaedorea elegans"),
        ("금전수", "Zamioculcas zamiifolia"),
        ("칼라테아", "Calathea"),
        ("필로덴드론", "Philodendron"),
        ("보스턴고사리", "Nephrolepis exaltata"),
        ("스파티필럼", "Spathiphyllum"),
        ("안스리움", "Anthurium"),
        ("호야", "Hoya"),
        ("제라늄", "Pelargonium"),
        ("라벤더", "Lavandula"),
        ("로즈마리", "Rosmarinus officinalis"),
        ("바질", "Ocimum basilicum"),
        // 추가 인기 식물
        ("떡갈고무나무", "Ficus lyrata"),
        ("벤자민고무나무", "Ficus benjamina"),
        ("뱅갈고무나무", "Ficus benghalensis"),
        ("여인초", "Strelitzia nicolai"),
        ("극락조", "Strelitzia reginae"),
        ("율마", "Cupressus macrocarpa"),
        ("유칼립투스", "Eucalyptus"),
        ("올리브나무", "Olea europaea"),
        ("레몬나무", "Citrus limon"),
        ("커피나무", "Coffea arabica"),
        ("소철", "Cycas revoluta"),
        ("아가베", "Agave"),
        ("크로톤", "Codiaeum variegatum"),
        ("드라세나", "Dracaena"),
        ("피토니아", "Fittonia"),
        ("페페로미아", "Peperomia"),
        ("트리안", "Tradescantia"),
        ("마란타", "Maranta leuconeura"),
        ("필레아", "Pilea peperomioides"),
        ("장미", "Rosa"),
        ("해바라기", "Helianthus annuus"),
        ("튤립", "Tulipa"),
        ("수국", "Hydrangea"),
        ("데이지", "Bellis perennis"),
        ("민들레", "Taraxacum"),
        ("백합", "Lilium"),
        ("난초", "Orchidaceae"),
        ("히아신스", "Hyacinthus"),
        ("수선화", "Narcissus"),
        ("국화", "Chrysanthemum"),
        ("허브", "Herb"),
        ("민트", "Mentha"),
        ("타임", "Thymus"),
    ]

    // MARK: - 학명 → 한국어 매핑 (PlantNet API 결과용)

    /// 학명/속명으로 한국어 이름 찾기
    static func findKoreanName(for scientificName: String) -> String? {
        let lowered = scientificName.lowercased()

        // commonHouseplants에서 학명 매칭 시도
        for plant in commonHouseplants {
            if plant.english.lowercased().contains(lowered) ||
               lowered.contains(plant.english.lowercased().components(separatedBy: " ").first ?? "") {
                return plant.korean
            }
        }

        // 추가 학명 → 한국어 매핑 (PlantNet에서 자주 반환하는 학명)
        for (keyword, korean) in scientificToKorean {
            if lowered.contains(keyword.lowercased()) {
                return korean
            }
        }

        return nil
    }

    /// PlantNet API에서 자주 반환하는 학명 → 한국어 매핑
    private static let scientificToKorean: [String: String] = [
        "Monstera deliciosa": "몬스테라",
        "Monstera adansonii": "몬스테라 아단소니",
        "Epipremnum aureum": "스킨답서스",
        "Ficus elastica": "고무나무",
        "Ficus lyrata": "떡갈고무나무",
        "Ficus benjamina": "벤자민고무나무",
        "Ficus benghalensis": "뱅갈고무나무",
        "Sansevieria trifasciata": "산세베리아",
        "Dracaena trifasciata": "산세베리아",
        "Sansevieria cylindrica": "스투키",
        "Dracaena fragrans": "행운목",
        "Dracaena sanderiana": "개운죽",
        "Dracaena marginata": "드라세나 마지나타",
        "Pachira aquatica": "파키라",
        "Dypsis lutescens": "아레카야자",
        "Chamaedorea elegans": "테이블야자",
        "Aloe vera": "알로에",
        "Hedera helix": "아이비",
        "Zamioculcas zamiifolia": "금전수",
        "Spathiphyllum": "스파티필럼",
        "Anthurium": "안스리움",
        "Philodendron": "필로덴드론",
        "Calathea": "칼라테아",
        "Nephrolepis exaltata": "보스턴고사리",
        "Strelitzia nicolai": "여인초",
        "Strelitzia reginae": "극락조",
        "Cupressus macrocarpa": "율마",
        "Olea europaea": "올리브나무",
        "Citrus limon": "레몬나무",
        "Coffea arabica": "커피나무",
        "Cycas revoluta": "소철",
        "Codiaeum variegatum": "크로톤",
        "Fittonia": "피토니아",
        "Peperomia": "페페로미아",
        "Tradescantia": "트리안",
        "Maranta leuconeura": "마란타",
        "Pilea peperomioides": "필레아",
        "Hoya carnosa": "호야",
        "Pelargonium": "제라늄",
        "Lavandula": "라벤더",
        "Rosmarinus officinalis": "로즈마리",
        "Salvia rosmarinus": "로즈마리",
        "Ocimum basilicum": "바질",
        "Mentha": "민트",
        "Rosa": "장미",
        "Helianthus annuus": "해바라기",
        "Tulipa": "튤립",
        "Hydrangea": "수국",
        "Narcissus": "수선화",
        "Chrysanthemum": "국화",
        "Lilium": "백합",
        "Orchidaceae": "난초",
        "Phalaenopsis": "호접란",
        "Dendrobium": "석곡란",
        "Cactaceae": "선인장",
        "Echeveria": "에케베리아",
        "Haworthia": "하월시아",
        "Crassula ovata": "염좌",
        "Agave": "아가베",
        "Thymus": "타임",
        "Hyacinthus": "히아신스",
    ]

    // MARK: - Perenual API 검색용 영어 일반명 매핑

    /// 한국어 이름 → Perenual API 검색에 최적화된 common name
    /// (학명 대신 일반명으로 검색해야 결과가 잘 나옴)
    static let perenualSearchName: [String: String] = [
        "몬스테라": "Monstera",
        "스킨답서스": "Golden Pothos",
        "고무나무": "Rubber plant",
        "산세베리아": "Snake plant",
        "스투키": "Cylindrical snake plant",
        "행운목": "Corn plant",
        "파키라": "Money tree",
        "아레카야자": "Areca palm",
        "개운죽": "Lucky bamboo",
        "알로에": "Aloe vera",
        "선인장": "Cactus",
        "다육이": "Succulent",
        "아이비": "English ivy",
        "테이블야자": "Parlor palm",
        "금전수": "ZZ plant",
        "칼라테아": "Calathea",
        "필로덴드론": "Philodendron",
        "보스턴고사리": "Boston fern",
        "스파티필럼": "Peace lily",
        "안스리움": "Anthurium",
        "호야": "Hoya",
        "제라늄": "Geranium",
        "라벤더": "Lavender",
        "로즈마리": "Rosemary",
        "바질": "Basil",
        "떡갈고무나무": "Fiddle leaf fig",
        "벤자민고무나무": "Weeping fig",
        "뱅갈고무나무": "Bengal fig",
        "여인초": "White bird of paradise",
        "극락조": "Bird of paradise",
        "율마": "Lemon cypress",
        "유칼립투스": "Eucalyptus",
        "올리브나무": "Olive tree",
        "레몬나무": "Lemon tree",
        "커피나무": "Coffee plant",
        "소철": "Sago palm",
        "아가베": "Agave",
        "크로톤": "Croton",
        "드라세나": "Dracaena",
        "피토니아": "Nerve plant",
        "페페로미아": "Peperomia",
        "트리안": "Tradescantia",
        "마란타": "Prayer plant",
        "필레아": "Chinese money plant",
        "장미": "Rose",
        "해바라기": "Sunflower",
        "튤립": "Tulip",
        "수국": "Hydrangea",
        "데이지": "Daisy",
        "백합": "Lily",
        "난초": "Orchid",
        "히아신스": "Hyacinth",
        "수선화": "Daffodil",
        "국화": "Chrysanthemum",
        "민트": "Mint",
        "타임": "Thyme",
    ]

    /// 한국어/영어 이름으로 검색
    static func search(query: String) -> [(korean: String, english: String)] {
        let lowered = query.lowercased().trimmingCharacters(in: .whitespaces)
        if lowered.isEmpty { return commonHouseplants }

        return commonHouseplants.filter { plant in
            plant.korean.lowercased().contains(lowered) ||
            plant.english.lowercased().contains(lowered)
        }
    }
}
