# magnetic_ui

Flutter first pass for the Libraries.dev Magnetic UI interaction.

```dart
MagneticSurface(
  strength: 0.22,
  reach: 220,
  child: const Card(child: Text('Magnetic')),
)
```

## API

- `strength`, `reach`, `axis`, `borderRadius`, `onTap`
- `MagnetBridge`: connects to the local `ws://127.0.0.1:47613` bridge and
  exposes `MagnetFrame`, `MagnetGesture` and connection-state streams.

This is a pointer/bridge first pass. The native MagnetKit model, calibration
flow, account-gated model download and Android bridge APK are not bundled.
