//
//  GalleryView.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import SwiftUI
import SwiftData

struct GalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\GenerationItem.createdAt, order: .reverse)])
    private var items: [GenerationItem]

    private let columns = [
        GridItem(.adaptive(minimum: 220), spacing: 16),
    ]

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    ContentUnavailableView(
                        "No Generations Yet",
                        systemImage: "rectangle.stack",
                        description: Text("Generate a video to see it here.")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(items) { item in
                                NavigationLink {
                                    GalleryDetailView(item: item)
                                } label: {
                                    GenerationCard(item: item)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        delete(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Gallery")
        }
    }

    private func delete(_ item: GenerationItem) {
        modelContext.delete(item)
        do {
            try modelContext.save()
        } catch {
            // Keep silent; error surfacing handled by higher-level UI later.
        }
    }
}

private struct GenerationCard: View {
    let item: GenerationItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                statusBadge
                Spacer()
                Text(item.createdAt, format: .dateTime.year().month().day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(item.prompt)
                .font(.headline)
                .lineLimit(3)

            HStack(spacing: 6) {
                Label(item.modelId, systemImage: "bolt.circle")
                if item.localFilePath != nil {
                    Label("Saved", systemImage: "tray.and.arrow.down")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var statusBadge: some View {
        Text(item.status.capitalized)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.15), in: Capsule())
    }

    private var statusColor: Color {
        switch item.status.lowercased() {
        case "completed", "success", "succeeded":
            return .green
        case "failed", "error":
            return .red
        case "processing", "running":
            return .orange
        default:
            return .secondary
        }
    }
}

private struct GalleryDetailView: View {
    let item: GenerationItem

    var body: some View {
        Form {
            Section("Prompt") {
                Text(item.prompt)
                    .textSelection(.enabled)
            }

            Section("Status") {
                LabeledContent("State", value: item.status)
                if let finishedAt = item.finishedAt {
                    LabeledContent("Finished", value: finishedAt.formatted())
                }
                if let errorMessage = item.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section("Model") {
                LabeledContent("Model ID", value: item.modelId)
            }

            Section("Files") {
                if let path = item.localFilePath {
                    LabeledContent("Local Path", value: path)
                }
                if let remoteURL = item.remoteURL {
                    LabeledContent("Remote URL", value: remoteURL)
                }
            }

            Section("Metadata") {
                Text(item.metadataJSON)
                    .font(.caption)
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("Detail")
    }
}

#Preview {
    let schema = Schema([GenerationItem.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    let sample = GenerationItem(
        prompt: "A cinematic cityscape at dusk with neon reflections.",
        modelId: "kling-v1",
        status: "completed",
        finishedAt: Date(),
        localFilePath: "videos/sample.mov",
        metadataJSON: "{\"width\":1920,\"height\":1080}"
    )
    container.mainContext.insert(sample)

    return GalleryView()
        .modelContainer(container)
}

