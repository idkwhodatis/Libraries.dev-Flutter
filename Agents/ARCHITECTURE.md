# Architecture

## 1. Repository shape

The Flutter port replaces the current repository root. The web fork remains
available at the `web-baseline` tag and in a temporary worktree used only for
reference captures.

```text
/
  pubspec.yaml                  # Dart pub workspace
  analysis_options.yaml
  .fvmrc                        # Flutter 3.47.x pin
  apps/
    libraries_dev/
      lib/
        app.dart
        router.dart
        theme/
        widgets/
        pages/
        data/
      assets/
      test/
      integration_test/
      android/ ios/ windows/ macos/ linux/
  packages/
    border_beam/
      lib/
    bot_avatars/
      lib/
    img_fx/
      lib/
    liquid_gooey/
      lib/
    magnetic_ui/
      lib/
    metal_fx/
      lib/
    thinking_orbs/
      lib/
        thinking_orbs.dart
        src/
          engine/
          presets.dart
          spec.g.dart
      test/
    voice_glow/
      lib/
    ui_kit/
      lib/
  tool/
    sync_reference_assets.dart
    gen_orb_spec.dart
    capture_web_reference.mjs
  reference/
    PARITY.md
    web-baseline.txt
```

The root `pubspec.yaml` is a Dart pub workspace. `apps/libraries_dev` is the
only application. `packages/thinking_orbs` and `packages/ui_kit` are reusable
packages.

## 2. SDK and platforms

- Flutter 3.47 or newer, Dart 3.12 or newer.
- iOS, Android, Windows, macOS and Linux.
- No Flutter Web target.
- Impeller is the only renderer. Do not add a Skia fallback.
- On Android below API 29, the engine may fall back to the legacy OpenGL
  renderer; that is an engine constraint, not an application option.

CI must build each platform on its native runner. The local Windows machine
can build Windows and Android; iOS, macOS and Linux need CI or the appropriate
host.

## 3. Dependencies

Keep the dependency set small and explicit:

- `go_router` for routing.
- `flutter_riverpod` for app state.
- `shared_preferences` for local auth state, presets and settings.
- `flutter_svg` for the site SVG assets.
- `visibility_detector` for offscreen orb pause.
- `flutter_layout_grid` for the web-equivalent row-span orb example grid.
- `media_kit`, `media_kit_video` and `media_kit_libs_video` for MP4 playback.
- `url_launcher` for external links.
- Built-in Flutter testing, `integration_test` and golden-file support.

Do not add a package that duplicates Flutter rendering, animation, state or
asset primitives without a documented reason.

`media_kit` needs a license and app-size review before distribution. If a
platform fails, keep the `VideoSurface` abstraction and substitute a native
player per platform rather than changing page code.

## 4. Design system

### Source

The web design system is defined by:

- `sites/home/public/assets/site.css`
- `sites/home/public/assets/playground.css`
- `sites/home/public/assets/examples.css`
- `sites/home/public/assets/ui-generation.css`
- page-level HTML and inline CSS at `web-baseline`

These are references. Flutter code does not parse CSS at runtime.

### Tokens

Port these token groups into `ui_kit`:

- dark palette and surface hierarchy
  - page `#121212`
  - card `#181818`
  - stage `#131313`
  - code/playground `#171717`
  - menu `#202020`
- text, muted text, subtle text, accent, Pro ink/tint and semantic colors
- type scale with Inter; Roboto Mono for code
- spacing values: 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 32, 40, 48, 56, 64,
  96, 112, 128
- radii: 6, 8, 12, 14, 16, 18, 24, 30, 36, 40, 48, 50, and 52 for the phone
- motion durations: 40, 80, 150, 250, 350, 400, 500 ms
- easing: the web's `cubic-bezier(0.22, 1, 0.36, 1)` family, plus the bounce
  curves where the reference uses them
- breakpoints: 639, 740, 761, 780, 900, 1100, 1161

### Material and effects

The web identity depends on inset rings and layered shadows. Flutter's
`BoxShadow` cannot express inset shadows, so implement:

- `InsetSurface` using a custom painter or layered clipped containers
- `Hairline` for 1px rings
- top highlight and bottom shade layers
- `ShaderMask` for gradient masks
- `BackdropFilter` inside a `ClipRect` for blurred overlays
- `ColorFilter.matrix` or a fragment shader for hue/saturate/brightness
  approximations

Do not replace these with a plain border and elevation.

### Typography

Use bundled Inter for all roles. The display headings that used Saans use Inter
with adjusted weight, letter spacing and line height. This is an accepted
deviation from the web and must be documented in `PARITY.md`.

Roboto Mono is bundled for code, snippets and mono labels.

## 5. Routing and state

### Routing

Use `go_router`. Every route from `sites/home/vite.config.ts` exists:

- `/`
- `/how-to-use`
- `/skill`
- `/skill-example`
- `/introduction`
- `/accessibility`
- `/beam`
- `/orbs`
- `/bots`
- `/orbs-carousel`
- `/bot-carousel`
- `/gooey`
- `/metal`
- `/image`
- `/magnetic`
- `/voice`
- `/voice-phone`
- `/skill-demo`
- `/pro`
- `/studio`
- `/studio/app`
- `/account`
- `/activate`
- `/success`
- `/terms`
- `/privacy`
- `/404`

V1 makes `/orbs`, `/orbs-carousel` and `/studio/app#orb` parity-complete.
Non-orb routes are navigation-safe stubs with real headers and preview media.

### State

Use Riverpod for:

- session and entitlements
- selected library/platform/tab
- playground and Studio values
- local presets
- dev mode and mock plan state

Theme resolution is a small dedicated provider. The orb clock is not a
Riverpod provider; it is a `ChangeNotifier`/`Listenable` owned by the app shell
so it has exactly one `Ticker`.

## 6. Thinking Orbs engine

### Layers

```text
packages/thinking_orbs/lib/src/
  engine/core.dart       projection, noise, hash, ink, finalize, paint contract
  engine/profiles.dart   base profiles and scaling
  engine/orbits.dart
  engine/lattice.dart    globe, rubik, wave
  engine/web.dart        connecting
  engine/braid.dart
  engine/ribbon.dart     ribbon and ring
  engine/morph.dart
  engine/registry.dart   mode dispatch
  presets.dart           state -> mode and 64/32/20 tunings
  spec.g.dart            generated constants from orbs-spec.json
  thinking_orb.dart      Flutter widget
  orb_clock.dart         shared ticker
  gravity.dart           desktop pointer warp
```

The engine is pure Dart. It must not import Flutter, `dart:ui` or any package
that requires a binding. That keeps golden tests fast and renderer-independent.

### Frame contract

A frame is a list of dots and lines:

- dot: `x`, `y`, `z`, `r`, `white`, `a`
- line: `x1`, `y1`, `x2`, `y2`, `white`, `a`, `w`

`finalizeFrame` culls invisible marks, clamps radius to the mode floor and
sorts far-to-near. The painter draws lines first, then dots, without deriving
geometry.

### Clock and lifecycle

Use one app-level `OrbClock`:

- a single `Ticker`
- starts when at least one visible orb subscribes
- every orb reads `clock.elapsed` and multiplies by its resolved speed
- pausing an orb freezes its last frame; resuming jumps to the current global
  time, matching the web's `performance.now` behavior
- stop the ticker when no orb is visible
- pause on app lifecycle hidden/inactive and when the orb is offscreen

Do not give each orb its own independent wall clock.

### Rendering

`OrbPainter extends CustomPainter`:

- transparent background
- DPR cap 2
- `Canvas.drawLine` for lines, `Canvas.drawCircle` for dots
- cached `Paint` objects for quantized ink/alpha values
- `RepaintBoundary` around each orb
- repaint only when the global clock ticks or the resolved theme/options change
- no text, filters or image sampling in the v1 orb

This is a small vector workload. Measure before optimizing. If profiling shows
pressure, `drawAtlas` with a circle sprite is the first escalation, not a
different renderer.

### Theme

`theme` is explicit `dark` or `light`; `auto` resolves:

1. the app's current theme mode
2. the platform brightness
3. live updates when either changes

Unlike the web, there are no DOM ancestors to inspect. The app shell is the
theme authority. The orb still follows live changes and never reads a stale
brightness.

### Reduced motion

Use the platform's reduced-motion accessibility feature. Draw the static
`t = 0.6` frame and keep theme updates live.

### Semantics

Expose each orb as an image with the per-state label:

- working: Working...
- searching: Searching...
- solving: Solving...
- listening: Listening...
- connecting: Connecting...
- weaving: Weaving...
- composing: Composing...
- breathing: Thinking...
- shaping: Shaping...

Allow a label override. The painted canvas itself is excluded from semantics.

### Gravity

Gravity is a pointer-sprite effect, not an orb-dot deformation. Port the
tracking, reach, tail, bend, taper, curve, falloff, inertia, handover, squash
and blur behavior from `gravity.ts`.

- Desktop: hide the system cursor only on the plain arrow, draw the warped
  platform pointer in an overlay, release it on leave, blur, hide, keydown and
  unsupported cursor states.
- macOS: use the existing arrow raster from `macCursor.ts`.
- Windows and Linux: bundle matching arrow rasters at 1x and 2x.
- Mobile: mirror the web's no-fine-pointer behavior. The playground toggle is
  visible, but the effect reports why it is unavailable.

## 7. Video and media

Use `media_kit` behind a `VideoSurface` widget. Requirements:

- play the existing H.264 MP4 assets
- lazy-create players only for visible tiles
- pause when offscreen, hidden or reduced motion
- show the existing poster and LQIP while loading
- mute by default and never autoplay with sound
- support hover-to-play on desktop and viewport-play on touch
- dispose players when a page leaves the tree

The home page has up to 13 simultaneous videos. Never create all players at
once; use visibility and a small player pool.

## 8. Data and backend mocks

Define repository interfaces before screens:

```dart
abstract class AuthRepository {
  Future<Session?> me();
  Future<void> signOut({bool allDevices = false});
}

abstract class PresetsRepository {
  Future<List<Preset>> list(String library);
  Future<Preset> save(Preset preset);
  Future<void> delete(String id);
}

abstract class StudioAgent {
  Stream<StudioEvent> chat(List<StudioMessage> messages);
}

abstract class CommerceRepository {
  Future<CheckoutResult> checkout(Plan plan);
  Future<PortalResult> portal();
}

abstract class DownloadsRepository {
  Future<DownloadTicket> magnetModel();
}
```

V1 implementations are local:

- auth state in `shared_preferences`, with a dev panel to switch signed-out,
  free, Pro and Business
- presets in `shared_preferences`
- agent returns canned status/text/params events and applies them through the
  same validation path the real agent will use
- commerce displays the pricing UI and a demo checkout modal
- downloads return an unavailable/demo result

Keep DTO names aligned with `pro-client.js` and the Studio client. Do not
invent a different contract that makes the later HTTP implementation a
rewrite.

## 9. Assets

Run `tool/sync_reference_assets.dart` to copy from a `web-baseline` worktree
into `apps/libraries_dev/assets/` and `packages/thinking_orbs/assets/`. The
tool records SHA-256 values and fails if a source file changes without a
manifest update.

Categories:

- fonts: Inter, Roboto Mono
- icons and logos: SVG and PNG
- customer marks: SVG
- avatars and images: JPG/PNG
- posters and LQIP
- videos: MP4
- cursor rasters: PNG
- orbs spec and golden JSON

Do not copy the React source, `node_modules`, `dist`, service worker files or
Cloudflare configuration into the Flutter tree.

## 10. Reference map

| Flutter area | Web reference |
| --- | --- |
| App shell, nav, footer | `sites/home/public/assets/site.css`, `sites/home/index.html` |
| Detail page shell | `sites/home/public/assets/playground.css`, `sites/home/orbs.html` |
| Orb examples/playground | `sites/home/src/orbs.tsx` |
| Orb carousel | `sites/home/src/orbs-carousel.tsx` |
| Studio orb bench | `sites/home/src/studio/orb.tsx` |
| Studio status row | `sites/home/src/studio/controls.tsx` |
| Orb engine | `packages/thinking-orbs/src/engine/` |
| Orb presets | `packages/thinking-orbs/src/presets.ts` |
| Orb behavior | `packages/thinking-orbs/src/ThinkingOrb.tsx`, `theme.ts`, `gravity.ts` |
| Golden data | `packages/thinking-orbs/spec/orbs-golden.json` |
| Tunings | `packages/thinking-orbs/spec/orbs-spec.json` |
| Backend calls | `sites/home/public/assets/pro-client.js`, `site.js`, `src/studio/agent.ts` |
| Studio gate | `sites/home/functions/studio/_middleware.js` |
| Agent contract | `services/studio-agent/handler.ts` |







