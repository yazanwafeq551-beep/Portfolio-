#!/usr/bin/env bash
# Compress the app recording and/or resize the portrait into assets/.
# Usage: scripts/prepare-assets.sh [photo.jpg|png|heic|webp] [screen-recording.mp4|mov]
# Either file may be given alone; images are treated as the photo, anything else as the video.
set -euo pipefail

[ $# -ge 1 ] || { echo "usage: $0 [photo] [screen-recording]" >&2; exit 1; }
out="$(cd "$(dirname "$0")/.." && pwd)/assets"
mkdir -p "$out"

ffmpeg=$(command -v ffmpeg || python3 -c 'import imageio_ffmpeg as f; print(f.get_ffmpeg_exe())')

for f in "$@"; do
  case "${f,,}" in
    *.jpg|*.jpeg|*.png|*.heic|*.webp)
      # Portrait: centre-crop to a square, 480x480 (2x the largest on-screen size).
      "$ffmpeg" -y -loglevel error -i "$f" \
        -vf "crop='min(iw,ih)':'min(iw,ih)',scale=480:480:flags=lanczos" \
        -q:v 3 "$out/yazan.jpg"
      ;;
    *)
      # Video: 540px wide (2x the phone mockup), 30fps, no audio, H.264 with
      # faststart so playback begins before the whole file downloads.
      "$ffmpeg" -y -loglevel error -i "$f" \
        -vf "scale=540:-2:flags=lanczos,fps=30" \
        -an -c:v libx264 -preset slow -crf 28 -profile:v high -pix_fmt yuv420p \
        -movflags +faststart "$out/tulkarm-app.mp4"

      # VP9 WebM: usually noticeably smaller; browsers pick it first, MP4 is the fallback.
      "$ffmpeg" -y -loglevel error -i "$f" \
        -vf "scale=540:-2:flags=lanczos,fps=30" \
        -an -c:v libvpx-vp9 -b:v 0 -crf 44 -row-mt 1 -deadline good -cpu-used 2 \
        "$out/tulkarm-app.webm"

      # Poster frame shown before the video loads.
      "$ffmpeg" -y -loglevel error -ss 1 -i "$out/tulkarm-app.mp4" -frames:v 1 -q:v 4 \
        "$out/tulkarm-app-poster.jpg"
      ;;
  esac
done

ls -lh "$out"
