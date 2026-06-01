import RealityKit

/// 트레이/볼륨에 놓인 "메모 카드"임을 표시하는 컴포넌트.
/// 드래그 제스처가 이 컴포넌트를 가진 엔티티만 대상으로 삼는다.
struct MemoCardComponent: Component {
    var payload: MemoPayload
    /// 트레이 슬롯 원위치 (드래그 후 복귀용)
    var home: SIMD3<Float>
}
