import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var anchorManager = AnchorManager()
    @State private var spawnRoot = Entity()   // 메모/카드가 붙는 루트
    @Environment(\.modelContext) private var modelContext
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            // 0. 의존성 주입 + 영속 메모 로드 (세션 시작 전에 로드해야 anchorUpdates 매칭됨)
            anchorManager.modelContext = modelContext
            content.add(spawnRoot)
            anchorManager.contentRoot = spawnRoot
            anchorManager.loadPersisted()

            // 1. ARKit 세션 시작 (이후 영속 앵커들이 surface되며 메모가 복원됨)
            await anchorManager.startSession()

            // 2. 테스트용 메모 1개 (미고정)
            let note = makeNoteEntity(text: "고정 버튼 메모")
            note.name = "note"
            note.position = SIMD3<Float>(x: 0, y: 1.3, z: -1.0)
            spawnRoot.addChild(note)
            note.addPinButton(using: anchorManager)

            // 3. Approach T — 공간 내 메모 카드 트레이 (여기서 끌어내면 메모 스폰)
            makeMemoCardTray(MemoPayload.dummies, origin: [-0.13, 1.6, -1.0], into: spawnRoot)

            print("✅ 메모 추가됨")
        }
        // Approach T — 카드를 끌어내면 놓은 위치에 메모 스폰
        .memoCardDragGesture { payload, worldPosition in
            spawnMemo(payload, at: worldPosition)
        }
        // Approach V — 볼륨 윈도우에서 온 스폰 요청 처리 (위치는 후속, 지금은 앞쪽 기본 배치)
        .onChange(of: appModel.pendingSpawns) { _, requests in
            guard !requests.isEmpty else { return }
            for (index, payload) in requests.enumerated() {
                let front = SIMD3<Float>(x: Float(index) * 0.12, y: 1.3, z: -1.0)
                spawnMemo(payload, at: front)
            }
            appModel.pendingSpawns.removeAll()
        }
    }

    /// payload로 메모 엔티티를 만들어 공간에 추가 + 핀 버튼.
    private func spawnMemo(_ payload: MemoPayload, at worldPosition: SIMD3<Float>) {
        let note = makeNoteEntity(text: payload.text, color: payload.uiColor)
        spawnRoot.addChild(note)
        note.setPosition(worldPosition, relativeTo: nil)
        note.addPinButton(using: anchorManager)
        print("🆕 메모 스폰: \(payload.text)")
    }
}
