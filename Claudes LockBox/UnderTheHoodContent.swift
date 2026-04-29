//
//  UnderTheHoodContent.swift
//  LockBox by Claude
//
//  Created by Michael Fluharty on 4/27/26.
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Hand-authored mirror of every Swift file's UTH callout block plus
//  a representative source excerpt. The "Open on GitHub" tap on each
//  detail sheet links to the live source — that's the canonical
//  reference. When you change a file in the app, also update the
//  matching entry here.
//  ────────────────────────────────────────────────────────────────
//

import Foundation

enum UnderTheHoodContent {
    static let repoSourceBase = "https://github.com/fluhartyml/Claudes-Xcode-26-Swift-Bible/blob/main/Claudes%20LockBox/Claudes%20LockBox/"

    static let entries: [FileEntry] = [

        FileEntry(
            filename: "Claudes_LockBoxApp.swift",
            purpose: "App entry — schema + ModelContainer for the vault.",
            callout: """
                The app declares a SwiftData Schema with the two persistent models (Folder + VaultItem) and a ModelConfiguration that is NOT in-memory only — the vault has to survive launches. The container is initialized once at App startup and injected into every view via .modelContainer. The fatalError on init failure is intentional: a vault app that can't open its store has nothing useful to do, so failing fast is the honest move. The window group hosts LockScreenView, not ContentView — authentication is the front door.
                """,
            source: Sources.appEntry
        ),

        FileEntry(
            filename: "LockScreenView.swift",
            purpose: "Face ID / device passcode gate before the vault.",
            callout: """
                LocalAuthentication's LAContext is the single authority. We try .deviceOwnerAuthenticationWithBiometrics first (Face ID / Touch ID), fall back to .deviceOwnerAuthentication (device passcode) when biometrics are unavailable, and unlock directly only when neither is configured (Simulator). The view re-locks on .background scene phase changes — leaving the app even briefly returns the vault to its locked state. No PIN is stored; the OS owns authentication entirely. That's the right design for a personal-data vault: never reinvent secrets.
                """,
            source: Sources.lockScreenView
        ),

        FileEntry(
            filename: "ContentView.swift",
            purpose: "TabView root + NavigationSplitView for the vault.",
            callout: """
                Two tabs: Vault (the actual app) and Under the Hood (this view's parent). The Vault tab uses NavigationSplitView with three columns — sidebar (folders), content (item list for the selected folder), detail (item detail for the selected item) — which gives iPad and Mac a real app-shaped layout while iPhone collapses to push-pop. ContentUnavailableView fills the empty content/detail panes when nothing's selected, which Apple's HIG calls for. seedDefaultFolders() runs on first appear and inserts Cards / Codes / Photos / Notes so the app is useful out of the box.
                """,
            source: Sources.contentView
        ),

        FileEntry(
            filename: "SidebarView.swift",
            purpose: "Folder list with item-count badges + drag support.",
            callout: """
                The sidebar reads folders via the parent's @Query and renders each as a Label with name + item count. The .draggable modifier on each row lets the user reorder folders by drag — iPad's natural gesture for managing lists. .onDelete handles swipe-to-delete; SwiftData cascade-delete on the @Relationship handles cleaning up the folder's VaultItems automatically. The toolbar's Add Folder button flips a binding to present AddFolderView; keeping presentation state in the parent makes the sidebar a pure rendering surface.
                """,
            source: Sources.sidebarView
        ),

        FileEntry(
            filename: "ItemListView.swift",
            purpose: "Items in a folder — list, search, add via scanner / camera / picker.",
            callout: """
                @Query is not used directly here — items come from the bound Folder's @Relationship array, sorted by dateModified descending so the most recent edit floats up. Search filters by title or notes via localizedCaseInsensitiveContains. The toolbar's add button branches on folder name: Cards opens DocumentScannerView (VisionKit four-corner scan), Photos opens PhotosPicker, everything else opens AddItemView for a manual entry. That branching is deliberate — different vault-content kinds want different capture flows; one universal "Add" button papers over real differences.
                """,
            source: Sources.itemListView
        ),

        FileEntry(
            filename: "ItemDetailView.swift",
            purpose: "One item's full detail — fields + images + share + delete.",
            callout: """
                The single largest file — every per-item interaction lives here. @Bindable on the VaultItem makes title/notes/PIN editable inline and SwiftData autosaves between runloop ticks. Image management uses LazyVGrid with tap-to-fullscreen via ImageViewerView. The toolbar holds Share (presents ShareSheetView with title + PIN + notes + images) and Delete (with confirmation alert) — destructive actions stay behind a confirmation step. Each text field uses .system(size: 18) for readability, matching the 18pt iPad-readability standard.
                """,
            source: Sources.itemDetailView
        ),

        FileEntry(
            filename: "AddFolderView.swift",
            purpose: "New folder — name + SF Symbol icon picker.",
            callout: """
                A focused two-section form: a single TextField for name, and a 16-icon LazyVGrid for picking a folder icon from a curated SF Symbols list. The grid is .adaptive(minimum: 50) so it reflows on different widths. The Save button inserts a new Folder with sortOrder = existing count, putting it at the end. Naming defaults to "Untitled" if blank — the app prefers a saved object over an error message, the user can rename later.
                """,
            source: Sources.addFolderView
        ),

        FileEntry(
            filename: "AddItemView.swift",
            purpose: "New manual item — title, notes, PIN, photos.",
            callout: """
                The non-scan, non-card flow for adding to any folder. Form sections for title, notes, PIN (with optional reveal toggle), and an image collection that supports both PhotosPicker (library) and CameraCaptureView (live capture). The PIN is stored as plaintext String on the SwiftData model — the threat model is "device-loss with biometric lock," not "compromised storage at rest"; iOS already encrypts the SwiftData store under the user's passcode key. Adding an extra encryption layer would be theater.
                """,
            source: Sources.addItemView
        ),

        FileEntry(
            filename: "ImageViewerView.swift",
            purpose: "Full-screen image viewer — pinch + drag + share.",
            callout: """
                Pinch-to-zoom via MagnificationGesture (with snap-back to 1.0 if released below scale 1), drag-to-pan via DragGesture, and a share button that opens ShareSheetView with just this image. Two @State pairs (scale/lastScale, offset/lastOffset) implement the standard "store the value at gesture-end so the next gesture continues from there" pattern. Below scale 1.0, the view animates back to fit — relieves the user of having to fix overzoomed-out gestures by hand.
                """,
            source: Sources.imageViewerView
        ),

        FileEntry(
            filename: "CameraCaptureView.swift",
            purpose: "UIImagePickerController wrapper for live camera capture.",
            callout: """
                SwiftUI doesn't ship a native camera-capture view yet, so we wrap UIImagePickerController via UIViewControllerRepresentable. The picker's sourceType is .camera; the Coordinator implements UIImagePickerControllerDelegate to pull the JPEG-compressed Data out of info[.originalImage] and hand it to the parent via the onCapture closure. Compression quality is 0.8 — a sensible balance between file size and photo quality for vault items.
                """,
            source: Sources.cameraCaptureView
        ),

        FileEntry(
            filename: "DocumentScannerView.swift",
            purpose: "VisionKit document scanner — four-corner detection.",
            callout: """
                VNDocumentCameraViewController is Apple's built-in document scanner — automatic four-corner detection, perspective correction, and multi-page capture in one screen. We wrap it the same way as CameraCaptureView. The Coordinator's didFinishWith handler walks scan.pageCount and pulls each page's UIImage, JPEG-compresses it, and hands the array of Data back to the caller. Used exclusively for the Cards folder, where multi-page scans of identification documents are the natural input.
                """,
            source: Sources.documentScannerView
        ),

        FileEntry(
            filename: "ShareSheetView.swift",
            purpose: "UIActivityViewController for sharing item content.",
            callout: """
                The system share sheet, wrapped for SwiftUI. Builds an array of activity items: a text summary (title, optional PIN, optional notes) followed by every UIImage decoded from the item's imageData. UIActivityViewController routes the bundle to whichever target the user picks (Notes, Messages, Mail, AirDrop, etc.) — Apple did the heavy lifting of formatting per target. iOS-only via #if os(iOS) since UIActivityViewController doesn't exist on macOS.
                """,
            source: Sources.shareSheetView
        ),

        FileEntry(
            filename: "Folder.swift",
            purpose: "SwiftData @Model — folder with cascade-delete relationship to items.",
            callout: """
                A persistable Swift class with name, iconName (SF Symbol), dateCreated, sortOrder, and a one-to-many relationship to VaultItem. The @Relationship(deleteRule: .cascade, inverse: \\VaultItem.folder) makes deleting a folder also delete every item in it — the right semantic for a vault organization scheme. Without the inverse: parameter SwiftData wouldn't know the two properties describe the same relationship.
                """,
            source: Sources.folder
        ),

        FileEntry(
            filename: "VaultItem.swift",
            purpose: "SwiftData @Model — the unit of vault storage.",
            callout: """
                Each VaultItem has title, notes, pin, dateCreated, dateModified, an array of imageData, and an optional Folder reference. The @Attribute(.externalStorage) on imageData tells SwiftData to keep image bytes outside the SQLite store (in separate files in the store's directory) — a single 5MB photo blob inside a SQLite row would trash query performance on any folder containing more than a handful of items. External storage is the right default for any binary content larger than a few KB.
                """,
            source: Sources.vaultItem
        ),

        FileEntry(
            filename: "AboutView.swift",
            purpose: "About sheet — icon, version, credits, feedback button.",
            callout: """
                Standard about page. The app icon is read at runtime from Bundle.main.infoDictionary's CFBundleIcons → CFBundlePrimaryIcon → CFBundleIconFiles array — that approach uses whatever icon is currently set in the asset catalog, so a future icon swap doesn't require touching this view. The Send Feedback button presents FeedbackView as a sheet for bug reports and feature requests.
                """,
            source: Sources.aboutView
        ),

        FileEntry(
            filename: "FeedbackView.swift",
            purpose: "Bug report / feature request mail composer.",
            callout: """
                A type-segmented picker (Bug Report / Feature Request) plus a free-text body, sent via MFMailComposeViewController on iOS with auto-attached device info (model, OS version, app version, locale). Falls back to a mailto: URL when MFMailCompose isn't available — keeps feedback flowing even when the user has no Mail account configured. Subject line embeds the type and version so triage is fast.
                """,
            source: Sources.feedbackView
        ),

        FileEntry(
            filename: "UnderTheHoodView.swift",
            purpose: "This view — file list + per-file callouts + Lexicon Quick-Define.",
            callout: """
                The Under the Hood feature surfaces the entire codebase inside the app: a list of every Swift file with its filename, one-line purpose, and a tap-to-expand sheet showing this callout block, the source, and an Open-on-GitHub link. The Lexicon Quick-Define layer tags any Swift identifier in the source block that has a Lexicon entry — tap WKWebView, NavigationStack, @Model, @Query etc. for an inline definition.
                """,
            source: Sources.underTheHoodView
        ),

        FileEntry(
            filename: "UnderTheHoodContent.swift",
            purpose: "Hand-authored callout & source mirror.",
            callout: """
                Hand-authored mirror of every Swift file's UTH callout block plus a representative source excerpt. The Open on GitHub link on each detail sheet keeps readers tied to the live source even when this constant drifts. When you change a file in the app, update the matching entry here.
                """,
            source: Sources.underTheHoodContentMirror
        )
    ]

    static func entry(for filename: String) -> FileEntry? {
        entries.first { $0.filename == filename }
    }

    struct FileEntry: Identifiable {
        let id = UUID()
        let filename: String
        let purpose: String
        let callout: String
        let source: String

        var githubURL: URL? {
            let encoded = filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? filename
            return URL(string: repoSourceBase + encoded)
        }
    }
}

// MARK: - Source mirrors
//
// Abbreviated representative excerpts. Full source available via the
// Open on GitHub button on each detail sheet — that's the canonical
// reference; this file's strings are reading-aid snippets only.

private enum Sources {

    static let appEntry = #"""
import SwiftUI
import SwiftData

@main
struct Claudes_LockBoxApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Folder.self, VaultItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup { LockScreenView() }
            .modelContainer(sharedModelContainer)
    }
}
"""#

    static let lockScreenView = #"""
import SwiftUI
import LocalAuthentication

struct LockScreenView: View {
    @State private var isUnlocked = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        if isUnlocked {
            ContentView()
                .onChange(of: scenePhase) { _, new in
                    if new == .background { isUnlocked = false }
                }
        } else {
            VStack {
                // ... lock-screen UI: icon, title, "Tap to unlock" hint,
                // "Unlock with Face ID" button calling authenticate()
            }
            .onAppear { authenticate() }
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Unlock your vault") { ok, _ in
                if ok { isUnlocked = true }
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // device passcode fallback
        } else {
            // Simulator / no auth available
            isUnlocked = true
        }
    }
}
"""#

    static let contentView = #"""
import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            VaultTabView().tabItem { Label("Vault", systemImage: "lock.shield.fill") }
            UnderTheHoodView().tabItem { Label("Under the Hood", systemImage: "wrench.and.screwdriver") }
        }
    }
}

struct VaultTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.sortOrder) private var folders: [Folder]
    @State private var selectedFolder: Folder?
    @State private var selectedItem: VaultItem?
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            SidebarView(folders: folders, selectedFolder: $selectedFolder, ...)
        } content: {
            if let folder = selectedFolder {
                ItemListView(folder: folder, selectedItem: $selectedItem, ...)
            } else {
                ContentUnavailableView("Select a Folder", systemImage: "folder", ...)
            }
        } detail: {
            if let item = selectedItem { ItemDetailView(item: item) }
            else { ContentUnavailableView("Select an Item", ...) }
        }
        .searchable(text: $searchText, prompt: "Search vault")
        .onAppear { seedDefaultFolders() }
    }
}
"""#

    static let sidebarView = #"""
import SwiftUI
import SwiftData

struct SidebarView: View {
    let folders: [Folder]
    @Binding var selectedFolder: Folder?
    @Binding var showAddFolder: Bool
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List(selection: $selectedFolder) {
            ForEach(folders) { folder in
                Label {
                    HStack {
                        Text(folder.name)
                        Spacer()
                        Text("\(folder.items.count)").foregroundStyle(.secondary)
                    }
                } icon: { Image(systemName: folder.iconName).foregroundStyle(.tint) }
                .tag(folder)
                .draggable(folder.name)
            }
            .onDelete(perform: deleteFolders)
        }
        .navigationTitle("LockBox")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddFolder = true } label: {
                    Label("Add Folder", systemImage: "folder.badge.plus")
                }
            }
        }
    }

    private func deleteFolders(at offsets: IndexSet) {
        for i in offsets { modelContext.delete(folders[i]) }
    }
}
"""#

    static let itemListView = #"""
import SwiftUI
import SwiftData
import PhotosUI

struct ItemListView: View {
    let folder: Folder
    @Binding var selectedItem: VaultItem?
    @Binding var searchText: String
    @Environment(\.modelContext) private var modelContext
    // ... showAddItem / showScanner / showPhotoPicker state

    var filteredItems: [VaultItem] {
        let items = folder.items.sorted { $0.dateModified > $1.dateModified }
        if searchText.isEmpty { return items }
        return items.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    var isCardFolder: Bool { folder.name == "Cards" }
    var isPhotoFolder: Bool { folder.name == "Photos" }

    var body: some View {
        List(selection: $selectedItem) {
            ForEach(filteredItems) { item in itemRow(item).tag(item) }
                .onDelete(perform: deleteItems)
        }
        .navigationTitle(folder.name)
        .toolbar {
            // Add button branches on folder kind: Cards => DocumentScannerView,
            // Photos => PhotosPicker, others => AddItemView
        }
    }
}
"""#

    static let itemDetailView = #"""
import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Bindable var item: VaultItem
    @Environment(\.modelContext) private var modelContext
    @State private var showingShareSheet = false
    @State private var showingDeleteAlert = false
    @State private var revealPIN = false
    @State private var fullScreenImageData: Data?
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                TextField("Title", text: $item.title)
                    .font(.system(size: 24, weight: .semibold))

                // Notes editor, PIN field with reveal toggle, image grid,
                // tap an image to open ImageViewerView fullscreen
                // Camera + delete-this-image buttons per image
            }
            .padding()
        }
        .navigationTitle(item.title)
        .toolbar {
            // Share => ShareSheetView, Delete => confirmation alert
        }
        // Sheets for ShareSheetView, CameraCaptureView, ImageViewerView
        // Alert for delete confirmation
    }
}
"""#

    static let addFolderView = #"""
import SwiftUI
import SwiftData

struct AddFolderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Folder.sortOrder) private var existingFolders: [Folder]
    @State private var name = ""
    @State private var selectedIcon = "folder.fill"

    let iconOptions = [
        "folder.fill", "creditcard.fill", "lock.fill",
        "person.crop.circle.fill", "photo.fill", "note.text",
        // ...curated SF Symbol list
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Folder name", text: $name)
                }
                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button { selectedIcon = icon } label: {
                                Image(systemName: icon)
                                    .background(selectedIcon == icon ? .blue : .clear)
                            }
                        }
                    }
                }
            }
            .toolbar {
                // Cancel + Save (creates Folder, inserts into modelContext)
            }
        }
    }
}
"""#

    static let addItemView = #"""
import SwiftUI
import SwiftData
import PhotosUI

struct AddItemView: View {
    let folder: Folder
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var notes = ""
    @State private var pin = ""
    @State private var revealPIN = false
    @State private var imageData: [Data] = []
    @State private var photosPickerItems: [PhotosPickerItem] = []
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") { TextField("Title", text: $title) }
                Section("PIN / Code") {
                    if revealPIN { TextField("PIN", text: $pin) }
                    else { SecureField("PIN", text: $pin) }
                    Toggle("Reveal", isOn: $revealPIN)
                }
                Section("Notes") { TextEditor(text: $notes).frame(minHeight: 100) }
                Section("Photos") {
                    // PhotosPicker + CameraCaptureView buttons
                    // Image grid for currently-attached photos
                }
            }
            .toolbar {
                // Cancel + Save (creates VaultItem, inserts to modelContext)
            }
        }
    }
}
"""#

    static let imageViewerView = #"""
import SwiftUI

struct ImageViewerView: View {
    let imageData: Data
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        NavigationStack {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { scale = lastScale * $0 }
                            .onEnded { _ in
                                lastScale = scale
                                if scale < 1.0 { withAnimation { reset() } }
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { offset = CGSize(width: lastOffset.width + $0.translation.width,
                                                          height: lastOffset.height + $0.translation.height) }
                            .onEnded { _ in lastOffset = offset }
                    )
                    .toolbar {
                        // Share button => ShareSheetView with this image only
                    }
            }
        }
    }
}
"""#

    static let cameraCaptureView = #"""
#if os(iOS)
import SwiftUI
import UIKit

struct CameraCaptureView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    var onCapture: (Data) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss, onCapture: onCapture)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let dismiss: DismissAction
        let onCapture: (Data) -> Void

        init(dismiss: DismissAction, onCapture: @escaping (Data) -> Void) {
            self.dismiss = dismiss
            self.onCapture = onCapture
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWith info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.8) {
                onCapture(data)
            }
            dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { dismiss() }
    }
}
#endif
"""#

    static let documentScannerView = #"""
#if os(iOS)
import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    var onScan: ([Data]) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss, onScan: onScan)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let dismiss: DismissAction
        let onScan: ([Data]) -> Void
        init(dismiss: DismissAction, onScan: @escaping ([Data]) -> Void) {
            self.dismiss = dismiss
            self.onScan = onScan
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            var pages: [Data] = []
            for i in 0..<scan.pageCount {
                if let data = scan.imageOfPage(at: i).jpegData(compressionQuality: 0.8) {
                    pages.append(data)
                }
            }
            onScan(pages)
            dismiss()
        }
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) { dismiss() }
    }
}
#endif
"""#

    static let shareSheetView = #"""
#if os(iOS)
import SwiftUI
import UIKit

struct ShareSheetView: UIViewControllerRepresentable {
    let item: VaultItem

    func makeUIViewController(context: Context) -> UIActivityViewController {
        var shareItems: [Any] = []

        var text = item.title
        if !item.pin.isEmpty { text += "\nCode: \(item.pin)" }
        if !item.notes.isEmpty { text += "\n\(item.notes)" }
        shareItems.append(text)

        for data in item.imageData {
            if let image = UIImage(data: data) { shareItems.append(image) }
        }

        return UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
"""#

    static let folder = #"""
import Foundation
import SwiftData

@Model
final class Folder {
    var name: String
    var iconName: String
    var dateCreated: Date
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \VaultItem.folder)
    var items: [VaultItem] = []

    init(name: String, iconName: String = "folder.fill", sortOrder: Int = 0) {
        self.name = name
        self.iconName = iconName
        self.dateCreated = Date()
        self.sortOrder = sortOrder
    }
}
"""#

    static let vaultItem = #"""
import Foundation
import SwiftData

@Model
final class VaultItem {
    var title: String
    var notes: String
    var pin: String
    var dateCreated: Date
    var dateModified: Date

    @Attribute(.externalStorage)
    var imageData: [Data] = []

    var folder: Folder?

    init(title: String, notes: String = "", pin: String = "", folder: Folder? = nil) {
        self.title = title
        self.notes = notes
        self.pin = pin
        self.dateCreated = Date()
        self.dateModified = Date()
        self.folder = folder
    }
}
"""#

    static let aboutView = #"""
import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFeedback = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // App icon image (read from CFBundleIcons at runtime)
                    Text("LockBox by Claude").font(.system(size: 24, weight: .bold))
                    Text("Version 1.0").foregroundStyle(.secondary)
                    Text("A personal vault for cards, codes, photos, and notes.")
                    // Send Feedback button => FeedbackView sheet
                }
            }
            .navigationTitle("About")
            .toolbar { /* Done */ }
        }
    }
}
"""#

    static let feedbackView = #"""
import SwiftUI
#if canImport(UIKit)
import MessageUI
#endif

struct FeedbackView: View {
    @State private var feedbackType = "Bug Report"
    @State private var feedbackText = ""

    var body: some View {
        Form {
            Picker("Type", selection: $feedbackType) {
                Text("Bug Report").tag("Bug Report")
                Text("Feature Request").tag("Feature Request")
            }.pickerStyle(.segmented)

            Section("Your Feedback") { TextEditor(text: $feedbackText) }

            Button("Send") {
                // MFMailComposeViewController on iOS,
                // mailto: URL fallback when Mail isn't configured.
                // Auto-attaches device + app version + locale info.
            }
        }
    }
}
"""#

    static let underTheHoodView = #"""
import SwiftUI

struct UnderTheHoodView: View {
    @State private var selected: UnderTheHoodContent.FileEntry?

    var body: some View {
        NavigationStack {
            List {
                Section { /* footnote intro */ }
                Section("Source Files") {
                    ForEach(UnderTheHoodContent.entries) { entry in
                        Button { selected = entry } label: { /* row label */ }
                    }
                }
            }
            .navigationTitle("Under the Hood")
            .sheet(item: $selected) { entry in FileDetailSheet(entry: entry) }
        }
    }
}
"""#

    static let underTheHoodContentMirror = #"""
import Foundation

enum UnderTheHoodContent {
    static let repoSourceBase = "https://github.com/fluhartyml/Claudes-Xcode-26-Swift-Bible/blob/main/Claudes%20LockBox/Claudes%20LockBox/"
    static let entries: [FileEntry] = [
        // ...one FileEntry per Swift file in the app; see full source.
    ]

    struct FileEntry: Identifiable {
        let id = UUID()
        let filename: String
        let purpose: String
        let callout: String
        let source: String
        var githubURL: URL? { /* repoSourceBase + filename */ }
    }
}
"""#
}
