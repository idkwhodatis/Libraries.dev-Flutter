# Reference inputs

This directory holds immutable inputs copied from the `web-baseline` tag before
the Flutter root replacement.

- `css/` - the shared site stylesheets used as visual reference. They are not
  loaded at runtime.
- `ports/` - the existing Thinking Orbs Swift and React Native port notes and
  the original port plan.
- `macCursor.ts` - the macOS pointer sprite source for the desktop gravity
  effect.
- `web-baseline.txt` - the tag and commit the inputs came from.

The golden and tuning JSON files live next to the engine in
`packages/thinking_orbs/spec/`.

To run the web reference for captures, use a temporary worktree of
`web-baseline`; do not copy the React application into the Flutter tree.
