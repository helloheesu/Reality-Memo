import SwiftUI
import RealityKit

/// Approach V — 볼륨 윈도우에 3D 메모 카드를 띄우고, 끌어내면 immersive 공간에 스폰 요청.
/// 한계: 볼륨은 경계에서 콘텐츠를 클립하므로 "매끄러운 끌어내기"는 안 되고,
/// 카드를 놓는 순간 공간으로 핸드오프(요청)된다. (정확한 위치 변환은 후속.)
struct MemoVolumeView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            let root = Entity()
            content.add(root)
            // 볼륨 중앙 근처에 트레이 배치
            makeMemoCardTray(MemoPayload.dummies, origin: [-0.13, 0.05, 0], into: root)
        }
        .memoCardDragGesture { payload, _ in
            // 볼륨 좌표 → immersive 좌표 변환은 후속. 지금은 요청만 전달(기본 위치 스폰).
            appModel.requestSpawn(payload)
        }
    }
}
