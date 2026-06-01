import SwiftUI
import RealityKit
import SwiftData

@main
struct MemoApp: App {

    @State private var appModel = AppModel()

    init() {
        WorldAnchorComponent.registerComponent()
        NoteDescriptorComponent.registerComponent()
    }

    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .modelContainer(for: PersistedNote.self)

        // 메모 목록 윈도우 (더미). 카드를 공간으로 드래그하면 메모 스폰.
        WindowGroup(id: "MemoList") {
            MemoListView()
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        .modelContainer(for: PersistedNote.self)
    }
}
