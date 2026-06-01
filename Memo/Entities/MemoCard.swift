import RealityKit
import SwiftUI

/// 트레이/볼륨에 놓일 작은 "메모 카드" 엔티티.
/// 메모 본체(makeNoteEntity)와 달리 ManipulationComponent 대신 커스텀 드래그 제스처 대상이 되도록
/// InputTarget + Collision + MemoCardComponent를 단다.
func makeMemoCard(_ payload: MemoPayload, home: SIMD3<Float>) -> ModelEntity {
    let w: Float = 0.1, h: Float = 0.07, t: Float = 0.005

    let card = ModelEntity(
        mesh: .generateBox(size: [w, h, t], cornerRadius: 0.004),
        materials: [SimpleMaterial(color: payload.uiColor, isMetallic: false)]
    )
    card.name = "memoCard-\(payload.text)"
    card.position = home

    if !payload.text.isEmpty {
        card.components.set(ViewAttachmentComponent(
            rootView: Text(payload.text)
                .font(.caption)
                .foregroundStyle(.black)
                .padding(4)
        ))
    }

    card.components.set(InputTargetComponent())
    card.components.set(CollisionComponent(shapes: [.generateBox(size: [w, h, t])]))
    card.components.set(HoverEffectComponent())
    card.components.set(MemoCardComponent(payload: payload, home: home))

    return card
}

/// 카드들을 격자(3열)로 배치해 root에 추가.
@discardableResult
func makeMemoCardTray(
    _ payloads: [MemoPayload],
    origin: SIMD3<Float>,
    into root: Entity
) -> [ModelEntity] {
    let columns = 3
    let dx: Float = 0.13
    let dy: Float = 0.10

    var cards: [ModelEntity] = []
    for (i, payload) in payloads.enumerated() {
        let col = i % columns
        let row = i / columns
        let home = origin + SIMD3<Float>(Float(col) * dx, -Float(row) * dy, 0)
        let card = makeMemoCard(payload, home: home)
        root.addChild(card)
        cards.append(card)
    }
    return cards
}
