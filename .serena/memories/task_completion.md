# Task Completion Checklist
- Run tests: `xcodebuild test -project OpenReelStudio.xcodeproj -scheme OpenReelStudio` (from repo root).
- If UI or runtime changes: launch via Xcode to verify Generator/Gallery/Settings tabs and SwiftData interactions.
- Update docs if behavior or requirements change (README.md or docs/).
- Keep API keys out of source; rely on KeychainHelper/BookmarkStore for secrets and folder bookmarks.
- No formatter/linter configured; keep Swift style consistent with existing code (SwiftUI idioms, clear naming).