import Foundation
import SwiftUI
import UIKit

/// 메모 카드/스폰에 쓰는 데이터.
struct MemoPayload: Codable, Hashable {
    var text: String
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    /// 테스트용 더미 메모 목록 (길이 짧은/긴 것 섞음).
    static let dummies: [MemoPayload] = [
        .init(text: "우유",                                                          r: 1.0,  g: 0.9,  b: 0.2,  a: 1),
        .init(text: "치과 예약 — 목요일 오후 3시 30분, 강남역 2번 출구 연세치과",        r: 0.6,  g: 0.85, b: 1.0,  a: 1),
        .init(text: "운동",                                                          r: 0.7,  g: 1.0,  b: 0.7,  a: 1),
        .init(text: "내일 발표 자료 최종 검토하고 디자인팀에 공유, 폰트 크기 확인",       r: 1.0,  g: 0.6,  b: 0.7,  a: 1),
        .init(text: "물 마시기",                                                      r: 0.85, g: 0.8,  b: 1.0,  a: 1),
        .init(text: "장보기: 계란, 우유, 식빵, 사과, 양파, 당근, 닭가슴살, 올리브유",     r: 1.0,  g: 0.8,  b: 0.5,  a: 1),
        .init(text: "콜백",                                                          r: 0.95, g: 0.7,  b: 0.7,  a: 1),
        .init(text: "주말 여행 숙소 예약하고 렌터카 비교, 동선 짜서 일행에게 공유하기",     r: 0.8,  g: 0.95, b: 0.85, a: 1),
    ]

    /// payload 색을 UIColor로.
    var uiColor: UIColor {
        UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
}
