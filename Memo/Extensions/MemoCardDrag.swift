import RealityKit
import SwiftUI

extension View {
    /// 메모 카드(`MemoCardComponent`)를 공간 제스처로 끌어내기.
    /// - 드래그 중: 카드가 손끝을 따라옴.
    /// - 드래그 끝: 카드의 월드 위치와 payload로 `onPullOut` 호출 후, 카드는 트레이 슬롯으로 복귀.
    func memoCardDragGesture(
        onPullOut: @escaping (_ payload: MemoPayload, _ worldPosition: SIMD3<Float>) -> Void
    ) -> some View {
        self.gesture(
            DragGesture()
                .targetedToEntity(where: .has(MemoCardComponent.self))
                .onChanged { value in
                    let card = value.entity
                    guard let parent = card.parent else { return }
                    card.position = value.convert(value.location3D, from: .local, to: parent)
                }
                .onEnded { value in
                    let card = value.entity
                    guard let component = card.components[MemoCardComponent.self] else { return }
                    let worldPosition = card.position(relativeTo: nil)
                    onPullOut(component.payload, worldPosition)
                    card.position = component.home   // 슬롯으로 복귀
                }
        )
    }
}
