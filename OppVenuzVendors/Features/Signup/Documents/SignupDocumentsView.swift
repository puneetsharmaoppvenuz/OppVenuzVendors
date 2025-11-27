//
//  SignupDocumentsView.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 18/11/25.
// Created by oppvenuz1 on 18/11/25.
//

import SwiftUI
import QuickLook

struct SignupDocumentsView: View {
    
    @StateObject private var viewModel = SignupDocumentsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // For picker flow: section → choose source → actual picker
    @State private var currentPickerSource: SignupDocumentsViewModel.PickerSource?
    @State private var currentSectionID: UUID?
    
    var onContinue: (() -> Void)?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header             // ✅ compact header + 3/3 strip
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerIllustration
                        companySelector
                        businessDocumentSelector
                        businessUploadedList
                        mandatoryDocumentsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                
                continueButton
            }
            .background(Color(.systemBackground))
            
            if viewModel.isLoading {
                loaderOverlay
            }
        }
        // Sheet 1 – our custom "Browse" options (Camera / Photos / Files)
        .sheet(item: $viewModel.activePickerTarget) { target in
            PickerSourceSheet { source in
                currentSectionID = target.sectionID
                currentPickerSource = source
                viewModel.activePickerTarget = nil
            }
        }
        // Sheet 2 – actual system pickers (camera, photo library, files)
        .sheet(item: $currentPickerSource) { source in
            switch source {
            case .camera:
                ImagePickerView(source: .camera) { image in
                    if let id = currentSectionID {
                        viewModel.didPickImage(image, for: id)
                    }
                    currentSectionID = nil
                    currentPickerSource = nil
                }
                
            case .photoLibrary:
                ImagePickerView(source: .photoLibrary) { image in
                    if let id = currentSectionID {
                        viewModel.didPickImage(image, for: id)
                    }
                    currentSectionID = nil
                    currentPickerSource = nil
                }
                
            case .files:
                DocumentPickerView { url in
                    if let id = currentSectionID {
                        viewModel.didPickFile(url, for: id)
                    }
                    currentSectionID = nil
                    currentPickerSource = nil
                }
            }
        }
        
        // Sheet 3 – full-screen preview with pinch-zoom
        .sheet(item: $viewModel.activePreviewItem) { item in
            FullScreenZoomImageView(item: item) {
                viewModel.activePreviewItem = nil
            }
        }
    }
    
    // MARK: - Header (gradient + 3/3 strip combined)
    private var header: some View {
        VStack(spacing: 0) {
            // Gradient bar with back arrow
            ZStack(alignment: .leading) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.22, green: 0.34, blue: 0.96),
                        Color(red: 0.52, green: 0.14, blue: 0.92)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 40) // tighter header
                .ignoresSafeArea(edges: .top)
                
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                }
            }
            
            // 3/3 + three bars just under the gradient
            VStack(alignment: .leading, spacing: 6) {
                Text("3/3")
                    .font(.system(size: 12, weight: .semibold))
                
                HStack(spacing: 10) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors:
                                                        index <= 2
                                                       ? [Color.blue, Color.purple]
                                                       : [Color(.systemGray4), Color(.systemGray4)]
                                                      ),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 4)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 0) // almost no gap
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Illustration + Title
    
    private var headerIllustration: some View {
        VStack(spacing: 16) {
            Image("signup4")
                .resizable()
                .scaledToFit()
                .frame(height: 180)
            
            Text("Submit Your Business Documents")
                .font(.system(size: 18, weight: .semibold))
            
            Text("Please upload the required documents to complete your registration.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }
    
    // MARK: - Company Selector
    
    private var companySelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select type of company")
                .font(.system(size: 14, weight: .semibold))
            
            Menu {
                ForEach(viewModel.companyOptions) { opt in
                    Button(opt.name) { viewModel.selectCompany(opt) }
                }
            } label: {
                selectorLabel(text: viewModel.selectedCompany?.name ?? "Private Limited")
            }
        }
    }
    
    // MARK: - Document Selector
    
    private var businessDocumentSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Select Document")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            
            Text("*Please upload at least 3 Documents")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            Menu {
                ForEach(viewModel.availableDocumentsForSelectedCompany) { doc in
                    Button(doc.name) { viewModel.addBusinessSection(for: doc) }
                }
            } label: {
                selectorLabel(text: "Select Documents")
            }
            .disabled(viewModel.availableDocumentsForSelectedCompany.isEmpty)
        }
    }
    
    // MARK: - Business Uploaded List
    
    private var businessUploadedList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.businessSections) { section in
                businessRow(section)
            }
        }
    }
    
    private func businessRow(_ section: SignupDocumentsViewModel.DocumentSection) -> some View {
        VStack {
            HStack(alignment: .top, spacing: 16) {   // ✅ top alignment
                
                thumbnail(for: section)
                    .frame(width: 56, height: 56)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.definition.name)
                        .font(.system(size: 13, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let size = section.readableSize {
                        Text(size)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    if section.attachment != nil {
                        Button {
                            viewModel.preview(section)
                        } label: {
                            HStack(spacing: 6) {
                                gradientEye
                                    .frame(width: 22, height: 22)
                                Text("View")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)   // ✅ hold text block at top
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Button {
                        viewModel.openPicker(for: section)
                    } label: {
                        smallBrowseButton(title: section.attachment == nil ? "Browse" : "Change")
                    }
                    
                    Button {
                        viewModel.removeBusinessSection(section)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 1)
        )
    }
    
    // MARK: - Mandatory Docs
    
    private var mandatoryDocumentsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Mandatory Documents")
                .font(.system(size: 14, weight: .semibold))
            
            ForEach(viewModel.mandatorySections) { sec in
                VStack(spacing: 10) {
                    HStack {
                        let isRequired = sec.definition.isRequired
                        Text(isRequired ? sec.definition.name : "\(sec.definition.name) (Optional)")
                            .font(.system(size: 13, weight: .semibold))
                        
                        Spacer()
                        
                        Button {
                            viewModel.openPicker(for: sec)
                        } label: {
                            smallBrowseButton(title: sec.attachment == nil ? "Browse" : "Change")
                        }
                    }
                    
                    if sec.attachment != nil {
                        mandatoryAttachmentRow(sec)
                    }
                    
                    Divider()
                }
            }
        }
        .padding(.top, 12)
    }
    
    private func mandatoryAttachmentRow(_ sec: SignupDocumentsViewModel.DocumentSection) -> some View {
        HStack(alignment: .top, spacing: 16) {         // ✅ top alignment here too
            thumbnail(for: sec)
                .frame(width: 56, height: 56)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sec.attachment?.filename(fallback: sec.definition.name) ?? "")
                    .font(.system(size: 12, weight: .semibold))
                Text(sec.readableSize ?? "")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Button { viewModel.preview(sec) } label: {
                    HStack(spacing: 6) {
                        gradientEye
                            .frame(width: 22, height: 22)
                        Text("View")
                            .font(.system(size: 11, weight: .semibold))
                    }
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            Spacer()
            
            Button {
                viewModel.clearMandatoryAttachment(sec.id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Thumbnail
    
    @ViewBuilder
    private func thumbnail(for section: SignupDocumentsViewModel.DocumentSection) -> some View {
        if let att = section.attachment {
            switch att {
            case .image(let ui):
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .cornerRadius(5)
                
            case .file(let url):
                VStack(spacing: 4) {
                    Image(systemName: "doc.text.image")
                        .font(.system(size: 22))
                    Text(url.lastPathComponent)
                        .font(.system(size: 9))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
        } else {
            VStack(spacing: 4) {
                Image(systemName: "doc.fill.badge.plus")
                    .font(.system(size: 22))
                    .foregroundColor(.secondary)
                Text("No file")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - UI Helpers
    
    private func selectorLabel(text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(text.contains("Select") ? .secondary : .primary)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }
    
    private func smallBrowseButton(title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
    }
    
    private var gradientEye: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: "eye.fill")
                .font(.system(size: 12))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Continue
    
    private var continueButton: some View {
        Button {
            viewModel.handleContinueTapped {
                onContinue?()
            }
        } label: {
            Text("Continue")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: viewModel.isContinueEnabled ?
                                           [Color.blue, Color.purple] :
                                            [Color.gray, Color.gray]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .disabled(!viewModel.isContinueEnabled)
    }
    
    // MARK: - Loader
    
    private var loaderOverlay: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.4)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
        }
    }
}

// MARK: - PickerSource Identifiable (for .sheet(item:))

extension SignupDocumentsViewModel.PickerSource: Identifiable {
    var id: Int { hashValue }
}
