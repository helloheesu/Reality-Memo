import RealityKit
import SwiftUI
import UIKit
import CoreText

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
        // 네이티브 텍스트 메쉬 + 말줄임(.byTruncatingTail). 작은 면이라 길면 끝에 "…" 표시.
        let label = makeLabelEntity(
            payload.text,
            fontSize: 0.009,
            maxWidth: w - 0.014,
            maxHeight: 0.026,                 // 2~3줄로 제한 → 넘치면 말줄임
            frontZ: t / 2 + 0.001,
            lineBreakMode: .byTruncatingTail
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

    // 카드 그리드 (가운데 정렬, 타이틀바 공간 확보 위해 약간 아래로). 유리 패널 앞에 뜸.
    let x0 = -Float(columns - 1) / 2 * dx
    let y0 = Float(rows - 1) / 2 * dy - 0.02
    for (i, payload) in payloads.enumerated() {
        let col = i % columns
        let row = i / columns
        let home = SIMD3<Float>(x0 + Float(col) * dx, y0 - Float(row) * dy, 0.004)
        let card = makeMemoCard(payload, home: home)
        panel.addChild(card)
    }

    // 윈도우 룩 크롬(유리 패널 + 타이틀/close + 하단 그래버) — 카드 "뒤"에 배치해 드래그를 안 가로챔.
    let gridW = Float(columns - 1) * dx + 0.10
    let gridH = Float(rows - 1) * dy + 0.07
    let ptPerMeter: CGFloat = 1360   // 어태치먼트 pt↔m 대략값 (기기서 미세조정)
    let window = Entity()
    window.components.set(ViewAttachmentComponent(
        rootView: MemoBoardWindow(
            widthPt: CGFloat(gridW + 0.12) * ptPerMeter,
            heightPt: CGFloat(gridH + 0.16) * ptPerMeter,
            onClose: { [weak panel] in panel?.removeFromParent() }
        )
    ))
    window.position = SIMD3<Float>(0, 0, -0.006)
    panel.addChild(window)

    return panel
}

/// in-space 메모 보드를 네이티브 윈도우처럼 보이게 하는 SwiftUI 크롬.
/// (시스템 윈도우 바/그래버는 WindowGroup 전용이라 100% 동일하진 않고 유리+그래버 캡슐로 모사.)
struct MemoBoardWindow: View {
    let widthPt: CGFloat
    let heightPt: CGFloat
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("메모 목록").font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 16)

            Spacer(minLength: 0)
        }
        .frame(width: widthPt, height: heightPt)
        .glassBackgroundEffect()
        .overlay(alignment: .bottom) {
            // 네이티브 윈도우 하단 그래버 핸들 모사
            Capsule()
                .fill(.white.opacity(0.55))
                .frame(width: 130, height: 7)
                .offset(y: 24)
        }
    }
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
