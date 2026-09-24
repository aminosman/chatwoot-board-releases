# Chatwoot Board — releases

Release builds and the update feed for Chatwoot Board, a macOS board and
agent workspace for Chatwoot support. The source lives in a private repo;
this repo holds only what installed copies download.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/aminosman/chatwoot-board-releases/main/install.sh | sh
```

Apple Silicon, macOS 13 or later. After that the app updates itself.

## How updates work

- `feed.json` lists every release; `appcast.xml` is the same feed in Sparkle's
  format, regenerated from it.
- Each item names a zip on this repo's GitHub releases and carries an Ed25519
  signature over the zip's bytes.
- The app checks the feed hourly, downloads anything newer, verifies the
  signature against the public key built into it, checks the bundle is
  Chatwoot Board at the version the feed claims, and installs it on restart
  (keeping the previous copy as `Chatwoot Board.app.previous`).
- The signature is the only trust anchor. A zip that does not verify is
  refused, whoever served it.
