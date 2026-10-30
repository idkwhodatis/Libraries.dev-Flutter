# bot_avatars

Flutter port of the Libraries.dev Bot Avatars effect.

```dart
BotAvatar(
  type: BotAvatarType.clover,
  state: BotAvatarState.working,
  size: 64,
)
```

## API

- `type`: 18 body shapes (`clover`, `flower`, `triangle`, `square`, `blob`,
  `ghost`, `circle`, `drop`, `star`, `droid`, `mech`, `alien`, `hexagon`,
  `cat`, `cloud`, `pill`, `pebble`, `puddle`)
- `state`: `idle`, `working`, `sleeping`
- `face`: `eyes`, `mouth`
- `size`, `color`, `ink`, `speed`, `paused`, `seed`, `theme`,
  `semanticLabel`

This is a vector first pass. The web library's baked plastic/fabric material,
wearables and full prop surface are not ported yet.
