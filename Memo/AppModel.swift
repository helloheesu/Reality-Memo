//
//  AppModel.swift
//  Memo
//
//  Created by Heesu on 5/31/26.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed

    /// 볼륨 윈도우(Approach V)에서 카드를 끌어냈을 때, immersive 공간에 스폰할 메모 요청 큐.
    /// ImmersiveView가 관찰해서 처리 후 비운다. (볼륨↔공간은 별도 씬이라 직접 엔티티 이동 대신 요청 전달.)
    var pendingSpawns: [MemoPayload] = []

    func requestSpawn(_ payload: MemoPayload) {
        pendingSpawns.append(payload)
    }
}
