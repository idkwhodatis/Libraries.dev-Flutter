# liquid_gooey

Flutter port of the Libraries.dev Liquid Gooey effect.

```dart
Liquid(
  fill: const Color(0xFF9FE8A8),
  child: const Center(child: Text('Gooey')),
)
```

## API

- `fill`, `background`, `blur`, `contrast`, `borderRadius`
- `paused`, `effect`, `blobs`
- `LiquidItem` for a pill-shaped gooey surface

The first pass merges animated circles with blur + alpha contrast while keeping
the content crisp. The web library's SVG filter graph, image melt, spring
engine and DOM-mirroring items are still to be ported.
