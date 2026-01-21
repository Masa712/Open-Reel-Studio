# Open Reel Studio

複数の動画生成AIモデル（Sora / Veo / Kling 等）を統合管理し、映像生成の実験・制作を行うための
macOSネイティブなサンドボックス環境を提供するOSSプロジェクトです。

## Status
- **Phase:** Project Initialization (フェーズ1)
- **Focus:** プロジェクトのセットアップ、フォルダ構成の作成、基本UIの実装

## Features (Planned)
- APIキー管理（Keychain保存）
- モデル有効/無効の切替
- コスト管理（可能であればローカルで概算）
- プロンプト入力（マルチライン、スタイルプリセット、Magic Promptプレースホルダー）
- パラメータ設定（アスペクト比、Duration、Image-to-Video DnD）
- 非同期の生成処理（UIをブロックしない）
- 生成ギャラリー（グリッド表示・プレビュー）
- メタデータ閲覧（プロンプト/モデル/シード/設定）
- 履歴保持と再生成（Reroll）

## Tech Stack
- macOS 15.0+ (Sequoia想定)
- Swift 6 / SwiftUI
- SwiftData（履歴・メタデータ保存）
- Keychain Services（APIキー）
- URLSession + async/await

## Architecture
MVVM + Service Provider Pattern を採用します。
- `VideoGenerationServiceProtocol` を共通インターフェースとして、モデル追加は準拠実装のみで拡張可能にする
- `APIManager` が通信の一元管理とエラーハンドリングを担う
- `GenerationItem` (SwiftData) で生成履歴・メタデータを保持

## Directory Structure (Planned)
```
OpenReelStudio/
├── App/
│   └── OpenReelStudioApp.swift
├── Features/
│   ├── Dashboard/
│   ├── Generator/
│   ├── Gallery/
│   └── Settings/
├── Core/
│   ├── Services/
│   ├── Models/
│   └── Utils/
└── Resources/
    └── Assets.xcassets
```

## Development
- Xcodeで `OpenReelStudio.xcodeproj` を開く
- テスト: `xcodebuild test -project OpenReelStudio.xcodeproj -scheme OpenReelStudio`

## License
MIT
