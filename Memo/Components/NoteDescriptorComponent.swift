import RealityKit

/// 메모 엔티티의 저작 파라미터를 엔티티에 보관하는 ECS 데이터.
/// 영속화(`PersistedNote` 생성)와 복원(메모 재생성) 양쪽의 단일 출처.
/// 색은 직렬화 가능하도록 RGBA(0...1)로 저장.
struct NoteDescriptorComponent: Component {
    var text: String
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    var width: Float
    var height: Float
    var thickness: Float
    var tilt: Float
}
