import RealityKit
import SwiftUI
import UIKit

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
        // 네이티브 텍스트 메쉬로 부착 — 입력을 안 가로채 카드 드래그가 안정적이고 깊이 정렬도 정상.
        let label = makeLabelEntity(
            payload.text,
            fontSize: 0.009,
            maxWidth: w - 0.014,
            maxHeight: h - 0.01,
            frontZ: t / 2 + 0.001
        )
        card.addChild(label)
    }

    card.components.set(InputTargetComponent())
    card.components.set(CollisionComponent(shapes: [.generateBox(size: [w, h, t])]))
    card.components.set(HoverEffectComponent())
    card.components.set(MemoCardComponent(payload: payload, home: home))

    return card
}

/// "윈도우 같은" 메모 목록 보드. 평평한 배경판 + 카드 그리드(3열, 가운데 정렬)를 한 엔티티로.
/// immersive 공간에 그대로 놓고, 카드를 드래그하면 메모를 스폰한다(전부 같은 좌표공간).
func makeMemoListPanel(_ payloads: [MemoPayload]) -> Entity {
    let columns = 3
    let dx: Float = 0.135
    let dy: Float = 0.10
    let rows = (payloads.count + columns - 1) / columns

    let panel = Entity()

    // 배경판 (반투명 화이트)
    let boardW = Float(columns) * dx + 0.04
    let boardH = Float(rows) * dy + 0.04
    let board = ModelEntity(
        mesh: .generateBox(size: [boardW, boardH, 0.004], cornerRadius: 0.012),
        materials: [SimpleMaterial(color: UIColor.white.withAlphaComponent(0.22), isMetallic: false)]
    )
    panel.addChild(board)

    // 카드 그리드 (가운데 정렬, 배경판 앞면에)
    let x0 = -Float(columns - 1) / 2 * dx
    let y0 = Float(rows - 1) / 2 * dy
    for (i, payload) in payloads.enumerated() {
        let col = i % columns
        let row = i / columns
        let home = SIMD3<Float>(x0 + Float(col) * dx, y0 - Float(row) * dy, 0.004)
        let card = makeMemoCard(payload, home: home)
        panel.addChild(card)
    }
    return panel
}

/// 드래그 중 손끝을 따라다니는 미리보기 엔티티 (반투명 메모). 드래그 끝나면 제거되고 진짜 메모가 생성됨.
func makeMemoPreview(_ payload: MemoPayload) -> ModelEntity {
    let w: Float = 0.20, h: Float = 0.14, t: Float = 0.006
    let preview = ModelEntity(
        mesh: .generateBox(size: [w, h, t], cornerRadius: 0.005),
        materials: [SimpleMaterial(color: payload.uiColor.withAlphaComponent(0.75), isMetallic: false)]
    )
    let label = makeLabelEntity(
        payload.text,
        fontSize: 0.014,
        maxWidth: w - 0.03,
        maxHeight: h - 0.02,
        frontZ: t / 2 + 0.001
    )
    preview.addChild(label)
    return preview
}
