//
//  ContinuityCameraScanner.swift
//  Memory Aid Lockbox
//
//  macOS-only. Brings Continuity Camera ("Import from iPhone or iPad →
//  Scan Documents / Take Photo") into the app. The iOS document scanner
//  (VNDocumentCameraViewController) does not exist on macOS; on the Mac the
//  scan is delivered through the Services / responder-chain mechanism:
//  the button advertises that it accepts image/PDF data, the system inserts
//  the Continuity Camera menu items, and the captured result is handed back
//  via NSServicesMenuRequestor.readSelection(from:).
//
//  A "Scan Documents" capture returns a multi-page PDF; we render each page
//  to a PNG so the result matches how VaultItem already stores images
//  (imageData: [Data]). An "Import Photo…" item is always present so the
//  control is never a dead end.
//

#if os(macOS)
import SwiftUI
import AppKit
import PDFKit
import UniformTypeIdentifiers

/// A toolbar "+" button that, on click, makes itself first responder and shows a
/// menu the system populates with Continuity Camera items.
struct ContinuityCameraButton: NSViewRepresentable {
    var onScan: ([Data]) -> Void
    var onImportPhoto: () -> Void

    func makeNSView(context: Context) -> ContinuityScanButton {
        let button = ContinuityScanButton()
        button.bezelStyle = .texturedRounded
        button.image = NSImage(systemSymbolName: "plus", accessibilityDescription: "Add Item")
        button.imagePosition = .imageOnly
        button.target = button
        button.action = #selector(ContinuityScanButton.showImportMenu)
        button.onScan = onScan
        button.onImportPhoto = onImportPhoto
        return button
    }

    func updateNSView(_ nsView: ContinuityScanButton, context: Context) {
        nsView.onScan = onScan
        nsView.onImportPhoto = onImportPhoto
    }
}

final class ContinuityScanButton: NSButton, NSServicesMenuRequestor {
    var onScan: (([Data]) -> Void)?
    var onImportPhoto: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }

    private static let pdfType = NSPasteboard.PasteboardType(UTType.pdf.identifier)

    @objc func showImportMenu() {
        window?.makeFirstResponder(self)
        let menu = NSMenu()
        let importItem = NSMenuItem(title: "Import Photo…",
                                    action: #selector(importPhotoTapped),
                                    keyEquivalent: "")
        importItem.target = self
        menu.addItem(importItem)
        // The Services architecture inserts "Import from iPhone or iPad"
        // (Take Photo / Scan Documents) when this menu is shown while self is
        // first responder and reports it accepts image/PDF types.
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: bounds.height), in: self)
    }

    @objc private func importPhotoTapped() {
        onImportPhoto?()
    }

    // MARK: Services / Continuity Camera

    override func validRequestor(forSendType sendType: NSPasteboard.PasteboardType?,
                                 returnType: NSPasteboard.PasteboardType?) -> Any? {
        if sendType == nil,
           let returnType,
           returnType == Self.pdfType || returnType == .tiff || returnType == .png {
            return self
        }
        return super.validRequestor(forSendType: sendType, returnType: returnType)
    }

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

    func writeSelection(to pasteboard: NSPasteboard,
                        types: [NSPasteboard.PasteboardType]) -> Bool {
        false
    }

    // MARK: Rendering

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
