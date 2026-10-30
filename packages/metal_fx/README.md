# metal_fx

Flutter port of the Libraries.dev Liquid Metal effect.

```dart
MetalFx(
  preset: MetalFxPreset.silver,
  child: const Text('Get started'),
)
```

## API

- `preset`: `silver`, `gold`, `chromatic`
- `variant`: `button`, `circle`
- `theme`: `auto`, `dark`, `light`
- `strength`, `paused`, `borderRadius`
- `MetalText`, `MetalBadge`

`MetalFx` and `MetalText` use an Impeller fragment shader
(`shaders/metal.frag`) on devices and fall back to a painter in tests. The web
library's Paper liquid-metal reflection paint and full material tuning are not
fully ported yet; MetalFx now adds a pointer-following light on desktop.


