# Implementation Plan

This is the ordered build plan. Workstreams are defined in
[AGENTS.md](AGENTS.md); technical details are in
[ARCHITECTURE.md](ARCHITECTURE.md); acceptance criteria are in
[PARITY.md](PARITY.md). See [STATUS.md](STATUS.md) for what is already
delivered; checkboxes here remain the full target, not a claim of completion.

## Phase 0 - Baseline, SDK and migration

### 0.1 Preserve the web fork

- [ ] Confirm the working tree is clean.
- [ ] Tag the current commit `web-baseline`.
- [ ] Create a `flutter-port` branch.
- [ ] Add a temporary worktree for `web-baseline` outside the final tree.
- [ ] Record the baseline commit and tag in `reference/web-baseline.txt`.
- [ ] Copy the reference inputs listed in [README.md](README.md).
- [ ] Remove the old web tree from the `flutter-port` branch only after the
      copies and tag are verified.

The final main tree contains no `sites/`, `packages/` from the npm workspace,
`services/`, `cli/`, `skills/`, root `package.json`, `Package.swift`,
Cloudflare config or Vite config.

### 0.2 SDK

- [ ] Pin Flutter 3.47.x with `.fvmrc` or the team's chosen SDK pin.
- [ ] Confirm `flutter doctor` for Windows and Android.
- [ ] Confirm CI can provide macOS, Linux and iOS runners.
- [ ] Scaffold Android, iOS, Windows, macOS and Linux runners.
- [ ] Verify Impeller is active on every platform that can be run locally.
- [ ] Document any platform that cannot be verified locally.

### 0.3 Early risk spikes

- [ ] Impeller fragment-shader spike on all five platforms.
- [ ] Verify `media_kit` plays an H.264 MP4 on Windows, Linux, macOS, Android
      and iOS with Impeller.
- [ ] Verify `visibility_detector` behavior inside the actual page scroll
      views.
- [ ] Verify `flutter_svg` renders the site's SVGs under Impeller.
- [ ] Verify `SystemMouseCursors.none` plus a custom overlay on all three
      desktop platforms.
- [ ] Record results before committing to the full UI.

If a spike fails, solve it in the spike. Do not hide it behind a fallback that
exists only to make the build pass.

**Exit:** baseline preserved, Flutter workspace at the repository root, all
five runners present, Impeller and media spikes pass.

---

## Phase 1 - Workspace and design system

### 1.1 Workspace

- [ ] Create the root pub workspace.
- [ ] Create `apps/libraries_dev`, `packages/thinking_orbs` and
      `packages/ui_kit`.
- [ ] Add `analysis_options.yaml`, formatting rules and CI.
- [ ] Add asset manifests and the sync tool.
- [ ] Add the reference parity docs.

### 1.2 Tokens

- [ ] Port the dark palette and surface hierarchy.
- [ ] Port text roles and Inter/Roboto Mono families.
- [ ] Port spacing, radii and motion tokens.
- [ ] Port breakpoints.
- [ ] Add a `SiteTheme` and `ThemeExtension` surface for tokens.
- [ ] Add tests that assert the key token values.

### 1.3 Primitives

- [ ] `InsetSurface` and `Hairline`.
- [ ] `PillTab`, `PillButton`, `IconButton`.
- [ ] `CodeBlock`, `CopyButton`, `Tooltip`.
- [ ] `BackdropOverlay`, `GradientMask`, `ScrollFade`.
- [ ] `SiteNav`, desktop menu, three-dot menu, mobile menu.
- [ ] Command palette with keyboard shortcuts.
- [ ] Footer.
- [ ] `ProRimButton` and its motion.
- [ ] Responsive layout helpers.

### 1.4 Assets and fonts

- [ ] Bundle Inter and Roboto Mono.
- [ ] Sync icons, logos, customer marks, images and posters.
- [ ] Add video assets only after the media spike passes.
- [ ] Add the cursor rasters.
- [ ] Add license and provenance notes for every asset group.
- [ ] Do not bundle Saans.

**Exit:** the shell renders at 1440x900, 1280x800, 768x1024 and 390x844; the
nav, menus, command palette, footer and core primitives are usable; assets load
offline.

---

## Phase 2 - Thinking Orbs engine

### 2.1 Spec generation

- [ ] Add `tool/gen_orb_spec.dart`.
- [ ] Generate `packages/thinking_orbs/lib/src/spec.g.dart` from
      `orbs-spec.json`.
- [ ] Add a CI check that regenerating produces no diff.
- [ ] Record `specVersion` and the source library version in the package.

### 2.2 Core math

- [ ] Port `lerp`, `frac`, `vnoise`, `hashD`, `fibDir`, `angleDelta`.
- [ ] Port `makeProj`.
- [ ] Port `radiusScale`, `scaleCounts`, `scaleRadii`.
- [ ] Port `finalizeFrame` and the draw contract.
- [ ] Port the ink ramp and tint behavior.
- [ ] Port `paint`/`paintLines` semantics into a renderer-independent frame
      output. The Dart engine must not depend on `dart:ui`.

### 2.3 Modes

- [ ] `orbits` - working.
- [ ] `globe` - searching.
- [ ] `rubik` - solving.
- [ ] `wave` - listening.
- [ ] `web` - connecting.
- [ ] `braid` - weaving.
- [ ] `ribbon` - composing.
- [ ] `ring` - breathing.
- [ ] `morph` - shaping.
- [ ] `registry` with exact mode dispatch.
- [ ] `presets` for 64, 32 and 20.

### 2.4 Golden tests

- [ ] Parse `orbs-golden.json`.
- [ ] Compare every dot and line at `1e-4`.
- [ ] Compare as an order-independent multiset for `breathing@64`.
- [ ] Add a test that catches a mistyped constant or sign error with the exact
      case and field.
- [ ] Add the "same dots, far to near" draw-order assertion.
- [ ] Run the full 72-case matrix.

**Exit:** all golden vectors pass; resolved presets match the spec; the engine
runs without Flutter.

---

## Phase 3 - ThinkingOrb widget

### 3.1 Clock and lifecycle

- [ ] Implement `OrbClock` with one `Ticker`.
- [ ] Start only when a visible orb subscribes.
- [ ] Stop when no orb is visible.
- [ ] Pause on app lifecycle hidden/inactive.
- [ ] Pause offscreen with `visibility_detector`.
- [ ] Resume at the current global time, matching the web.
- [ ] Test phase alignment across multiple orbs.

### 3.2 Painter

- [ ] `OrbPainter` with lines then dots.
- [x] DPR cap 2.
- [ ] Cached paints for quantized ink/alpha.
- [ ] `RepaintBoundary` per orb.
- [ ] No repaint when nothing changed.
- [ ] Static frame under reduced motion.
- [ ] Live theme changes.
- [ ] `displaySize` for arbitrary layout sizes without changing tuned geometry.

### 3.3 API and behavior

- [ ] `state`, `size`, `theme`, `speed`, `paused`, `color`, `dots`,
      `dotSize`, `opts`, `gravity`, `displaySize`, `semanticLabel`.
- [ ] Default state, size, theme and speed match the web.
- [ ] `opts` overrides merge last.
- [ ] `dots`/`dotSize` use the same paired scaling.
- [ ] Semantics labels and override.
- [ ] Exclude the painted canvas from semantics.

### 3.4 Gravity

- [ ] Port the tracking and warp math.
- [ ] macOS sprite.
- [ ] Windows sprite.
- [ ] Linux sprite.
- [ ] Hide and restore the system cursor safely.
- [ ] Release on leave, blur, hide, keydown and unsupported states.
- [ ] Mobile reports why gravity is unavailable.
- [ ] Test with reduced motion, zoom/scale changes and non-arrow cursors.

**Exit:** the package renders all nine states at 64/20/32; all lifecycle and
theme behaviors pass; gravity works on all three desktops; no golden
regression.

---

## Phase 4 - Orb surfaces

### 4.1 `/orbs`

- [ ] Rebuild the page shell from `sites/home/orbs.html`.
- [ ] Docs sidebar and previous/next navigation.
- [ ] Header icon, title and subtitle.
- [ ] Preview/Install tabs.
- [ ] React/SwiftUI/React Native platform tabs.
- [ ] Two hero pills: `solving`, `composing`.
- [ ] Seven-state grid with exact labels and large-chip rules.
- [ ] Locked Weaving/Shaping controls.
- [ ] Playground state, size and gravity controls.
- [ ] Play/Pause behavior; starts paused.
- [ ] Studio teaser rows in the exact order.
- [ ] Live snippet generation.
- [ ] Install and usage blocks.
- [ ] Copy buttons with the same feedback.
- [ ] Agent prompt text.
- [ ] Footer.

### 4.2 `/orbs-carousel`

- [ ] Oblique stack layout.
- [ ] Eight pills in two slides.
- [ ] 7s auto-advance.
- [ ] 1100ms transition, 3px blur, 70ms stagger.
- [ ] Reduced-motion behavior.
- [ ] Debug panel only in debug builds.

### 4.3 `/studio/app#orb`

- [ ] Studio shell and library rail.
- [ ] Orb bench visible by default when `#orb`.
- [ ] Nine states.
- [ ] 64/32/20 sizes.
- [ ] Speed, ink, dots and dot size.
- [ ] Shape control for `shaping`.
- [ ] Per-state engine knobs.
- [ ] Gravity controls and desktop availability note.
- [ ] Local presets.
- [ ] Mock agent.
- [ ] Install/Usage tabs and snippets.
- [ ] Theme toggle.
- [ ] No other library bench implemented in v1; show locked/stub states.

### 4.4 Orb appearances

- [ ] Home hero orb tile.
- [ ] Home orb library card.
- [ ] `ThinkingStatus` in how-to-use and studio marketing.
- [ ] Skill page orbs.
- [ ] Skill demo and skill example orbs.
- [ ] Voice/phone mocks only where they use orb status, not the other effects.

### 4.5 Routes and stubs

- [ ] Register all 26 routes.
- [ ] Real headers and preview media for non-orb pages.
- [ ] Clear "port pending" state, not a fake playground.
- [ ] No dead links.
- [ ] External links use the platform browser.

**Exit:** the complete orb slice works offline on all five platforms; all
orb-related content and interactions are present; the rest of the site is
navigable and honestly marked pending.

---

## Phase 5 - Video, mocks and Studio data

### 5.1 Video

- [ ] Add the `VideoSurface` abstraction.
- [ ] Implement `media_kit`.
- [ ] Lazy-create players only for visible tiles.
- [ ] Poster/LQIP while loading.
- [ ] Hover-to-play on desktop; viewport-play on touch.
- [ ] Pause offscreen and under reduced motion.
- [ ] Dispose players on route exit.
- [ ] Verify memory and frame time with 13 video tiles.

### 5.2 Local repositories

- [ ] `AuthRepository` with signed-out, free, Pro and Business dev states.
- [ ] `PresetsRepository` with local persistence.
- [ ] `StudioAgent` with a canned event stream.
- [ ] `CommerceRepository` with demo checkout UI.
- [ ] `DownloadsRepository` with a placeholder result.
- [ ] DTOs aligned with the client callers at `web-baseline`.
- [ ] Dev panel to switch state and reset local data.

### 5.3 No network

- [ ] No calls to `api.libraries.dev`.
- [ ] No Stripe.
- [ ] No GoatCounter.
- [ ] No npm or GitHub counters.
- [ ] Local fixtures preserve the layout where live data was used.
- [ ] Any placeholder is visibly marked in debug builds, not in the public UI
      unless required by the mock flow.

**Exit:** all v1 flows work without network access; future HTTP integration can
replace repository implementations without screen changes.

---

## Phase 6 - Impeller parity and CI

### 6.1 Geometry

- [ ] Golden vectors in CI.
- [ ] Spec regeneration check.
- [ ] Draw-order/multiset check.

### 6.2 Impeller captures

- [ ] 9 states x 2 sizes x 2 themes x 4 timestamps = 144 orb captures.
- [ ] Capture on each available Impeller platform.
- [ ] Compare against web baseline captures.
- [ ] Record centroid, ink mass and downsample metrics.
- [ ] Calibrate per-platform thresholds after the first baseline.
- [ ] Do not use `flutter test` software-Skia goldens as Impeller evidence.

### 6.3 Page captures

- [ ] 1440x900.
- [ ] 1280x800.
- [ ] 768x1024.
- [ ] 390x844.
- [ ] `/orbs`, `/orbs-carousel`, home orb areas and Studio orb bench.
- [ ] Masked regions for Inter and video frames.
- [ ] Written deviations report.

### 6.4 Behavior and performance

- [ ] Shared-clock phase alignment.
- [ ] Reduced motion.
- [ ] Hidden/offscreen pause.
- [ ] Live theme switch.
- [ ] Four or more orbs at 60fps.
- [ ] Frame budget: under 2ms on mid-range mobile, under 1ms on desktop.
- [ ] Memory check with multiple orbs and video tiles.
- [ ] Semantics and keyboard traversal.

### 6.5 CI matrix

- [ ] Windows runner: analyze, test, build Windows.
- [ ] Linux runner: analyze, test, build Linux.
- [ ] macOS runner: build macOS, build iOS without signing.
- [ ] Android runner: build APK, run emulator integration test.
- [ ] Impeller screenshot jobs where runners support them.
- [ ] Artifact retention for parity captures.

**Exit:** v1 release candidate passes all gates and the parity report is
accepted.

---

## Phase 7 - Full fork after v1

Order by reuse and risk:

1. **border-beam** - port `beam-spec.json` and the Swift Metal/RN SkSL
   references. Verify the line and pulse families first.
2. **bot-avatars** - port the Canvas 2D rig and the plastic/fabric material.
   Use the Swift line-port and RN material references.
3. **metal-fx** - port the liquid-metal material to an Impeller fragment
   shader; rebuild the shared renderer/crop model.
4. **img-fx** - port the GLSL effect branches and the reveal pipeline.
5. **liquid-gooey** - implement the merged silhouette, goo filter and melt
   layers with custom shaders.
6. **voice-glow** - port audio analysis, band drawing, distortion and bloom.
7. **Remaining pages** - beam, bots, gooey, voice, metal, image, magnetic, pro,
   account, activate, success, legal, 404 and internal demos.
8. **Real backend** - OTP auth, session bridge, entitlements, Stripe redirects,
   team management, presets, feedback, Studio agent SSE and protected model
   download.
9. **Magnetic/native bridge and release** - Android Magnet Bridge, model
   license gate, store packaging, desktop signing and notarization.

Each phase starts with a risk spike, then an engine/package port, then the UI
surface, then parity. Do not start a new effect before the previous one has a
golden or pixel gate.

## Definition of done for v1

- [ ] Flutter-only repository at the root.
- [ ] `web-baseline` tag intact.
- [ ] All five platforms build.
- [ ] Impeller is the renderer on every platform.
- [ ] All 9 orb states at 64/20/32.
- [ ] Golden vectors pass at `1e-4`.
- [ ] 144 Impeller orb captures accepted.
- [ ] `/orbs`, `/orbs-carousel` and the orb Studio bench are parity-complete.
- [ ] Orb appearances on home, how-to-use, skill and studio are live.
- [ ] All 26 routes navigate; non-orb pages are honest stubs.
- [ ] Local mocks cover auth, presets, agent, commerce and downloads.
- [ ] No network required.
- [ ] Inter everywhere; no Saans.
- [ ] Gravity works on macOS, Windows and Linux; mobile explains availability.
- [ ] `PARITY.md` lists every accepted deviation.
- [ ] `flutter analyze` and `flutter test` pass.
- [ ] CI builds and tests the platform matrix.

