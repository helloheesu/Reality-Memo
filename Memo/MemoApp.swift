import SwiftUI
import RealityKit
import SwiftData

@main
struct MemoApp: App {

    @State private var appModel = AppModel()

    init() {
        WorldAnchorComponent.registerComponent()
        NoteDescriptorComponent.registerComponent()
        MemoCardComponent.registerComponent()
    }

    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .modelContainer(for: PersistedNote.self)

        // 메모 목록 윈도우 (더미, 2D). 윈도우→공간 드래그는 visionOS 한계로 동작 X — 비교용 참고.
        WindowGroup(id: "MemoList") {
            MemoListView()
        }

        // Approach V — 볼륨 윈도우 (3D 카드). 끌어내면 immersive 공간에 스폰 요청.
        WindowGroup(id: "MemoVolume") {
            MemoVolumeView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.5, height: 0.4, depth: 0.3, in: .meters)

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
