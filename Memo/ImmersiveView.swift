//
//  ImmersiveView.swift
//  Memo
//
//  Created by Heesu on 5/31/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    var body: some View {
        RealityView { content in
            let note = makeNoteEntity()
            note.position = SIMD3<Float>(x: 0, y: 1.3, z: -1.5)
            content.add(note)
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
