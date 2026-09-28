#!/usr/bin/env bash
# Compress the app recording and resize the portrait into assets/.
# Usage: scripts/prepare-assets.sh <photo> <screen-recording>
set -euo pipefail

photo=${1:?usage: $0 <photo> <screen-recording>}
video=${2:?usage: $0 <photo> <screen-recording>}
out="$(cd "$(dirname "$0")/.." && pwd)/assets"
mkdir -p "$out"

ffmpeg=$(command -v ffmpeg || python3 -c 'import imageio_ffmpeg as f; print(f.get_ffmpeg_exe())')

# Portrait: centre-crop to a square, 480x480 (2x the largest on-screen size).
"$ffmpeg" -y -loglevel error -i "$photo" \
  -vf "crop='min(iw,ih)':'min(iw,ih)',scale=480:480:flags=lanczos" \
  -q:v 3 "$out/yazan.jpg"

# Video: 540px wide (2x the phone mockup), 30fps, no audio, H.264 with
# faststart so playback begins before the whole file downloads.
"$ffmpeg" -y -loglevel error -i "$video" \
  -vf "scale=540:-2:flags=lanczos,fps=30" \
  -an -c:v libx264 -preset slow -crf 28 -profile:v high -pix_fmt yuv420p \
  -movflags +faststart "$out/tulkarm-app.mp4"

# VP9 WebM: usually noticeably smaller; browsers pick it first, MP4 is the fallback.
"$ffmpeg" -y -loglevel error -i "$video" \
  -vf "scale=540:-2:flags=lanczos,fps=30" \
  -an -c:v libvpx-vp9 -b:v 0 -crf 38 -row-mt 1 -deadline good -cpu-used 2 \
  "$out/tulkarm-app.webm"

# Poster frame shown before the video loads.
"$ffmpeg" -y -loglevel error -ss 1 -i "$out/tulkarm-app.mp4" -frames:v 1 -q:v 4 \
  "$out/tulkarm-app-poster.jpg"

ls -lh "$out"
