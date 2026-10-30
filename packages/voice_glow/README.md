# voice_glow

Flutter port of the Libraries.dev Voice Glow effect.

```dart
VoiceBeam(
  level: 0.55,
  colorVariant: VoiceBeamColorVariant.colorful,
  child: const ChatInput(),
)
```

## API

- `type`: `defaultBeam`, `pill`, `mobile`
- `level`: 0..1 voice level; use an audio analyser to drive it
- `colorVariant`: `colorful`, `mono`, `ocean`, `sunset`, `mint`
- `theme`, `active`, `paused`, `borderRadius`, `sensitivity`

This is a painter-based first pass. Audio capture, the SVG turbulence
distortion, dots/lines surface looks and the full band-shape prop family are
not ported yet.
