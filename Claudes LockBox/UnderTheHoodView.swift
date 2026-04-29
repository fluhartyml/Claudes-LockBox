//
//  UnderTheHoodView.swift
//  LockBox by Claude
//
//  Created by Michael Fluharty on 4/16/26.
//
//  ── Under the Hood ──────────────────────────────────────────────
//  This view IS the Under the Hood feature — a list of every Swift
//  file in the app with its filename, one-line purpose, and a tap-
//  to-expand sheet showing a developer-level callout, an embedded
//  source excerpt, and an Open-on-GitHub link to the live source.
//  Tappable Swift identifiers in the source block open a Lexicon
//  Quick-Define sheet for inline definitions.
//  ────────────────────────────────────────────────────────────────
//

import SwiftUI

struct UnderTheHoodView: View {
    @State private var selected: UnderTheHoodContent.FileEntry?

    var body: some View {
        NavigationStack {
            list
                .navigationTitle("Under the Hood")
                #if os(iOS) || os(visionOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
        }
    }

    private var list: some View {
        List {
            Section {
                Text("Tap a file to read why the code is written that way, browse the source, and jump to the live file on GitHub.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Source Files") {
                ForEach(UnderTheHoodContent.entries) { entry in
                    Button {
                        selected = entry
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "swift")
                                .foregroundStyle(.tint)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.filename)
                                    .font(.body.monospaced())
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(entry.purpose)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .sheet(item: $selected) { entry in
            FileDetailSheet(entry: entry)
        }
    }
}

private struct FileDetailSheet: View {
    let entry: UnderTheHoodContent.FileEntry
    @Environment(\.dismiss) private var dismiss
    @State private var lexiconSelection: LexiconEntry?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(entry.filename)
                            .font(.title3.monospaced())
                        Text(entry.purpose)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Under the Hood", systemImage: "wrench.and.screwdriver")
                            .font(.headline)
                            .foregroundStyle(.tint)
                        Text(entry.callout)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Source — tap any tinted identifier",
                              systemImage: "swift")
                            .font(.headline)
                            .foregroundStyle(.tint)
                        ScrollView(.horizontal, showsIndicators: true) {
                            IdentifierTaggedSourceView(source: entry.source)
                        }
                        .frame(maxHeight: 400)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    if let url = entry.githubURL {
                        Link(destination: url) {
                            Label("Open on GitHub", systemImage: "arrow.up.right.square")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .padding()
            }
            .navigationTitle("Source File")
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .environment(\.openURL, OpenURLAction { url in
                if url.scheme == "lexicon",
                   let host = url.host?.removingPercentEncoding,
                   let lexicon = LexiconContent.entry(for: host) {
                    lexiconSelection = lexicon
                    return .handled
                }
                return .systemAction
            })
            .sheet(item: $lexiconSelection) { lex in
                LexiconSheet(entry: lex)
            }
        }
    }
}

#Preview {
    UnderTheHoodView()
}
