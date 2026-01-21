//
//  BookmarkStore.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import Foundation

enum BookmarkStore {
    private static let outputFolderKey = "output_folder_bookmark"

    static func saveOutputFolder(url: URL) throws {
        let data = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        UserDefaults.standard.set(data, forKey: outputFolderKey)
    }

    static func loadOutputFolder() -> URL? {
        guard let data = UserDefaults.standard.data(forKey: outputFolderKey) else {
            return nil
        }

        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: data,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            return nil
        }

        guard !isStale else { return nil }
        return url
    }
}

