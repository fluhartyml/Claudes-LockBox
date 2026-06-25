//
//  ContinuityCameraScanner.swift
//  Memory Aid Lockbox
//
//  macOS-only. Brings Continuity Camera ("Import from iPhone or iPad →
//  Scan Documents / Take Photo") into the app. The iOS document scanner
//  (VNDocumentCameraViewController) does not exist on macOS; on the Mac the
//  scan is delivered through the Services / responder-chain mechanism:
//  an NSView advertises that it accepts image/PDF data, the system inserts
//  the Continuity Camera menu items, and the captured result is handed back
//  via NSServicesMenuRequestor.readSelection(from:).
//
//  A "Scan Documents" capture returns a multi-page PDF; we render each page
//  to a PNG so the result matches how VaultItem already stores images
//  (imageData: [Data]). A photo-library fallback is offered in the same menu
//  so the control is never a dead end if no device is available.
//

#if os(macOS)
import SwiftUI
import AppKit
import PDFKit
import UniformTypeIdentifiers

/// Hidden helper view that, when its `trigger` changes, pops a menu containing
/// the system's Continuity Camera items plus an "Import Photo…" fallback.
struct ContinuityCameraButton: NSViewRepresentable {
    /// Increment to request the menu.
    var trigger: Int
    /// Called with one PNG per scanned/captured page.
    var onScan: ([Data]) -> Void
    /// Fallback when the user has no nearby device.
    var onImportPhoto: () -> Void

    func makeNSView(context: Context) -> ContinuityScanView {
        let view = ContinuityScanView()
        view.onScan = onScan
        view.onImportPhoto = onImportPhoto
        context.coordinator.view = view
        return view
    }

    func updateNSView(_ nsView: ContinuityScanView, context: Context) {
        nsView.onScan = onScan
        nsView.onImportPhoto = onImportPhoto
        if trigger != context.coordinator.lastTrigger {
            context.coordinator.lastTrigger = trigger
            // Defer so the view is in the window's responder chain.
            DispatchQueue.main.async { nsView.presentScanMenu() }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var lastTrigger = 0
        weak var view: ContinuityScanView?
    }
}

final class ContinuityScanView: NSView, NSServicesMenuRequestor {
    var onScan: (([Data]) -> Void)?
    var onImportPhoto: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }

    private static let pdfType = NSPasteboard.PasteboardType(UTType.pdf.identifier)

    // MARK: Services / Continuity Camera plumbing

    // Tell the Services architecture we can receive an image or PDF (sendType nil = we
    // only receive). Returning self is what makes macOS insert the Continuity Camera items.
    override func validRequestor(forSendType sendType: NSPasteboard.PasteboardType?,
                                 returnType: NSPasteboard.PasteboardType?) -> Any? {
        if sendType == nil,
           let returnType,
           returnType == Self.pdfType || returnType == .tiff || returnType == .png {
            return self
        }
        return super.validRequestor(forSendType: sendType, returnType: returnType)
    }

    // Receives the captured document/photo.
    func readSelection(from pasteboard: NSPasteboard) -> Bool {
        var pages: [Data] = []

        if let pdfData = pasteboard.data(forType: Self.pdfType),
           let pdf = PDFDocument(data: pdfData) {
            for index in 0..<pdf.pageCount {
                if let page = pdf.page(at: index), let png = Self.png(from: page) {
                    pages.append(png)
                }
            }
        } else if let imageData = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .tiff),
                  let image = NSImage(data: imageData),
                  let png = Self.png(from: image) {
            pages.append(png)
        }

        guard !pages.isEmpty else { return false }
        onScan?(pages)
        return true
    }

    // Required by NSServicesMenuRequestor; we never provide data outward.
    func writeSelection(to pasteboard: NSPasteboard,
                        types: [NSPasteboard.PasteboardType]) -> Bool {
        false
    }

    // MARK: Menu

    func presentScanMenu() {
        window?.makeFirstResponder(self)
        let menu = NSMenu()

        // Our guaranteed fallback so the menu is never empty.
        let importItem = NSMenuItem(title: "Import Photo…",
                                    action: #selector(importPhotoTapped),
                                    keyEquivalent: "")
        importItem.target = self
        menu.addItem(importItem)

        // The Services architecture inserts "Import from iPhone or iPad"
        // (Take Photo / Scan Documents) into this menu when it is displayed
        // while self is the first responder and accepts image/PDF types.
        let origin = NSPoint(x: 0, y: bounds.height)
        menu.popUp(positioning: nil, at: origin, in: self)
    }

    @objc private func importPhotoTapped() {
        onImportPhoto?()
    }

    // MARK: Rendering helpers

    private static func png(from page: PDFPage) -> Data? {
        let bounds = page.bounds(for: .mediaBox)
        guard bounds.width > 0, bounds.height > 0 else { return nil }
        let image = NSImage(size: bounds.size)
        image.lockFocus()
        if let ctx = NSGraphicsContext.current?.cgContext {
            ctx.setFillColor(NSColor.white.cgColor)
            ctx.fill(CGRect(origin: .zero, size: bounds.size))
            page.draw(with: .mediaBox, to: ctx)
        }
        image.unlockFocus()
        return png(from: image)
    }

    private static func png(from image: NSImage) -> Data? {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
    }
}
#endif
