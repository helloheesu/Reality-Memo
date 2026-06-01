import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var anchorManager = AnchorManager()
    @State private var spawnRoot = Entity()   // 메모들이 붙는 루트 (복원·스폰 공용)
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

            // 2. 테스트용 새 메모 1개 스폰 (미고정). 복원된 메모는 추가로 나타남.
            let note = makeNoteEntity(text: "고정 버튼 메모")
            note.name = "note"
            note.position = SIMD3<Float>(x: 0, y: 1.3, z: -1.0)
            spawnRoot.addChild(note)

            note.addPinButton(using: anchorManager)

            print("✅ 메모 추가됨")
        }
        // 메모 목록 윈도우에서 드래그해온 메모를 공간에 스폰
        .dropDestination(for: MemoPayload.self) { payloads, _ in
            for (index, payload) in payloads.enumerated() {
                spawnMemo(payload, index: index)
            }
            return !payloads.isEmpty
        }
    }

    /// 드롭된 payload로 메모 엔티티 생성 후 공간에 추가.
    /// (더미 단계: 드롭 위치는 무시하고 사용자 앞쪽에 약간씩 어긋나게 배치.)
    private func spawnMemo(_ payload: MemoPayload, index: Int) {
        let color = UIColor(
            red: CGFloat(payload.r),
            green: CGFloat(payload.g),
            blue: CGFloat(payload.b),
            alpha: CGFloat(payload.a)
        )
        let note = makeNoteEntity(text: payload.text, color: color)
        let jitter = Float(index) * 0.06
        note.position = SIMD3<Float>(x: jitter, y: 1.3, z: -1.0)
        spawnRoot.addChild(note)
        note.addPinButton(using: anchorManager)
        print("🆕 메모 스폰: \(payload.text)")
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
