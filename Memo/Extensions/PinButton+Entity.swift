import RealityKit
import SwiftUI

extension Entity {
    /// 이 Entity의 옆에 "고정" 버튼을 부착
    func addPinButton(
        offset: SIMD3<Float> = SIMD3<Float>(x: 0.1, y: 0.07, z: 0),
        onTap: @escaping () -> Void
    ) {
        // 자식 Entity 생성
        let buttonEntity = Entity()
        buttonEntity.name = "pinButton"
        buttonEntity.position = offset
        
        // SwiftUI 뷰 부착
        buttonEntity.components.set(ViewAttachmentComponent(
            rootView: PinButtonView(onTap: onTap)
        ))
        
        // 컴포넌트 부착 (메타데이터로 표시)
        buttonEntity.components.set(PinButtonComponent(onTap: onTap))
        
        addChild(buttonEntity)
    }
}

// SwiftUI 뷰는 같은 파일에
private struct PinButtonView: View {
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            Label("고정", systemImage: "pin.fill")
                .padding(8)
        }
        .buttonStyle(.borderedProminent)
    }
}
