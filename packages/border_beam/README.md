# border_beam

Flutter port of the Libraries.dev Border Beam effect.

```dart
BorderBeam(
  size: BorderBeamSize.md,
  colorVariant: BorderBeamColorVariant.colorful,
  child: const Card(child: Text('Your content here')),
)
```

## API

- `size`: `sm`, `md`, `line`, `pulseInner`, `pulseOutside`
- `colorVariant`: `colorful`, `mono`, `ocean`, `sunset`
- `theme`: `auto`, `dark`, `light`
- `duration`, `active`, `borderRadius`, `brightness`, `saturation`,
  `hueRange`, `staticColors`, `strength`
- `onActivate`, `onDeactivate`

The current implementation is a painter-based first pass. The exact
`beam-spec.json` palette and oscillator data is retained under `spec/` for the
shader-parity phase; the painting currently uses tuned Flutter gradients.
