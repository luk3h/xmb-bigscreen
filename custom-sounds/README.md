# Your own sounds

Put your own sound files in this folder and they're used instead of the built-in ones. Name each file after what it's for:

| File name | Plays when |
|---|---|
| `move` | Moving between categories or items |
| `select` | Choosing something |
| `back` | Going back, choosing No |
| `error` | Something can't be chosen |
| `open` | The home screen appearing |

For example `move.wav`, `select.mp3`, `error.flac`. You don't need all five: any you leave out keep the built-in sound.

**Formats:** `.wav` works as it is. `.mp3`, `.flac`, `.ogg`, `.m4a` and `.opus` are converted automatically if `ffmpeg` is installed (Fedora: `sudo dnf install ffmpeg-free`).

`scripts/preview.sh` picks them up straight away and says `Using your sounds: ...` when it does.

**Tips**

- Short sounds feel best: under half a second for `move`, `select` and `back`.
- Only use sounds you have the right to use. This project doesn't include or link to anyone else's.

Sound files in this folder are ignored by git, so they're never uploaded.
