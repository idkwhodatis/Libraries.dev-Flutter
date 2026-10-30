# thinking_orbs

Flutter port of the Libraries.dev Thinking Orbs engine and widget.

```dart
ThinkingOrb(
  state: OrbState.searching,
  size: 64,
  theme: OrbTheme.auto,
)
```

## API

- `state`: `working`, `searching`, `solving`, `listening`, `connecting`,
  `weaving`, `composing`, `breathing`, `shaping`
- `size`: 64, 32 or 20; 64 and 20 are the tuned presets, 32 is interpolated
- `theme`: `auto`, `dark` or `light`
- `speed`, `paused`, `color`, `dots`, `dotSize`, `opts`
- `displaySize`: draw a tuned size into an arbitrary layout size
- `semanticLabel`: override the per-state accessibility label

Use `OrbGravityField` around a stage to opt into the desktop pointer effect.

When the device pixel ratio is above 2, the painter rasterizes through a 2x
`Picture` and draws that image, capping the effective orb resolution. Other
DPRs paint directly.

## Verification

```bash
flutter test packages/thinking_orbs/test
flutter test apps/libraries_dev/integration_test/orb_matrix_test.dart -d windows
flutter test apps/libraries_dev/integration_test/orb_capture_test.dart -d windows
flutter test apps/libraries_dev/integration_test/orb_dpr_cap_test.dart -d windows
```

The golden test reads `spec/orbs-golden.json` and compares all 72 cases at
`1e-4`. The capture test writes the 144-case Impeller matrix to
`reference/captures/orbs/`.

