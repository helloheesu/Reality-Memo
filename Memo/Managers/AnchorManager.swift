import ARKit
import RealityKit
import Observation

/// ARKit 월드 트래킹 세션을 소유하고, 엔티티를 월드 앵커에 고정/해제하는 서비스.
/// - 상태(고정 여부/anchorID)는 엔티티의 `WorldAnchorComponent`(ECS 데이터)에 보관.
/// - 세션 소유 + 비동기 add/remove + `anchorUpdates` 스트림 소비는 RealityKit System으로
///   표현할 수 없으므로(동기·매 프레임 모델) 오래 사는 이 매니저가 담당.
@MainActor
@Observable
final class AnchorManager {
    private let session = ARKitSession()
    private let worldTracking = WorldTrackingProvider()

    var isSessionRunning = false

    /// 앵커 id ↔ 고정된 엔티티 매핑. anchorUpdates가 이 엔티티들의 transform을 갱신.
    private var anchoredEntities: [UUID: Entity] = [:]

    /// 고정 시 떼어둔 ManipulationComponent를 보관했다가 해제 시 복원.
    private var savedManipulation: [Entity.ID: ManipulationComponent] = [:]

    // MARK: - Session

    /// ARKit 세션 시작 후 앵커 업데이트 소비 루프를 띄운다.
    func startSession() async {
        guard !isSessionRunning else { return }

        do {
            try await session.run([worldTracking])
            isSessionRunning = true
            print("✅ ARKit session started")

            // 세션이 실제로 돌기 시작한 뒤에 앵커 스트림 소비 시작 (순서 보장)
            Task { await self.processAnchorUpdates() }
        } catch {
            print("❌ Failed to start ARKit session: \(error)")
        }
    }

    /// 월드 앵커 업데이트를 받아 고정된 엔티티의 transform을 물리 공간에 맞춘다.
    /// 재정렬/재로컬라이즈가 일어나도 이 루프가 앵커 위치를 다시 적용 → 메모가 안 따라옴.
    private func processAnchorUpdates() async {
        for await update in worldTracking.anchorUpdates {
            let anchor = update.anchor
            switch update.event {
            case .added, .updated:
                guard let entity = anchoredEntities[anchor.id] else { continue }
                entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
            case .removed:
                anchoredEntities[anchor.id] = nil
            }
        }
    }

    // MARK: - Pin / Unpin

    /// 엔티티의 현재 고정 상태를 토글한다. 반환값은 토글 후의 고정 여부.
    @discardableResult
    func togglePin(for entity: Entity) async -> Bool {
        var component = entity.components[WorldAnchorComponent.self] ?? WorldAnchorComponent()

        if let anchorID = component.anchorID {
            // === 고정 해제 ===
            do {
                try await worldTracking.removeAnchor(forID: anchorID)
            } catch {
                print("❌ removeAnchor 실패: \(error)")
            }
            anchoredEntities[anchorID] = nil
            component.anchorID = nil
            entity.components.set(component)
            restoreManipulation(on: entity)
            print("📌 고정 해제: \(entity.name)")
            return false
        } else {
            // === 고정 ===
            let transform = entity.transformMatrix(relativeTo: nil)
            let anchor = WorldAnchor(originFromAnchorTransform: transform)
            do {
                try await worldTracking.addAnchor(anchor)
            } catch {
                print("❌ addAnchor 실패: \(error)")
                return false
            }
            anchoredEntities[anchor.id] = entity
            component.anchorID = anchor.id
            entity.components.set(component)
            lockManipulation(on: entity)
            print("✅ Anchor added: \(anchor.id) (\(entity.name))")
            return true
        }
    }

    // MARK: - Drag lock

    /// 고정 중에는 드래그로 안 움직이도록 ManipulationComponent를 떼어내 보관.
    private func lockManipulation(on entity: Entity) {
        if let manipulation = entity.components[ManipulationComponent.self] {
            savedManipulation[entity.id] = manipulation
            entity.components.remove(ManipulationComponent.self)
        }
    }

    /// 보관해둔 ManipulationComponent를 복원해 다시 드래그 가능하게.
    private func restoreManipulation(on entity: Entity) {
        if let manipulation = savedManipulation.removeValue(forKey: entity.id) {
            entity.components.set(manipulation)
        }
    }
}
