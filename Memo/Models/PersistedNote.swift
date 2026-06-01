import Foundation
import SwiftData

/// 월드 앵커에 고정된 메모의 영속 데이터.
/// anchorID로 ARKit 월드 앵커와 1:1 매칭되고, 앱 재실행 시 이 데이터로 메모를 재생성한다.
@Model
final class PersistedNote {
    /// 연결된 월드 앵커 id (고유)
    @Attribute(.unique) var anchorID: UUID

    var text: String

    // 색 (RGBA, 0...1)
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    // 형태 (m)
    var width: Double
    var height: Double
    var thickness: Double

    init(anchorID: UUID, descriptor d: NoteDescriptorComponent) {
        self.anchorID = anchorID
        self.text = d.text
        self.r = d.red
        self.g = d.green
        self.b = d.blue
        self.a = d.alpha
        self.width = Double(d.width)
        self.height = Double(d.height)
        self.thickness = Double(d.thickness)
    }
}
