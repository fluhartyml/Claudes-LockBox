//
//  LexiconContent.swift
//  Claudes Web Wrapper
//
//  Created by Michael Fluharty on 4/27/26.
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Hand-authored starter corpus of Lexicon entries covering Swift
//  identifiers that actually appear in this app's source. Tappable
//  highlight in the Under the Hood source block fires only on words
//  present here, so the user never taps a word that 404s. Corpus
//  grows organically as the wiki Lexicon page collection is written.
//
//  Per the popup-skips-Rosetta rule, the in-app Lexicon entry omits
//  the Rosetta Stone (Delphi/Pascal, BASIC, C/C++) section that the
//  full book Lexicon Pages carry — that comparative material stays
//  book-exclusive.
//  ────────────────────────────────────────────────────────────────
//

import Foundation

enum LexiconContent {
    static let entries: [LexiconEntry] = [

        LexiconEntry(
            headword: "WKWebView",
            definition: "WebKit's iOS / iPadOS / macOS / visionOS view that renders web content. The modern replacement for UIWebView (deprecated). WKWebView runs the web content in a separate process for security and performance, supports JavaScript, custom URL schemes, and is the only browser engine Apple permits in third-party apps.",
            swiftExample: """
                import WebKit
                let webView = WKWebView()
                webView.load(URLRequest(url: URL(string: "https://apple.com")!))
                """,
            related: ["URLRequest", "URL", "UIViewRepresentable"],
            sources: [
                .init(title: "Apple Developer — WKWebView", url: URL(string: "https://developer.apple.com/documentation/webkit/wkwebview")!)
            ]
        ),

        LexiconEntry(
            headword: "UIViewRepresentable",
            definition: "A SwiftUI protocol that wraps a UIKit UIView so it can appear inside a SwiftUI view hierarchy. Required when SwiftUI doesn't have a native equivalent of the UIKit class you need (like WKWebView). You implement makeUIView to create the wrapped view and updateUIView to push state changes from SwiftUI into it.",
            swiftExample: """
                struct WebViewRepresentable: UIViewRepresentable {
                    let webView: WKWebView
                    func makeUIView(context: Context) -> WKWebView { webView }
                    func updateUIView(_ uiView: WKWebView, context: Context) {}
                }
                """,
            related: ["NSViewRepresentable", "WKWebView", "View"],
            sources: [
                .init(title: "Apple Developer — UIViewRepresentable", url: URL(string: "https://developer.apple.com/documentation/swiftui/uiviewrepresentable")!)
            ]
        ),

        LexiconEntry(
            headword: "NSViewRepresentable",
            definition: "The macOS counterpart to UIViewRepresentable. Wraps an AppKit NSView for use inside SwiftUI on macOS. Same shape as UIViewRepresentable but the protocol differs because AppKit and UIKit aren't unified — every cross-platform SwiftUI app that bridges native views ends up with both protocols behind a #if os(macOS) branch.",
            swiftExample: """
                #if os(macOS)
                struct WebViewRepresentable: NSViewRepresentable {
                    let webView: WKWebView
                    func makeNSView(context: Context) -> WKWebView { webView }
                    func updateNSView(_ nsView: WKWebView, context: Context) {}
                }
                #endif
                """,
            related: ["UIViewRepresentable", "WKWebView", "View"],
            sources: [
                .init(title: "Apple Developer — NSViewRepresentable", url: URL(string: "https://developer.apple.com/documentation/swiftui/nsviewrepresentable")!)
            ]
        ),

        LexiconEntry(
            headword: "WindowGroup",
            definition: "A SwiftUI Scene that presents a group of windows displaying the same view hierarchy. Used inside an App's body to declare the main user-facing window. On iOS / iPadOS / visionOS this is the single app window; on macOS the user can open multiple windows from the same WindowGroup.",
            swiftExample: """
                @main
                struct MyApp: App {
                    var body: some Scene {
                        WindowGroup {
                            ContentView()
                        }
                    }
                }
                """,
            related: ["App", "Scene", "View"],
            sources: [
                .init(title: "Apple Developer — WindowGroup", url: URL(string: "https://developer.apple.com/documentation/swiftui/windowgroup")!)
            ]
        ),

        LexiconEntry(
            headword: "App",
            definition: "The SwiftUI protocol every Swift 6 app conforms to at its top level. The struct marked @main provides a body of type some Scene that declares the app's window structure. App is the entry point — Swift programs that use App don't need a UIApplicationMain or NSApplicationMain stub.",
            swiftExample: """
                @main
                struct MyApp: App {
                    var body: some Scene {
                        WindowGroup { ContentView() }
                    }
                }
                """,
            related: ["Scene", "WindowGroup", "View"],
            sources: [
                .init(title: "Apple Developer — App", url: URL(string: "https://developer.apple.com/documentation/swiftui/app")!)
            ]
        ),

        LexiconEntry(
            headword: "Scene",
            definition: "A SwiftUI protocol representing a top-level container — a window, a document, a settings pane. The body of an App returns some Scene. Built-in scene types include WindowGroup, DocumentGroup, Settings, MenuBarExtra. Custom scenes can be composed from these.",
            swiftExample: """
                var body: some Scene {
                    WindowGroup { ContentView() }
                    Settings { SettingsView() }
                }
                """,
            related: ["App", "WindowGroup", "View"],
            sources: [
                .init(title: "Apple Developer — Scene", url: URL(string: "https://developer.apple.com/documentation/swiftui/scene")!)
            ]
        ),

        LexiconEntry(
            headword: "View",
            definition: "The fundamental SwiftUI protocol — anything that can be drawn on screen conforms to View. A View has a single computed property body of type some View that describes the view's content. Views are value types (structs); SwiftUI creates and discards them constantly as state changes.",
            swiftExample: """
                struct Hello: View {
                    var body: some View {
                        Text("Hello, world.")
                    }
                }
                """,
            related: ["State", "Environment", "NavigationStack"],
            sources: [
                .init(title: "Apple Developer — View", url: URL(string: "https://developer.apple.com/documentation/swiftui/view")!)
            ]
        ),

        LexiconEntry(
            headword: "State",
            definition: "A SwiftUI property wrapper that gives a view a piece of mutable, view-local state. SwiftUI persists @State values across view rebuilds and re-renders the view when they change. Use @State for state owned by the view itself; use @Binding to pass state ownership down, @Environment to read shared state up the hierarchy.",
            swiftExample: """
                struct Counter: View {
                    @State private var count = 0
                    var body: some View {
                        Button("Tapped \\(count) times") { count += 1 }
                    }
                }
                """,
            related: ["Environment", "View"],
            sources: [
                .init(title: "Apple Developer — State", url: URL(string: "https://developer.apple.com/documentation/swiftui/state")!)
            ]
        ),

        LexiconEntry(
            headword: "Environment",
            definition: "A SwiftUI property wrapper that reads a value from the surrounding environment — values set on a parent view (or by SwiftUI itself) become available to descendants without explicit passing. Built-in environment values include \\.dismiss, \\.modelContext, \\.openURL, \\.colorScheme, \\.locale.",
            swiftExample: """
                struct DetailView: View {
                    @Environment(\\.dismiss) private var dismiss
                    var body: some View {
                        Button("Close") { dismiss() }
                    }
                }
                """,
            related: ["State", "View"],
            sources: [
                .init(title: "Apple Developer — Environment", url: URL(string: "https://developer.apple.com/documentation/swiftui/environment")!)
            ]
        ),

        LexiconEntry(
            headword: "NavigationStack",
            definition: "A SwiftUI container that pushes and pops views in response to NavigationLink taps or programmatic path changes. Replaces the deprecated NavigationView (iOS 13–16). NavigationStack is required on iOS 16+ for the modern push-pop navigation API and integrates with NavigationPath for programmatic control.",
            swiftExample: """
                NavigationStack {
                    List {
                        NavigationLink("Detail") {
                            DetailView()
                        }
                    }
                    .navigationTitle("Home")
                }
                """,
            related: ["NavigationLink", "View"],
            sources: [
                .init(title: "Apple Developer — NavigationStack", url: URL(string: "https://developer.apple.com/documentation/swiftui/navigationstack")!)
            ]
        ),

        LexiconEntry(
            headword: "NavigationLink",
            definition: "A SwiftUI control that pushes a destination view onto the enclosing NavigationStack when tapped. Two common forms: NavigationLink(_:destination:) for label + view inline; NavigationLink(value:label:) for value-based navigation paired with .navigationDestination(for:destination:).",
            swiftExample: """
                NavigationLink("Settings") {
                    SettingsView()
                }
                """,
            related: ["NavigationStack", "View"],
            sources: [
                .init(title: "Apple Developer — NavigationLink", url: URL(string: "https://developer.apple.com/documentation/swiftui/navigationlink")!)
            ]
        ),

        LexiconEntry(
            headword: "Bookmark",
            definition: "In this app: a SwiftData @Model that stores a saved web page (title, URL string, date added). Persists across app launches. Used by the bookmarks feature. The same word in iOS more broadly refers to a security-scoped URL bookmark (URL.bookmarkData) for cross-launch file-system access — that is a different mechanism.",
            swiftExample: """
                @Model
                class Bookmark {
                    var title: String
                    var urlString: String
                    var dateAdded: Date
                    init(title: String, urlString: String) {
                        self.title = title
                        self.urlString = urlString
                        self.dateAdded = .now
                    }
                }
                """,
            related: ["Model", "Query", "ModelContext"],
            sources: [
                .init(title: "Apple Developer — SwiftData", url: URL(string: "https://developer.apple.com/documentation/swiftdata")!)
            ]
        ),

        LexiconEntry(
            headword: "Model",
            definition: "A SwiftData macro that turns a Swift class into a persistable model. The macro generates the boilerplate that lets the class be stored in a ModelContainer / queried via @Query / mutated via ModelContext. Replaces Core Data's NSManagedObject with a much smaller surface area for typical app needs.",
            swiftExample: """
                @Model
                class Item {
                    var name: String
                    init(name: String) { self.name = name }
                }
                """,
            related: ["Query", "ModelContext", "Bookmark"],
            sources: [
                .init(title: "Apple Developer — Model macro", url: URL(string: "https://developer.apple.com/documentation/swiftdata/model")!)
            ]
        ),

        LexiconEntry(
            headword: "Query",
            definition: "A SwiftData property wrapper that fetches model instances from the active ModelContainer. Updates the view automatically when the underlying store changes. Supports sort descriptors and predicates for filtering / ordering. Comparable to Core Data's @FetchRequest, but lighter and macro-driven.",
            swiftExample: """
                @Query(sort: \\Bookmark.dateAdded, order: .reverse)
                private var bookmarks: [Bookmark]
                """,
            related: ["Model", "ModelContext"],
            sources: [
                .init(title: "Apple Developer — Query", url: URL(string: "https://developer.apple.com/documentation/swiftdata/query")!)
            ]
        ),

        LexiconEntry(
            headword: "ModelContext",
            definition: "The SwiftData object responsible for tracking changes to model instances and committing them to the persistent store. Inserted via @Environment(\\.modelContext). insert(_:) adds a new instance, delete(_:) removes one. Autosaves on context changes by default.",
            swiftExample: """
                @Environment(\\.modelContext) private var modelContext
                func save(_ item: Item) {
                    modelContext.insert(item)
                }
                """,
            related: ["Model", "Query"],
            sources: [
                .init(title: "Apple Developer — ModelContext", url: URL(string: "https://developer.apple.com/documentation/swiftdata/modelcontext")!)
            ]
        ),

        LexiconEntry(
            headword: "URL",
            definition: "Foundation's value type representing a uniform resource locator — a network resource, a file path, or a custom-scheme URL like lexicon://Codable. Initialized from a string (failable initializer returns Optional). URL is Codable, Hashable, and used pervasively across networking, file I/O, and SwiftUI's openURL.",
            swiftExample: """
                let url = URL(string: "https://apple.com")!
                let request = URLRequest(url: url)
                """,
            related: ["URLRequest", "OpenURLAction"],
            sources: [
                .init(title: "Apple Developer — URL", url: URL(string: "https://developer.apple.com/documentation/foundation/url")!)
            ]
        ),

        LexiconEntry(
            headword: "URLRequest",
            definition: "Foundation's value type representing a request to fetch a resource at a URL. Carries the URL plus optional HTTP method, headers, body, and cache policy. Loaded by URLSession (raw networking) or by views like WKWebView (web rendering).",
            swiftExample: """
                let request = URLRequest(url: URL(string: "https://apple.com")!)
                webView.load(request)
                """,
            related: ["URL", "WKWebView"],
            sources: [
                .init(title: "Apple Developer — URLRequest", url: URL(string: "https://developer.apple.com/documentation/foundation/urlrequest")!)
            ]
        ),

        LexiconEntry(
            headword: "AttributedString",
            definition: "Foundation's modern, Codable, value-type string with per-range attributes (font, foreground color, link, custom attributes). Replaces NSAttributedString for new code. SwiftUI's Text accepts AttributedString directly; tap-on-link interception works via Environment(\\.openURL).",
            swiftExample: """
                var attr = AttributedString("Tap here")
                attr.link = URL(string: "https://apple.com")
                Text(attr)
                """,
            related: ["URL", "OpenURLAction"],
            sources: [
                .init(title: "Apple Developer — AttributedString", url: URL(string: "https://developer.apple.com/documentation/foundation/attributedstring")!)
            ]
        ),

        LexiconEntry(
            headword: "OpenURLAction",
            definition: "A SwiftUI environment value (\\.openURL) that opens URLs. Can be invoked directly (openURL(myURL)) or installed as a custom interceptor via .environment(\\.openURL, OpenURLAction { url in ... }) so a parent view handles its descendants' link taps without leaving the app — used here to intercept lexicon:// URLs and present the Lexicon sheet.",
            swiftExample: """
                .environment(\\.openURL, OpenURLAction { url in
                    if url.scheme == "lexicon" {
                        // present in-app sheet
                        return .handled
                    }
                    return .systemAction
                })
                """,
            related: ["URL", "AttributedString", "Environment"],
            sources: [
                .init(title: "Apple Developer — OpenURLAction", url: URL(string: "https://developer.apple.com/documentation/swiftui/openurlaction")!)
            ]
        )
    ]

    /// Looks up an entry by exact headword match (case-sensitive).
    static func entry(for headword: String) -> LexiconEntry? {
        entries.first { $0.headword == headword }
    }

    /// All headwords as an array — used by the identifier tagger.
    static var allHeadwords: [String] {
        entries.map(\.headword)
    }
}

struct LexiconEntry: Identifiable, Hashable {
    var id: String { headword }
    let headword: String
    let definition: String
    let swiftExample: String
    let related: [String]
    let sources: [SourceLink]

    struct SourceLink: Hashable {
        let title: String
        let url: URL
    }
}
