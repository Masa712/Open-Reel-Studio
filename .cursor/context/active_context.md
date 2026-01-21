# Active Development Context: Open Reel Studio

## 📍 Current Status (現在地)
- **Phase:** Project Initialization (フェーズ1)
- **Focus:** プロジェクトのセットアップ、フォルダ構成の作成、基本UIの実装。

## ✅ Completed (完了事項)
- [x] Xcodeプロジェクト作成
- [x] .gitignore設定
- [x] AI開発環境（.cursorrules）の整備
- [x] GitHubリポジトリへの初回プッシュ
- [x] 要件定義書・技術仕様書のたたき台作成
- [x] 要件定義書・技術仕様書の改訂（配布/保存/通知方針）
- [x] SwiftDataモデル `GenerationItem` の実装
- [x] Providerプロトコルの実装
- [x] MockProviderの実装
- [x] Kling APIの仮実装（暫定仕様）
- [x] 生成ワークフローのViewModel実装
- [x] 生成画面UIの実装
- [x] ギャラリー画面UIの実装
- [x] 設定画面UIの実装（APIキー/保存先）

## 🚧 In Progress / Next Steps (直近のタスク)
1. Kling APIの実仕様への適合（エンドポイント/レスポンス確定後）
2. 保存先フォルダのブックマーク再利用（アクセス開始処理）

## 📝 Technical Notes & Decisions (技術メモ・決定事項)
- **Architecture:** MVVMを採用。
- **Data Persistence:** SwiftData
- **Distribution:** GitHubで直接配布（現時点）
- **Storage:** 保存先はユーザー選択フォルダ
- **Notifications:** アプリ内通知のみ（MVP）
