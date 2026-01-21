# 技術仕様書 (Technical Specifications)

## 2.1 技術スタック
- **OS:** macOS 15.0+ (Sequoia想定)
- **言語:** Swift 6
- **UIフレームワーク:** SwiftUI
- **データ永続化:** SwiftData
- **キー管理:** Security framework (Keychain Services)
- **通信:** URLSession (Concurrency: async/await)
- **配布:** GitHubによる直接配布（現時点）

## 2.2 アーキテクチャ設計
MVVM (Model-View-ViewModel) + Service Provider Pattern を採用。

### A. データモデル（SwiftData Schema）
```swift
@Model
class GenerationItem {
    @Attribute(.unique) var id: UUID
    var prompt: String
    var negativePrompt: String?
    var modelId: String         // 例: "kling-v1", "mock-v1"
    var status: String          // "queued", "processing", "completed", "failed"
    var createdAt: Date
    var finishedAt: Date?

    // 成果物管理
    var localFilePath: String?  // 選択フォルダからの相対パス推奨
    var remoteURL: String?      // API一時URL

    // メタデータ (JSON String)
    // 推奨キー: width, height, duration, seed, cfg_scale
    var metadataJSON: String

    // エラー情報
    var errorMessage: String?

    init(...) { ... }
}
```

### B. プロバイダ設計 (Provider Protocol)
拡張性を担保するため、全ての動画生成サービスは以下のプロトコルに準拠する。

```swift
protocol VideoProviderProtocol {
    var providerId: String { get } // "openai", "kling"

    // 1. 生成リクエスト (Job IDを返す)
    func startGeneration(prompt: String, config: GenerationConfig) async throws -> String

    // 2. ステータス確認 (Polling用)
    func checkStatus(jobId: String) async throws -> GenerationStatus
}

struct GenerationConfig {
    var aspectRatio: String
    var duration: Int
    // 将来的に imageInput: Data? 等を追加
}

enum GenerationStatus {
    case processing(progress: Double?) // 進捗率 (0.0 - 1.0)
    case completed(videoURL: URL)
    case failed(reason: String)
}
```

### C. 生成ジョブ仕様
- **非同期処理:** `Task` と SwiftData を連動させる。
- **ポーリング戦略:**
  - 初期: 5秒間隔
  - 30秒経過後: 10秒間隔
  - タイムアウト: 5分（設定で可変）
- **中断処理:** アプリ終了時はタスク破棄。次回起動時に `processing` の項目は「中断/失敗」扱い、または再チェックを行う。

### D. 保存先・権限
- 保存先はユーザー選択フォルダを使用する。
- App Sandboxを有効化する場合、Security-Scoped BookmarkをUserDefaultsに保存して再アクセスを可能にする。
- 保存ファイル名は生成時刻ベース + モデル識別子の命名を想定する。

### E. テスト/品質戦略
- **Mock First開発:** 初期開発は MockProvider (ダミー動画を返すクラス) で進め、UI開発とAPIロジック開発を分離する。
- **ユニットテスト対象:**
  - APIManager (JSONパース、エラーハンドリング)
  - KeychainHelper (保存・読み出し・削除)
  - GenerationItem (モデルのバリデーション)

## 2.3 ディレクトリ構成
```
OpenReelStudio/
├── App/
│   └── OpenReelStudioApp.swift
├── Features/
│   ├── Dashboard/          # タブ管理など
│   ├── Generator/          # 生成画面 (ViewModel含む)
│   ├── Gallery/            # 一覧・詳細画面
│   └── Settings/           # APIキー設定画面
├── Core/
│   ├── Services/           # Provider / Mock / API通信ロジック
│   ├── Models/             # SwiftDataモデル
│   └── Utils/              # Keychain, Bookmark, Extensions
└── Resources/
    └── Assets.xcassets
```

