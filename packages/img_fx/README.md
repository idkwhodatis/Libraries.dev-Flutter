# img_fx

Flutter port of the Libraries.dev Image Generation effect.

```dart
ImageGeneration(
  images: const ['assets/images/gen-1.jpg'],
  preset: ImageGenerationPreset.organic,
)
```

## API

- `images`: asset paths to cycle through
- `preset`: `organic`, `mechanic`, `sweep`
- `strength`, `speed`, `borderRadius`
- `paused`, `autoReveal`, `onCycle`

The first pass samples the image into a 28x34 color grid and dissolves the
mosaic over the full image. The original three.js shader, 26 effect branches and
the full reveal pipeline are still to be ported.
