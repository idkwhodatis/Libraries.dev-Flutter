# Agent Working Agreement

Read [README.md](README.md), [ARCHITECTURE.md](ARCHITECTURE.md),
[IMPLEMENTATION.md](IMPLEMENTATION.md) and [PARITY.md](PARITY.md) before
changing code. This file defines how work is divided and what must not drift.

## Global rules

- The final application is Flutter-only. Do not add a Flutter Web target.
- Render with Impeller. Do not add a Skia fallback or a `--no-enable-impeller`
  path.
- Pin Flutter 3.47 or newer.
- V1 is the Thinking Orbs slice. Do not implement the other effects beyond
  navigation-safe stubs.
- `orbs-spec.json` and `orbs-golden.json` are immutable inputs. Regenerate
  generated Dart only through `tool/gen_orb_spec.dart`; never hand-edit the
  generated file.
- Do not replace Inter with Saans or another display font.
- Do not call `api.libraries.dev`, Stripe, GoatCounter, npm or GitHub APIs in
  v1. Use the local mock repositories.
- Do not commit secrets, API keys, model files or downloaded fonts without a
  license review.
- Do not modify `web-baseline`. It is the reference source for screenshots and
  assets.

## Source of truth

1. Golden geometry: `orbs-golden.json`.
2. Tunings: `orbs-spec.json`.
3. Behavior and API: the `thinking-orbs` source at `web-baseline`, especially
   `src/ThinkingOrb.tsx`, `src/theme.ts`, `src/presets.ts` and `src/engine/`.
4. Visual specification: the four shared CSS files and the page HTML at
   `web-baseline`.
5. Existing native ports: Swift and React Native READMEs and tests.

When source and a document disagree, stop and record the conflict in the pull
request or handoff. Do not silently choose one.

## Workstreams

### 1. Core Engine Agent

Scope:

- `packages/thinking_orbs/lib/src/engine/`
- `packages/thinking_orbs/lib/src/presets.dart`
- `packages/thinking_orbs/lib/src/spec.g.dart` (generated)
- `packages/thinking_orbs/test/`
- `tool/gen_orb_spec.dart`

Deliverables:

- Pure-Dart port of all nine frame functions.
- Exact `resolvePreset` behavior for 64, 32 and 20.
- `scaleCounts`, `scaleRadii`, `finalizeFrame`, ink ramp and z-order.
- Golden-vector tests at `1e-4` tolerance.
- Order-independent multiset check for `breathing@64`.

Do not:

- Import Flutter in the engine package.
- Change golden values to make a test pass.
- Use approximations for `hashD`, `vnoise`, `fibDir` or the projection.

### 2. Design System Agent

Scope:

- `packages/ui_kit/`
- `apps/libraries_dev/lib/theme/`
- `apps/libraries_dev/lib/widgets/`
- ported assets and fonts

Deliverables:

- Dark-first tokens derived from `site.css`.
- Inset-ring surfaces, hairlines, top highlights and bottom shades.
- Pill tabs, buttons, code blocks, copy buttons, tooltips, dropdowns,
  command palette, nav, mobile menu and footer.
- Backdrop blur, gradient masks and scroll fades.
- Inter and Roboto Mono bundled as local assets.
- Responsive behavior at the web breakpoints: 639, 740, 761, 780, 900, 1100,
  1161.

Do not:

- Use Material defaults that visibly diverge from the reference.
- Replace the inset material with a plain `Border`.
- Add Saans.

### 3. Orbs Surface Agent

Scope:

- `apps/libraries_dev/lib/pages/orbs/`
- `apps/libraries_dev/lib/pages/orbs_carousel/`
- `apps/libraries_dev/lib/pages/studio/orb/`
- orb sections in home, how-to-use, skill and studio pages

Deliverables:

- `/orbs` page parity, including examples, playground, install/usage and
  prompt.
- `/orbs-carousel` timing and layout.
- Studio orb bench with local presets and mock agent.
- Orb appearances on all related pages.

Do not:

- Change labels, example order, locked states, sizes or snippet text.
- Implement the other library benches.

### 4. Rendering and Platform Agent

Scope:

- `ThinkingOrb` widget and painter
- `OrbClock`
- gravity overlay
- `media_kit` integration
- Android, iOS, Windows, macOS and Linux runners
- CI platform matrix

Deliverables:

- Shared clock with web-equivalent phase behavior.
- Offscreen and lifecycle pause.
- Reduced-motion static frame.
- DPR cap 2.
- Desktop gravity with platform pointer rasters.
- Impeller verification on all five platforms.
- Video surface abstraction and lazy playback.

Do not:

- Use a per-orb wall clock that drifts between instances.
- Draw on a timer that continues while hidden or offscreen.
- Enable Impeller per-platform overrides that hide a failure.

### 5. Parity and QA Agent

Scope:

- `apps/libraries_dev/integration_test/`
- `apps/libraries_dev/test/`
- `tool/capture_web_reference.mjs`
- `Agents/PARITY.md` updates

Deliverables:

- 144-case Impeller render matrix.
- Page captures at 1440x900, 1280x800, 768x1024 and 390x844.
- Geometry, centroid, ink-mass and downsample checks.
- Motion, theme, reduced-motion and visibility tests.
- Performance profiles with four or more simultaneous orbs.
- A written deviations report for every accepted difference.

Do not:

- Treat `flutter test` software-Skia goldens as Impeller evidence.
- Loosen a threshold before recording the first baseline and the reason.
- Hide a regression in an aggregate average.

### 6. Data and Mocks Agent

Scope:

- `apps/libraries_dev/lib/data/`
- local repositories and fixtures
- dev panel

Deliverables:

- `AuthRepository`, `PresetsRepository`, `StudioAgent`,
  `CommerceRepository`, `DownloadsRepository`.
- Signed-out, free, Pro and Business dev states.
- Local preset persistence and canned agent patches.
- DTOs and method names aligned with the client callers at `web-baseline`.
- No network calls.

Do not:

- Add checkout, auth or model-download network code in v1.
- Make a mock look like a completed production integration.
- Store credentials or real user data.

## Branch and commit rules

- Do not commit or push unless explicitly asked.
- Keep the `web-baseline` tag untouched.
- Make one logical change per commit.
- Stage only files in scope.
- Include the tests run in the commit or handoff.

## Quality gates

Before handing off:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

For platform work, also run the relevant build or integration test:

```bash
flutter build windows
flutter build linux
flutter build macos
flutter build apk
flutter build ios --no-codesign
```

Do not claim a platform passes if it was not built or run on that platform.
Windows cannot produce iOS or macOS builds; use CI.

## Handoff format

Return a short report:

1. What changed and why.
2. Files and packages touched.
3. Tests and builds run, with results.
4. Parity or performance numbers.
5. Known gaps and unresolved questions.
6. Whether `web-baseline` or any generated file changed.
