import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var anchorManager = AnchorManager()
    @State private var spawnRoot = Entity()                  // 메모/보드가 붙는 루트
    @State private var dragPreviews: [Entity.ID: Entity] = [:]  // 드래그 중 카드별 미리보기
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        RealityView { content in
            // 0. 의존성 주입 + 영속 메모 로드 (세션 시작 전에 로드해야 anchorUpdates 매칭됨)
            anchorManager.modelContext = modelContext
            content.add(spawnRoot)
            anchorManager.contentRoot = spawnRoot
            anchorManager.loadPersisted()

            // 1. ARKit 세션 시작 (이후 영속 앵커들이 surface되며 메모가 복원됨)
            await anchorManager.startSession()

            // 2. "윈도우 같은" 메모 목록 보드를 공간에 배치
            let panel = makeMemoListPanel(MemoPayload.dummies)
            panel.position = SIMD3<Float>(0, 1.5, -0.9)
            spawnRoot.addChild(panel)

            print("✅ ImmersiveView 준비됨")
        }
        .gesture(dragSpawnGesture)
    }

    /// 보드의 카드를 드래그 → 미리보기가 따라옴 → 놓으면 그 위치에 진짜 메모 스폰.
    private var dragSpawnGesture: some Gesture {
        DragGesture()
            .targetedToEntity(where: .has(MemoCardComponent.self))
            .onChanged { value in
                let card = value.entity
                guard let component = card.components[MemoCardComponent.self] else { return }
                let pos = value.convert(value.location3D, from: .local, to: spawnRoot)

                if let preview = dragPreviews[card.id] {
                    preview.setPosition(pos, relativeTo: spawnRoot)
                } else {
                    let preview = makeMemoPreview(component.payload)
                    preview.setPosition(pos, relativeTo: spawnRoot)
                    spawnRoot.addChild(preview)
                    dragPreviews[card.id] = preview
                }
            }
            .onEnded { value in
                let card = value.entity
                guard let component = card.components[MemoCardComponent.self] else { return }

                let preview = dragPreviews.removeValue(forKey: card.id)
                let dropPosition = preview?.position(relativeTo: nil) ?? card.position(relativeTo: nil)
                preview?.removeFromParent()

                spawnMemo(component.payload, at: dropPosition)
            }
    }

    /// payload로 진짜 메모 엔티티를 만들어 그 위치에 추가 + 핀 버튼.
    private func spawnMemo(_ payload: MemoPayload, at worldPosition: SIMD3<Float>) {
        let note = makeNoteEntity(text: payload.text, color: payload.uiColor)
        spawnRoot.addChild(note)
        note.setPosition(worldPosition, relativeTo: nil)
        note.addPinButton(using: anchorManager)
        print("🆕 메모 스폰: \(payload.text)")
    }
}
