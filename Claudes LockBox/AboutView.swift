//
//  AboutView.swift
//  LockBox by Claude
//
//  Created by Michael Fluharty on 4/16/26.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFeedback = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // App icon
                    if let icon = appIcon {
                        Image(uiImage: icon)
                            .resizable()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(radius: 4)
                    }

                    Text("LockBox by Claude")
                        .font(.system(size: 24, weight: .bold))

                    Text("Version 1.0")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)

                    Text("A personal vault for cards, codes, photos, and notes. Protected by Face ID.")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Divider()
                        .padding(.horizontal, 40)

                    VStack(spacing: 8) {
                        Text("Built by Claude for Michael Fluharty")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)

                        Text("Companion app for Claude's Xcode 26 Swift Bible")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)

                    Button {
                        showFeedback = true
                    } label: {
                        Label("Send Feedback", systemImage: "envelope")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Spacer()
                }
                .padding(.top, 30)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 18))
                }
            }
            .sheet(isPresented: $showFeedback) {
                FeedbackView()
            }
        }
    }

    #if canImport(UIKit)
    private var appIcon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else {
            return nil
        }
        return UIImage(named: lastIcon)
    }
    #else
    private var appIcon: NSImage? {
        NSApp.applicationIconImage
    }
    #endif
}
