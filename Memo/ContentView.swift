//
//  ContentView.swift
//  Memo
//
//  Created by Heesu on 5/31/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Hello, world!")

            ToggleImmersiveSpaceButton()

            Button("메모 목록 열기 (2D 윈도우)") {
                openWindow(id: "MemoList")
            }

            Button("메모 볼륨 열기 (3D 끌어내기)") {
                openWindow(id: "MemoVolume")
            }
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
