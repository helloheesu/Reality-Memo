import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var anchorManager = AnchorManager()
    
    var body: some View {
        RealityView { content in
            // 1. ARKit 세션 시작
            await anchorManager.startSession()
            
            
            // 2. 메모 생성 + 고정 버튼 부착 (버튼은 child라 별도 content.add 불필요)
            let note = makeNoteEntity(text: "고정 버튼 메모")
            note.name = "note"
            note.position = SIMD3<Float>(x: 0, y: 1.3, z: -1.0)
            content.add(note)

            note.addPinButton(using: anchorManager)

            print("✅ 메모 추가됨")
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
