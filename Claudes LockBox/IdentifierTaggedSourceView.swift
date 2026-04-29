//
//  IdentifierTaggedSourceView.swift
//  Claudes Web Wrapper
//
//  Created by Michael Fluharty on 4/27/26.
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Renders a Swift source string with every Lexicon-headword match
//  tagged as a tappable lexicon:// link. The parent view installs a
//  custom OpenURLAction in its environment that intercepts the
//  scheme and presents LexiconSheet — so the user gets Kindle-style
//  tap-to-define inside the source code block, no scroll-jumping.
//
//  AttributedString is built once per source string (not per render)
//  via a regex pass against LexiconContent.allHeadwords with word
//  boundaries (\b<headword>\b) so matches don't fire inside other
//  identifiers. Tagged ranges get .accentColor + single underline
//  so users can see what's tappable.
//  ────────────────────────────────────────────────────────────────
//

import SwiftUI

struct IdentifierTaggedSourceView: View {
    let source: String
    @State private var attributed: AttributedString = AttributedString("")

    var body: some View {
        Text(attributed)
            .font(.system(.footnote, design: .monospaced))
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .task(id: source) {
                attributed = Self.tag(source: source, headwords: LexiconContent.allHeadwords)
            }
    }

    static func tag(source: String, headwords: [String]) -> AttributedString {
        var attr = AttributedString(source)
        for headword in headwords {
            let escaped = NSRegularExpression.escapedPattern(for: headword)
            guard let pattern = try? NSRegularExpression(pattern: "\\b\(escaped)\\b") else { continue }
            let nsRange = NSRange(source.startIndex..<source.endIndex, in: source)
            let matches = pattern.matches(in: source, range: nsRange)
            for match in matches {
                guard let stringRange = Range(match.range, in: source),
                      let attrRange = attr.range(of: source[stringRange]) else { continue }
                if let encoded = headword.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                   let url = URL(string: "lexicon://\(encoded)") {
                    attr[attrRange].link = url
                    attr[attrRange].foregroundColor = .accentColor
                    attr[attrRange].underlineStyle = .single
                }
            }
        }
        return attr
    }
}
