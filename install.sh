#!/bin/sh
# Install Chatwoot Board (macOS, Apple Silicon):
#
#   curl -fsSL https://raw.githubusercontent.com/aminosman/chatwoot-board-releases/main/install.sh | sh
#
# Downloads the newest release from this repo's feed and puts it in
# /Applications. Downloading with curl rather than a browser means macOS does
# not quarantine the app, so it opens without a Gatekeeper prompt (it is not
# Apple-notarized). From then on the app updates itself: every update is
# verified against the release signing key baked into the app.
set -eu

FEED="https://raw.githubusercontent.com/aminosman/chatwoot-board-releases/main/feed.json"
DEST="/Applications"
APP="Chatwoot Board.app"

[ "$(uname -s)" = "Darwin" ] || { echo "Chatwoot Board is macOS only." >&2; exit 1; }
[ "$(uname -m)" = "arm64" ] || { echo "Chatwoot Board is built for Apple Silicon only." >&2; exit 1; }

# JavaScript for Automation ships with every Mac, so no python/node needed.
URL="$(curl -fsSL "$FEED?t=$(date +%s)" | osascript -l JavaScript -e '
  function run() {
    const input = $.NSFileHandle.fileHandleWithStandardInput.readDataToEndOfFile
    const feed = JSON.parse($.NSString.alloc.initWithDataEncoding(input, $.NSUTF8StringEncoding).js)
    const items = feed.filter(i => i.channel === "chatwoot-board")
    const cmp = (a, b) => { const x = a.split(".").map(Number), y = b.split(".").map(Number); for (let i = 0; i < 3; i++) if (x[i] !== y[i]) return x[i] - y[i]; return 0 }
    items.sort((a, b) => cmp(b.marketing, a.marketing))
    return items.length ? items[0].url : ""
  }')"
[ -n "$URL" ] || { echo "No release found in the feed." >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "Downloading $URL"
curl -fL --progress-bar "$URL" -o "$TMP/app.zip"
ditto -x -k "$TMP/app.zip" "$TMP/unzipped"

if [ -d "$DEST/$APP" ]; then
  osascript -e 'quit app "Chatwoot Board"' 2>/dev/null || true
  sleep 1
  rm -rf "$DEST/$APP.previous"
  mv "$DEST/$APP" "$DEST/$APP.previous"
fi
mv "$TMP/unzipped/$APP" "$DEST/$APP"
xattr -dr com.apple.quarantine "$DEST/$APP" 2>/dev/null || true
echo "Installed $DEST/$APP"
open "$DEST/$APP"
