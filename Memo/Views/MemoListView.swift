import SwiftUI

/// 더미 메모 목록 윈도우. (세부 구현은 다른 담당자 — 여기선 드래그-스폰 테스트용 최소 구현.)
/// 카드를 윈도우 밖(immersive 공간)으로 드래그하면 메모 엔티티가 스폰된다.
struct MemoListView: View {
    private let dummyMemos: [MemoPayload] = [
        .init(text: "우유 사기", r: 1.0,  g: 0.9,  b: 0.2,  a: 1),
        .init(text: "회의 14시", r: 0.6,  g: 0.85, b: 1.0,  a: 1),
        .init(text: "내일 발표", r: 1.0,  g: 0.6,  b: 0.7,  a: 1),
        .init(text: "운동하기",  r: 0.7,  g: 1.0,  b: 0.7,  a: 1),
        .init(text: "약속 잡기",  r: 1.0,  g: 0.8,  b: 0.5,  a: 1),
        .init(text: "책 읽기",    r: 0.85, g: 0.8,  b: 1.0,  a: 1),
    ]

    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(dummyMemos, id: \.text) { memo in
                    MemoCard(memo: memo)
                        .draggable(memo)   // ← 드래그하면 MemoPayload가 실림
                }
            }
            .padding()
        }
        .navigationTitle("메모 목록 (더미)")
    }
}

private struct MemoCard: View {
    let memo: MemoPayload

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(red: memo.r, green: memo.g, blue: memo.b))
            .frame(height: 90)
            .overlay {
                Text(memo.text)
                    .font(.headline)
                    .foregroundStyle(.black)
            }
            .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 12))
            .hoverEffect()   // 시선 호버 시 하이라이트
    }
}

#Preview {
    MemoListView()
}
