# Libraries.dev Flutter Port

Working documentation for replacing this fork with a Flutter application.

Status: implementation in progress. The repository root is now a Flutter
workspace on `flutter-port`; the web fork is preserved on the `web-baseline`
tag. See [STATUS.md](STATUS.md) for the current slice, delivered items and
remaining gaps.

## Locked decisions

| Area | Decision |
| --- | --- |
| Repository | Replace the repository root with the Flutter workspace. The final tree is Flutter-only. |
| Baseline | Preserve the current web fork on the `web-baseline` tag. Use a temporary git worktree for reference captures. |
| Overall scope | Full fork: all seven libraries and the site. |
| V1 scope | Exact replication of Thinking Orbs and every orb-related surface, with real shells for everything else. |
| Platforms | iOS, Android, Windows, macOS, Linux. No Flutter Web. |
| Renderer | Impeller only. Pin Flutter 3.47 or newer; 3.44.4 is not sufficient for desktop Impeller defaults. |
| Typography | Inter for all text, including display headings. Saans is accepted as dropped. |
| Gravity | Desktop parity on macOS, Windows and Linux. Mobile mirrors the web "no fine pointer" behavior. |
| Video | `media_kit` from the start, with lazy loading and poster/LQIP fallback. |
| Backend | Local/mock first. Keep the real API contract behind repository interfaces. |
| Parity | Geometry, content and timing are exact for orbs. Pages allow font and rasterizer tolerances. |

## Documents

- [AGENTS.md](AGENTS.md) - working agreement, agent workstreams, handoff rules.
- [ARCHITECTURE.md](ARCHITECTURE.md) - repository layout, stack, rendering,
  design system, data and asset architecture.
- [IMPLEMENTATION.md](IMPLEMENTATION.md) - phased implementation plan and
  checklists.
- [PARITY.md](PARITY.md) - exact acceptance criteria, golden vectors, Impeller
  capture strategy, known deviations.
- [STATUS.md](STATUS.md) - current delivery state and remaining gaps.

## Baseline and evidence

- Web fork baseline commit: `d923333`.
- REA static analysis of the site:
  `ev_1690547e8db28301f4f846fcc6910124f9d33c8d9f5d451bca8725d462a30ccf`
  (parent `ev_a05d72bcb8d80f6020f62548522384a63ea82ffeb573a967fbc94bcea0dd53c9`).
- REA static analysis of `thinking-orbs`:
  `ev_6d5e3a7dbb925751a7a98cbcbd5d25e1d7edf3607e7334969b25e09fde10edbc`
  (parent `ev_706de683514dd5866677e0f25eb391cebfb9ddffff08c8b7ba36d1fe5448a67c`).
- REA coverage is static and partial. Inline HTML scripts were not analyzed,
  and no runtime behavior was observed.

## Reference inputs to keep

Copy these before removing the web tree:

- `packages/thinking-orbs/spec/orbs-spec.json`
- `packages/thinking-orbs/spec/orbs-golden.json`
- `packages/thinking-orbs/PORT_PLAN.md`
- `packages/thinking-orbs/ports/ios/ThinkingOrbsKit/README.md`
- `packages/thinking-orbs/ports/react-native/thinking-orbs-native/README.md`
- `sites/home/public/assets/fonts`
- `sites/home/public/assets/icons`
- `sites/home/public/assets/images`
- `sites/home/public/assets/customers`
- `sites/home/public/assets/videos`
- `sites/home/src/examples/macCursor.ts`
- `sites/home/public/assets/site.css`
- `sites/home/public/assets/playground.css`
- `sites/home/public/assets/examples.css`
- `sites/home/public/assets/ui-generation.css`

The CSS files are design references, not runtime styles.

## First commands after the Flutter scaffold exists

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

Platform builds and Impeller capture commands will be added in
[IMPLEMENTATION.md](IMPLEMENTATION.md).
