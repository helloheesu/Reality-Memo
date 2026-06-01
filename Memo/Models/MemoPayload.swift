import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// 메모 목록 윈도우에서 immersive 공간으로 드래그할 때 실어 나르는 데이터.
/// (메모 목록 자체는 더미 — 세부 구현은 다른 담당자. 여기서는 드래그-스폰 테스트용.)
struct MemoPayload: Codable, Transferable {
    var text: String
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .memoPayload)
    }
}

extension UTType {
    /// 앱 내부 드래그용 커스텀 타입. (프로덕션에선 Info.plist에 Exported Type 선언 권장.)
    static let memoPayload = UTType(exportedAs: "com.heesu.Memo.memo-payload")
}
