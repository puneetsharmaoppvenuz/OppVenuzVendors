//
//  FullScreenZoomImageView.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 21/11/25.
//

import SwiftUI
import UIKit
import QuickLook

/// A full-screen viewer with pinch-zoom, drag, double-tap to zoom.
/// Works for `.image` and `.file` (PDF, Doc, etc. via QLPreview).
struct FullScreenZoomImageView: View {

    let item: SignupDocumentsViewModel.PreviewItem
    let onClose: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    @State private var doubleTapZoomed = false

    var body: some View {
        ZStack(alignment: .topTrailing) {

            Color.black
                .ignoresSafeArea()

            switch item.attachment {

            case .image(let uiImage):
                zoomableImage(uiImage)

            case .file(let url):
                FullScreenFilePreview(url: url)
            }

            closeButton
        }
    }

    // MARK: - Zoomable Image

    private func zoomableImage(_ image: UIImage) -> some View {
        GeometryReader { geo in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = lastScale * value
                        }
                        .onEnded { _ in
                            lastScale = scale
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if doubleTapZoomed {
                            // reset to original
                            scale = 1.0
                            lastScale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.4
                            lastScale = 2.4
                        }
                        doubleTapZoomed.toggle()
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 34, height: 34)
                .foregroundColor(.white)
                .shadow(radius: 4)
                .padding()
        }
    }
}

// MARK: - QLPreview For Files

struct FullScreenFilePreview: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let vc = QLPreviewController()
        vc.dataSource = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController,
                               previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}
