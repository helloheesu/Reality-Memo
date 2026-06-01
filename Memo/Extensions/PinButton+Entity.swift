import RealityKit
import SwiftUI

/// SwiftUI 버튼 표시용 상태 미러. 진짜 출처는 엔티티의 `WorldAnchorComponent`.
@Observable
class PinButtonState {
    var isPinned: Bool = false
}

extension Entity {
    /// 이 Entity에 기본 모양의 "고정" 토글 버튼을 자식으로 붙인다.
    /// 위치/회전 추종은 부모-자식 관계로, 항상 정면 응시는 BillboardComponent로 공짜로 해결.
    @discardableResult
    func addPinButton(
        offset: SIMD3<Float> = SIMD3<Float>(x: 0.12, y: 0.06, z: 0),
        using anchorManager: AnchorManager
    ) -> Entity {
        addPinButton(offset: offset, using: anchorManager) { isPinned in
            DefaultPinButtonLabel(isPinned: isPinned)
        }
    }

    /// 생김새만 주입하는 버전. 동작(고정/해제)·추종·빌보드는 동일하고 라벨 모양만 교체.
    /// 메모/박스 등 엔티티 종류마다 다른 모양을 줄 수 있다.
    @discardableResult
    func addPinButton<Label: View>(
        offset: SIMD3<Float> = SIMD3<Float>(x: 0.12, y: 0.06, z: 0),
        using anchorManager: AnchorManager,
        @ViewBuilder label: @escaping (_ isPinned: Bool) -> Label
    ) -> Entity {
        let target = self

        let button = Entity()
        button.name = "pinButton-\(self.name)"

        // UI 상태 미러를 컴포넌트의 현재 고정 상태로 초기화
        let state = PinButtonState()
        state.isPinned = self.components[WorldAnchorComponent.self]?.isPinned ?? false

        // 생김새(SwiftUI) 부착 — 탭하면 매니저의 단일 동작 호출
        button.components.set(ViewAttachmentComponent(
            rootView: PinButtonView(state: state, label: label) {
                Task {
                    let pinned = await anchorManager.togglePin(for: target)
                    state.isPinned = pinned   // 토글 결과를 UI에 반영
                }
            }
        ))

        // 항상 사용자를 향하도록
        button.components.set(BillboardComponent())

        // 자식으로 붙이면 위치·회전 자동 추종 (System 불필요)
        button.position = offset
        self.addChild(button)

        return button
    }
}

// MARK: - SwiftUI Views

/// 주입된 라벨을 감싸는 버튼. 동작/상태는 바깥에서 주입.
struct PinButtonView<Label: View>: View {
    @Bindable var state: PinButtonState
    @ViewBuilder let label: (Bool) -> Label
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            label(state.isPinned)
        }
        .buttonStyle(.borderedProminent)
        .tint(state.isPinned ? .red : .blue)
    }
}

/// 기본 고정 버튼 라벨.
struct DefaultPinButtonLabel: View {
    let isPinned: Bool

    var body: some View {
        SwiftUI.Label(
            isPinned ? "고정 해제" : "고정",
            systemImage: isPinned ? "pin.slash.fill" : "pin.fill"
        )
        .padding(8)
    }
}
