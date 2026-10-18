#!/usr/bin/env bash
# Safe preview of the XMB home screen with made-up apps - nothing launches or changes.
# Runs from a temporary copy, so your own sounds (custom-sounds/) can go in without
# changing the repo's files; the copy is deleted when the preview closes.

QML=""
for c in qml6 qml-qt6 /usr/lib64/qt6/bin/qml /usr/lib/qt6/bin/qml; do
    command -v "$c" >/dev/null 2>&1 && { QML="$c"; break; }
done
if [ -z "$QML" ]; then
    echo "Qt's qml tool isn't installed. Fedora: sudo dnf install qt6-qtdeclarative-devel"
    echo "(Other distros: find the package that has qt6/bin/qml.)"
    exit 1
fi

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp -r "$REPO/xmb" "$REPO/preview" "$TMP/"

USED=""
for n in move select back error open; do
    src="$(ls "$REPO/custom-sounds/$n".* 2>/dev/null | head -1)"
    [ -n "$src" ] || continue
    case "$src" in
        *.wav) cp "$src" "$TMP/xmb/sounds/$n.wav" ;;
        *) if command -v ffmpeg >/dev/null 2>&1; then
               ffmpeg -loglevel error -y -i "$src" -ac 2 -ar 48000 -c:a pcm_s16le "$TMP/xmb/sounds/$n.wav" || continue
           else
               echo "Skipping $src: needs ffmpeg to convert it (Fedora: sudo dnf install ffmpeg-free)"; continue
           fi ;;
    esac
    USED="$USED $n"
done
[ -n "$USED" ] && echo "Using your sounds:$USED"

echo "Arrows move, Enter selects, Esc goes back, P pauses the wave. Exit with Ctrl+Q."
echo "Nothing launches or changes - choices only show a note."
"$QML" "$TMP/preview/Preview.qml"
