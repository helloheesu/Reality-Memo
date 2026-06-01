import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// 메모 목록 윈도우에서 immersive 공간으로 드래그할 때 실어 나르는 데이터.
/// (메모 목록 자체는 더미 — 세부 구현은 다른 담당자. 여기서는 드래그-스폰 테스트용.)
struct MemoPayload: Codable, Transferable, Hashable {
    var text: String
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .memoPayload)
    }

    /// 테스트용 더미 메모 목록 (여러 화면에서 공유).
    static let dummies: [MemoPayload] = [
        .init(text: "우유 사기", r: 1.0,  g: 0.9,  b: 0.2,  a: 1),
        .init(text: "회의 14시", r: 0.6,  g: 0.85, b: 1.0,  a: 1),
        .init(text: "내일 발표", r: 1.0,  g: 0.6,  b: 0.7,  a: 1),
        .init(text: "운동하기",  r: 0.7,  g: 1.0,  b: 0.7,  a: 1),
        .init(text: "약속 잡기",  r: 1.0,  g: 0.8,  b: 0.5,  a: 1),
        .init(text: "책 읽기",    r: 0.85, g: 0.8,  b: 1.0,  a: 1),
    ]

    /// payload 색을 UIColor로.
    var uiColor: UIColor {
        UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
}

extension UTType {
    /// 앱 내부 드래그용 커스텀 타입. (프로덕션에선 Info.plist에 Exported Type 선언 권장.)
    static let memoPayload = UTType(exportedAs: "com.heesu.Memo.memo-payload")
}
