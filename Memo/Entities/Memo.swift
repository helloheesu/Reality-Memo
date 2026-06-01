import RealityKit
import SwiftUI

// MARK: - Note Entity Factory

func makeNoteEntity(
    text: String = "",
    color: UIColor = .yellow,
    width: Float = 0.15,       // 가로 (좌우)
    height: Float = 0.10,      // 세로 (위아래)
    thickness: Float = 0.005   // 두께 (앞뒤)
) -> ModelEntity {
    let note = ModelEntity(
        mesh: .generateBox(
            size: [width, height, thickness],   // ← 순서 주의: X(가로), Y(세로), Z(두께)
            cornerRadius: 0.005
        ),
        materials: [SimpleMaterial(color: color, isMetallic: false)]
    )

    // configureEntity로 인터랙션 셋업
    ManipulationComponent.configureEntity(
        note,
        allowedInputTypes: .all,
        collisionShapes: [.generateBox(size: [width, height, thickness])]
    )
    
    // 호버 이펙트 추가
    note.components.set(HoverEffectComponent())

    // 놓은 자리에 그대로 있게: releaseBehavior = .stay
    if var manipulation = note.components[ManipulationComponent.self] {
        manipulation.releaseBehavior = .stay
        note.components.set(manipulation)
    }
    
    // 텍스트가 있으면 부착
    if !text.isEmpty {
        note.components.set(ViewAttachmentComponent(
            rootView: NoteTextView(text: text)
        ))
    }

    // 저작 파라미터를 엔티티에 보관 (영속화/복원 단일 출처)
    let (r, g, b, a) = color.rgbaDoubles
    note.components.set(NoteDescriptorComponent(
        text: text,
        red: r, green: g, blue: b, alpha: a,
        width: width, height: height, thickness: thickness
    ))

    return note
}

/// 영속 데이터로부터 메모 엔티티 재생성 (앱 재실행 시 복원용).
func makeNoteEntity(from note: PersistedNote) -> ModelEntity {
    let color = UIColor(
        red: CGFloat(note.r),
        green: CGFloat(note.g),
        blue: CGFloat(note.b),
        alpha: CGFloat(note.a)
    )
    return makeNoteEntity(
        text: note.text,
        color: color,
        width: Float(note.width),
        height: Float(note.height),
        thickness: Float(note.thickness)
    )
}

private extension UIColor {
    /// RGBA 성분을 Double(0...1)로 추출.
    var rgbaDoubles: (Double, Double, Double, Double) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
    }
}

// 메모 안에 들어갈 텍스트 뷰 (별도 struct로 빼서 깔끔하게)
private struct NoteTextView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.body)
            .foregroundStyle(.black)
            .padding(8)
            .frame(maxWidth: 130, maxHeight: 80)  // 메모 크기 안에 맞추기
    }
}

// MARK: - Previews

#Preview("기본") {
    RealityView { content in
        let note = makeNoteEntity()
        content.add(note)
    }
}

#Preview("두께 비교") {
    RealityView { content in
        for (index, thickness) in [Float(0.001), 0.005, 0.01].enumerated() {
            let note = makeNoteEntity(thickness: thickness)
            note.position = SIMD3<Float>(x: Float(index - 1) * 0.2, y: 0, z: 0)
            content.add(note)
        }
    }
}

#Preview("색깔 비교") {
    RealityView { content in
        let colors: [UIColor] = [.yellow, .systemPink, .cyan]
        for (index, color) in colors.enumerated() {
            let note = makeNoteEntity(color: color)
            note.position = SIMD3<Float>(x: Float(index - 1) * 0.2, y: 0, z: 0)
            content.add(note)
        }
    }
}

#Preview("텍스트 메모 - RealityView attachments", immersionStyle: .mixed) {
    RealityView { content, attachments in
        let note = makeNoteEntity()
        note.position = SIMD3<Float>(x: 0, y: 1.5, z: -1.0)
        content.add(note)
        
        // attachments에서 "noteText"라는 ID로 정의한 뷰를 꺼내서 메모에 부착
        if let textEntity = attachments.entity(for: "noteText") {
            // 메모 표면에 살짝 떨어뜨려 배치 (Z축으로 살짝 앞)
            textEntity.position = SIMD3<Float>(x: 0, y: 0, z: 0.003)
            note.addChild(textEntity)
        }
    } attachments: {
        // 부착할 SwiftUI 뷰들을 정의
        Attachment(id: "noteText") {
            Text("$3499")
                .font(.body)
                .foregroundStyle(.black)
                .padding()
        }
    }
}

#Preview("여러 메모 + 텍스트 - RealityView attachments", immersionStyle: .mixed) {
    RealityView { content, attachments in
        let texts = ["우유 사기", "회의 14시", "내일 발표"]
        
        for (i, text) in texts.enumerated() {
            let note = makeNoteEntity(
                color: .yellow
            )
            note.position = SIMD3<Float>(
                x: Float(i - 1) * 0.2,
                y: 1.5,
                z: -1.0
            )
            content.add(note)
            
            // 각 메모마다 다른 텍스트 부착
            if let textEntity = attachments.entity(for: "text-\(i)") {
                textEntity.position = SIMD3<Float>(x: 0, y: 0, z: 0.003)
                note.addChild(textEntity)
            }
        }
    } attachments: {
        ForEach(0..<3, id: \.self) { i in
            Attachment(id: "text-\(i)") {
                // ⚠️ 텍스트 배열을 두 번 써야함. 데이터 모델(Note 구조체) 정의 필요.
                Text(["우유 사기", "회의 14시", "내일 발표"][i])
                    .font(.body)
                    .foregroundStyle(.black)
                    .padding(8)
            }
        }
    }
}

#Preview("텍스트 메모 - ViewAttachmentComponent", immersionStyle: .mixed) {
    RealityView { content in
        let note = makeNoteEntity(text: "오늘 할 일")
        note.position = SIMD3<Float>(x: 0, y: 1.5, z: -1.0)
        content.add(note)
    }
}

#Preview("여러 메모 - ViewAttachmentComponent", immersionStyle: .mixed) {
    RealityView { content in
        let texts = ["우유 사기", "회의 14시", "내일 발표"]
        for (i, text) in texts.enumerated() {
            let note = makeNoteEntity(
                text: text
            )
            note.position = SIMD3<Float>(
                x: Float(i - 1) * 0.2,
                y: 1.5,
                z: -1.0
            )
            content.add(note)
        }
    }
}
