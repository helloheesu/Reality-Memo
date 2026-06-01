import Foundation
import RealityKit

/// 이 Entity가 월드 앵커로 "고정"될 수 있음을 나타내고, 현재 고정 상태를 보관하는 컴포넌트.
/// 고정 여부 = (anchorID != nil). 실제 앵커 생성/제거/추적은 AnchorManager가 담당.
/// 메모, 박스 등 엔티티 종류와 무관하게 재사용된다.
struct WorldAnchorComponent: Component {
    /// 현재 이 엔티티에 연결된 월드 앵커 id. nil이면 고정 안 된 상태.
    var anchorID: UUID? = nil

    /// 편의 프로퍼티
    var isPinned: Bool { anchorID != nil }
}
