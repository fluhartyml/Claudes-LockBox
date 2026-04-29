//
//  LexiconSheet.swift
//  Claudes Web Wrapper
//
//  Created by Michael Fluharty on 4/27/26.
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Sheet shown when the user taps a Lexicon-tagged identifier in a
//  source code block inside Under the Hood. NavigationStack wraps a
//  LexiconEntryView so related-link taps push the next entry onto
//  the same stack — mirrors Kindle's tap-to-define experience but
//  for Swift identifiers. Rosetta Stone section is intentionally
//  absent (book-exclusive per the popup-skips-Rosetta rule).
//  ────────────────────────────────────────────────────────────────
//

import SwiftUI

struct LexiconSheet: View {
    let entry: LexiconEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            LexiconEntryView(entry: entry)
                .navigationDestination(for: String.self) { headword in
                    if let related = LexiconContent.entry(for: headword) {
                        LexiconEntryView(entry: related)
                    } else {
                        Text("No entry for “\(headword).”")
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

struct LexiconEntryView: View {
    let entry: LexiconEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text(entry.headword)
                    .font(.largeTitle.monospaced())

                Text(entry.definition)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Swift Example", systemImage: "swift")
                        .font(.headline)
                        .foregroundStyle(.tint)
                    ScrollView(.horizontal, showsIndicators: true) {
                        Text(entry.swiftExample)
                            .font(.system(.footnote, design: .monospaced))
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                    }
                    .frame(maxHeight: 240)
                    .background(codeBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                if !entry.related.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Related", systemImage: "link")
                            .font(.headline)
                            .foregroundStyle(.tint)
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(entry.related, id: \.self) { headword in
                                NavigationLink(value: headword) {
                                    HStack {
                                        Text(headword)
                                            .font(.body.monospaced())
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }

                if !entry.sources.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Sources", systemImage: "books.vertical")
                            .font(.headline)
                            .foregroundStyle(.tint)
                        ForEach(entry.sources, id: \.self) { source in
                            Link(destination: source.url) {
                                HStack {
                                    Text(source.title)
                                        .font(.body)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(entry.headword)
        #if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var codeBackground: Color {
        #if os(iOS) || os(visionOS)
        Color(.tertiarySystemBackground)
        #else
        Color.secondary.opacity(0.05)
        #endif
    }
}
