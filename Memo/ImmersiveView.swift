import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var anchorManager = AnchorManager()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        RealityView { content in
            // 0. 의존성 주입 + 영속 메모 로드 (세션 시작 전에 로드해야 anchorUpdates 매칭됨)
            anchorManager.modelContext = modelContext
            let root = Entity()
            content.add(root)
            anchorManager.contentRoot = root
            anchorManager.loadPersisted()

            // 1. ARKit 세션 시작 (이후 영속 앵커들이 surface되며 메모가 복원됨)
            await anchorManager.startSession()

            // 2. 테스트용 새 메모 1개 스폰 (미고정). 복원된 메모는 추가로 나타남.
            let note = makeNoteEntity(text: "고정 버튼 메모")
            note.name = "note"
            note.position = SIMD3<Float>(x: 0, y: 1.3, z: -1.0)
            root.addChild(note)

            note.addPinButton(using: anchorManager)

            print("✅ 메모 추가됨")
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
