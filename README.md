# Libraries.dev Flutter

Flutter port of the Libraries.dev fork.

The current vertical slice is dedicated to **Thinking Orbs**: the nine-state
Dart engine, the Flutter widget, the `/orbs` page, the carousel, and the Studio
orb bench. The rest of the site is wired as honest route stubs and will be
ported in later phases.

## Status

- Flutter 3.47.8, Impeller.
- Platforms: iOS, Android, Windows, macOS, Linux. No Flutter Web.
- Backend: local/mock only in this slice.
- The original web fork is preserved on the `web-baseline` tag.

## Run

```bash
flutter pub get
flutter run -d windows
```

Open the orb page directly:

```bash
flutter run -d windows --dart-define=START_ROUTE=/orbs
```

Use the real backend instead of the local mocks:

```bash
flutter run -d windows --dart-define=USE_REAL_API=true
```

`API_BASE_URL` defaults to `https://api.libraries.dev`; override it for a
staging Worker.

Run the tests:

```bash
flutter test packages/thinking_orbs/test
flutter test packages/border_beam/test
flutter test packages/bot_avatars/test
flutter test packages/metal_fx/test
flutter test packages/voice_glow/test
flutter test packages/img_fx/test
flutter test packages/liquid_gooey/test
flutter test packages/magnetic_ui/test
flutter test apps/libraries_dev/test
```

Regenerate the orb tuning file:

```bash
dart run tool/gen_orb_spec.dart
dart run tool/gen_orb_spec.dart --check
```

Compare the checked-in `/orbs` captures (requires Pillow + NumPy):

```bash
python tool/compare_parity.py
```

## Workspace

```text
apps/libraries_dev     Flutter application
packages/thinking_orbs Dart engine and ThinkingOrb widget
packages/border_beam   Border beam widget
packages/bot_avatars   Bot avatar widget
packages/metal_fx      Liquid metal widget
packages/voice_glow    Voice glow widget
packages/img_fx        Image generation widget
packages/liquid_gooey   Gooey widget
packages/magnetic_ui   Magnetic pointer widget
packages/ui_kit        Site theme and UI primitives
tool                   Spec and reference generators
Agents                 Architecture, implementation and parity docs
reference              Ported web reference inputs
```

## Documentation

Start with [`Agents/README.md`](Agents/README.md).








