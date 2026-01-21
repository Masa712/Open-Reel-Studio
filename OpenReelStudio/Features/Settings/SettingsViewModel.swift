//
//  SettingsViewModel.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var openAIKey = ""
    @Published var klingKey = ""
    @Published var googleKey = ""
    @Published var outputFolderPath = "未設定"
    @Published var statusMessage: String?

    init() {
        openAIKey = KeychainHelper.loadKey(account: "api_key_openai") ?? ""
        klingKey = KeychainHelper.loadKey(account: "api_key_kling") ?? ""
        googleKey = KeychainHelper.loadKey(account: "api_key_google") ?? ""
        outputFolderPath = BookmarkStore.loadOutputFolder()?.path ?? "未設定"
    }

    func saveKeys() {
        do {
            try saveKey(openAIKey, account: "api_key_openai")
            try saveKey(klingKey, account: "api_key_kling")
            try saveKey(googleKey, account: "api_key_google")
            statusMessage = "APIキーを保存しました。"
        } catch {
            statusMessage = "APIキーの保存に失敗しました。"
        }
    }

    func updateOutputFolder(url: URL) {
        do {
            try BookmarkStore.saveOutputFolder(url: url)
            outputFolderPath = url.path
            statusMessage = "保存先フォルダを更新しました。"
        } catch {
            statusMessage = "保存先フォルダの保存に失敗しました。"
        }
    }

    private func saveKey(_ value: String, account: String) throws {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try KeychainHelper.deleteKey(account: account)
        } else {
            try KeychainHelper.saveKey(value, account: account)
        }
    }
}

