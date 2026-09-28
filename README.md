# Yazan Awawda — Portfolio

Single-page static site: `index.html` (all CSS/JS inline) + `assets/`.

## Assets

The page expects:

| File | Used for |
| --- | --- |
| `assets/yazan.jpg` | Hero portrait (square, 480×480) |
| `assets/tulkarm-app.webm` / `.mp4` | Tulkarm app recording in the phone mockup |
| `assets/tulkarm-app-poster.jpg` | Frame shown before the video loads |

Generate all of them from the originals with:

```sh
scripts/prepare-assets.sh path/to/photo.jpg path/to/screen-recording.mp4
```

It uses `ffmpeg` (or `pip install imageio-ffmpeg` if ffmpeg isn't installed).
