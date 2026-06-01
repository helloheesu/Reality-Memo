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
