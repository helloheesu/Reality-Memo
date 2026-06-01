# Reality-Memo — visionOS 구현에서 배운 점

> 메모를 공간에 두고 World Anchor로 고정하는 visionOS 앱.
> "메모 목록에서 드래그 → 공간에 메모 엔티티 스폰" 기능을 만들며 부딪힌 플랫폼 제약과 해법 정리.
> (실측으로 확정한 것 / 공식 문서 / 경험적 추론을 구분해 표기)

---

## TL;DR

- **윈도우/볼륨에서 공간으로 "끌어내기"는 안 된다.** 전부 **하나의 immersive RealityView(한 좌표공간)** 안에서 처리해야 안정적이다.
- **입력 시스템이 둘**이다: SwiftUI 드래그-드롭(`.draggable`/`.dropDestination`)과 RealityKit 공간 제스처(`DragGesture().targetedToEntity`). **둘은 별개**이고 서로의 개념(InputTargetComponent 등)이 적용되지 않는다.
- "윈도우"는 공간 안의 **엔티티 + SwiftUI 어태치먼트**로 그린다. 드롭 위치도 같은 좌표라 정확하다.

---

## 1. 플랫폼 제약 (실측으로 확정)

1. **윈도우 → immersive 공간 드래그-드롭 불가.**
   passthrough(빈 공간)엔 SwiftUI 드롭 타겟이 없어, 윈도우에서 시작한 `.draggable`이 공간으로 넘어오면 드롭이 안 잡히고 취소된다.
   → `.dropDestination`의 `isTargeted`가 **한 번도 true가 안 뜸**으로 확정. (`.draggable`/`.dropDestination` 무용)

2. **볼륨 윈도우는 경계에서 콘텐츠를 클립**(GPU clipping)하고 바깥은 비인터랙티브.
   → 카드를 볼륨 밖으로 "끌어내기" 불가. 볼륨↔공간 엔티티 이동은 좌표 변환이 필요. (공식 문서화된 제약 — `preferredWindowClippingMargins`는 best-effort + 비인터랙티브)

3. **결론:** 메모 목록 "윈도우"도 immersive 공간 안의 엔티티/어태치먼트로 그린다. 같은 좌표공간이라 **드롭 위치가 정확**하고 cross-scene 문제가 없다.

---

## 2. 입력: 두 시스템을 절대 혼동하지 말 것 ⭐

이번에 가장 크게 헷갈렸던 부분. **드래그(잡기)** 와 **드롭→스폰(생성)** 은 별개이고, 2D와 3D는 입력 경로 자체가 다르다.

| | 2D 윈도우 | 3D / 공간 보드 |
|---|---|---|
| 입력 방식 | **SwiftUI** `.draggable` + `.dropDestination` | **RealityKit** `DragGesture().targetedToEntity(where:)` |
| `InputTargetComponent`/`CollisionComponent`/`allowsHitTesting` | **적용 안 됨** | 적용됨 |
| 드롭→스폰 | **안 됨 (cross-scene 한계)** | 됨 (`onEnded`에서 직접 엔티티 생성) |

- **2D 드롭이 안 생기는 문제는 RealityKit 컴포넌트로 못 고친다.** 다른 입력 시스템이라 작동 영역이 아님. (cross-scene SwiftUI 한계)
- RealityKit 공간 제스처가 동작하려면 대상 엔티티에 **`InputTargetComponent` + `CollisionComponent`** 필요(충돌 셰이프 = hit-test 영역). — *공식 문서/WWDC*

---

## 3. 어태치먼트 vs 텍스트 메쉬, 그리고 hit-test 가로채기

- **네이티브 텍스트 메쉬(`MeshResource.generateText`)**: 깊이 정렬이 본체와 함께 정상 처리됨(겹친 메모 텍스트가 앞으로 안 샘) + 입력 안 가로챔 + `lineBreakMode: .byTruncatingTail`로 말줄임("…") 가능. **단 스크롤/리치 레이아웃 없음.**
- **SwiftUI 어태치먼트(`ViewAttachmentComponent`)**: 진짜 SwiftUI를 시스템이 **래스터화**해 공간에 띄움(버튼·스크롤·`.glassBackgroundEffect()` OK). 단 면 앞에 두면 깊이/입력 이슈.

### hit-test 가로채기 — 정확한 표현 (경험적 추론 + 회피책)
- **관찰(경험적):** 카드에 `InputTargetComponent`+`CollisionComponent`가 **이미 있었는데도** 드래그가 flaky했다. 텍스트 어태치먼트를 카드 면 *앞*에 자식으로 둔 동안 그랬고, **네이티브 메쉬로 바꾸자 정상화**됨.
- **유력한 메커니즘:** hit-test는 **가장 앞 엔티티**로 해소되는데, 앞에 뜬 어태치먼트(hit-test 가능 표면)가 먼저 잡혀 `targetedToEntity(where: .has(MemoCardComponent))`가 카드로 시작 안 됨. (앞/뒤가 갈림 — 유리 패널을 카드 *뒤*에 두면 드래그 유지됨이 방증)
- ⚠️ **"어태치먼트가 드래그를 가로챈다"는 Apple 공식 서술이 아니다.** 위는 정황 기반 추론. (찾아본 WWDC25/포럼엔 어태치먼트-엔티티 입력 우선순위 명시 없음)
- **회피책 (공식 동작):** 비인터랙티브 어태치먼트엔 **`.allowsHitTesting(false)`** → 입력이 통과해 뒤 엔티티(카드 충돌면)로 내려감. SwiftUI 텍스트를 쓰면서 드래그를 살리고 싶을 때 사용. (단 공간에서 한 번 검증 권장)

### 기타
- **박스에 텍스트**는 **앞면으로 살짝 띄운 자식 엔티티**로 안 두면 면 안에 박혀 안 보인다(z = thickness/2 + ε).
- **하이브리드 원칙:** chrome/버튼은 SwiftUI 어태치먼트, **드래그 대상은 엔티티**. 어태치먼트는 드래그 대상의 *뒤*에 두거나 `.allowsHitTesting(false)`.
- 어태치먼트 컨트롤 초기 무반응 레이스 가능성 → `make` 클로저 끝에 `Task.sleep(~100ms)` 워크어라운드(대부분 수정됨, 알아둘 것).

---

## 4. ViewAttachmentComponent 재래스터/크기 이슈 — "고정" 버튼 사례 ⭐

핀 버튼(`borderedProminent`)에 로딩 스피너를 넣었더니 **버튼이 순간적으로 잘려 보이는**(둥근 모서리 radius가 사라지고 직선만 보이는) 현상.

- **원인:** `ViewAttachmentComponent`는 SwiftUI 뷰를 텍스처로 래스터화해 3D 쿼드에 입힌다. SwiftUI **콘텐츠 크기가 바뀌면** 텍스처/쿼드 갱신이 **한 프레임 늦어**, 둥근 배경이 새 크기로 다 그려지기 전 프레임이 노출 → 모서리 잘림.
- **왜 정적 라벨끼리는 괜찮고 스피너에서만?**
  - "고정 ↔ 고정 해제" 라벨 토글: 크기 변화가 **작고 1회성**이라 1프레임 만에 안정 → 안 보임.
  - `ProgressView`(무한 회전): **매 프레임 다시 그려져** 어태치먼트가 계속 재래스터되고, **라벨(큰 폭)→스피너(작은 폭)로 크게 수축**까지 겹쳐 어긋남이 **지속적·크게** 노출.
- **해법:**
  - 크기를 **고정**한다(`.frame(width:)`), 또는
  - 스피너로 **교체하지 말고** 라벨을 `.opacity(0)`로 두고 스피너를 `.overlay`(footprint 유지 → 크기 불변), 또는
  - 크기가 변하는 애니메이션 콘텐츠를 어태치먼트에 넣지 않는다.
- **교훈:** 어태치먼트는 "크기 불변"이 가장 안전. 크기가 자주/연속으로 바뀌는 SwiftUI(스피너, 가변 텍스트 토글)는 래스터 랙을 유발한다.

---

## 5. "네이티브 윈도우처럼" — 가능/불가능

- **시스템 윈도우 바·하단 그래버·창 컨트롤은 `WindowGroup` 전용.** 공간 안 엔티티 보드엔 그 시스템 크롬을 그대로 못 붙인다.
- **모사는 가능:** `.glassBackgroundEffect()` 유리 패널 + 그래버 캡슐 + 타이틀/close 버튼을 SwiftUI 어태치먼트로. 100% 동일하진 않음.
- 어태치먼트(pt) ↔ RealityKit(m) 크기 정합은 **대략 pt/m 환산값(≈1360)으로 추정 후 기기서 미세조정** 필요.
- **근본 트레이드오프:** 진짜 네이티브 윈도우 크롬을 원하면 `WindowGroup`을 써야 하고, 그러면 "공간으로 끌어내기"가 불가능(cross-scene). 끌어내기를 살리려면 공간 보드 + 모사로 간다.

---

## 6. 구현 패턴

- **드래그 프리뷰로 끌어내기:** `onChanged`에서 프리뷰 엔티티 생성/이동(`value.convert(value.location3D, from: .local, to: <space>)`), `onEnded`에서 진짜 엔티티 스폰 + 프리뷰 제거. 같은 좌표공간이라 **놓은 위치 그대로** 생성.
- **SwiftData 영속:** anchor id ↔ 데이터 매핑 저장, `worldTracking.anchorUpdates`로 재실행 시 복원(`.added`에서 엔티티 재생성). 모델 필드 제거는 스키마 변경 → 개발 중엔 앱 재설치로 스토어 리셋.
- **World Anchor 동작:** ARKit는 비동기·push(스트림), RealityKit System은 동기·매 프레임 pull → 세션 소유 + async add/remove + 스트림 소비는 **Manager(오래 사는 @Observable)**가, 상태(anchorID 등)는 **Component(ECS 데이터)**가. (Apple ObjectPlacement 샘플 구조)
- **사용자 회전은 `tilt`가 아니라 월드 앵커 transform이 보존.** 고정 시 `entity.transformMatrix(relativeTo: nil)`로 현재 회전을 앵커에 담고 복원 시 되살림.
- **`Scene` 모호성:** `import SwiftUI` + `import RealityKit` 동시 시 `some Scene`이 모호 → `some SwiftUI.Scene`로 한정.

---

## 출처

- [Transforming RealityKit entities using gestures — Apple Docs](https://developer.apple.com/documentation/realitykit/transforming-realitykit-entities-with-gestures)
- [allowsHitTesting(_:) — Apple Docs](https://developer.apple.com/documentation/swiftui/view/allowshittesting(_:))
- [Better together: SwiftUI and RealityKit — WWDC25](https://developer.apple.com/videos/play/wwdc2025/274/)
- [Dive deep into volumes and immersive spaces — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10153/)
- [Content inside volume gets clipped — Apple Forums](https://developer.apple.com/forums/thread/760018)
- [SwiftUI Gestures with RealityKit Entities — Step Into Vision](https://stepinto.vision/example-code/swiftui-gestures-with-realitykit-entities/)
- [Transforming entities between RealityKit coordinate spaces — Apple Docs](https://developer.apple.com/documentation/realitykit/transforming-entities-between-realitykit-coordinate-spaces)
