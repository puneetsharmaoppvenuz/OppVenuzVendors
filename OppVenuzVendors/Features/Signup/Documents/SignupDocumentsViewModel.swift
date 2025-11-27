//
//  SignupDocumentsViewModel.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 18/11/25.
//

import Foundation
import SwiftUI
import Combine
import UIKit
import UniformTypeIdentifiers

final class SignupDocumentsViewModel: ObservableObject {
    
    // MARK: - Types
    
    enum PickerSource {
        case camera
        case photoLibrary
        case files
    }
    
    struct DocumentDefinition: Identifiable, Hashable {
        let id: Int
        let name: String
        let companyName: String?
        let isRequired: Bool
    }
    
    struct CompanyOption: Identifiable, Hashable {
        let id: Int
        let name: String
        let documents: [DocumentDefinition]
    }
    
    enum DocumentAttachment: Equatable {
        case image(UIImage)
        case file(URL)
        
        static func == (lhs: DocumentAttachment, rhs: DocumentAttachment) -> Bool {
            switch (lhs, rhs) {
            case (.file(let l), .file(let r)):
                return l == r
            case (.image, .image):
                return true
            default:
                return false
            }
        }
    }
    
    struct DocumentSection: Identifiable {
        let id = UUID()
        let definition: DocumentDefinition
        var attachment: DocumentAttachment? = nil
    }
    
    struct PickerTarget: Identifiable {
        let id = UUID()
        let sectionID: UUID
        let source: PickerSource
    }
    
    struct PreviewItem: Identifiable {
        let id = UUID()
        let attachment: DocumentAttachment
        let title: String
    }
    
    // MARK: - Upload DTOs
    struct UploadDocumentDTO: Codable {
        let id: Int
        let phone: String
        let company_type: String
        let document_type: String
        let document_url: String
        let status: String
        
        func toDraftDoc() -> SignupDraft.UploadedDoc {
            SignupDraft.UploadedDoc(
                serverId: id,
                phone: phone,
                companyType: company_type,
                documentType: document_type,
                documentUrl: document_url,
                status: status
            )
        }
    }
    
    
    struct UploadDocumentResponse: Codable {
        let message: String
        let document: UploadDocumentDTO
    }
    
    // MARK: - Published
    
    @Published private(set) var companyOptions: [CompanyOption] = []
    @Published var selectedCompany: CompanyOption?
    
    @Published private(set) var availableDocumentsForSelectedCompany: [DocumentDefinition] = []
    @Published var businessSections: [DocumentSection] = []
    @Published var mandatorySections: [DocumentSection] = []
    
    @Published var activePickerTarget: PickerTarget?
    @Published var activePreviewItem: PreviewItem?
    
    @Published var showGlobalLoader: Bool = false
    @Published private(set) var isContinueEnabled: Bool = false
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        loadBaseAPI()
        setupBindings()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest($businessSections, $mandatorySections)
            .sink { [weak self] _, _ in
                self?.computeContinueState()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Base API
    
    private func loadBaseAPI() {
        guard let data = BaseAPIService.cachedEnvelope()?.data else {
            self.companyOptions = []
            self.mandatorySections = buildMandatorySections()
            return
        }
        
        var companies: [CompanyOption] = []
        
        if let companyDocs = data.company_type_documents {
            for company in companyDocs {
                var mappedDocs: [DocumentDefinition] = []
                
                if let docs = company.documents {
                    for doc in docs {
                        let rawName = doc.document_type.trimmingCharacters(in: .whitespacesAndNewlines)
                        let lower = rawName.lowercased()
                        
                        // Strong filter for Aadhaar / PAN / Passport
                        if isMandatoryDocumentName(lower) {
                            continue
                        }
                        
                        mappedDocs.append(
                            DocumentDefinition(
                                id: doc.id,
                                name: rawName,
                                companyName: company.company_type,
                                isRequired: false
                            )
                        )
                    }
                }
                
                let option = CompanyOption(
                    id: company.id,
                    name: company.company_type,
                    documents: mappedDocs
                )
                companies.append(option)
            }
        }
        
        companyOptions = companies
        mandatorySections = buildMandatorySections()
        
        if let first = companies.first {
            selectCompany(first)
        }
    }
    
    /// Returns true if the given lowercased name belongs to Aadhaar / PAN / Passport.
    private func isMandatoryDocumentName(_ lower: String) -> Bool {
        let v = lower.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Aadhaar / Aadhar / Adhar, with or without "card"
        if v.contains("aadhaar") || v.contains("aadhar") || v.contains("adhar") {
            return true
        }
        
        // PAN
        if v == "pan" || v == "pan card" || (v.contains("pan") && v.contains("card")) {
            return true
        }
        
        // Passport
        if v == "passport" || v.contains("passport") {
            return true
        }
        
        return false
    }
    
    // MARK: - Mandatory Setup
    
    private func buildMandatorySections() -> [DocumentSection] {
        let defs = [
            DocumentDefinition(id: -1, name: "Aadhar Card", companyName: nil, isRequired: true),
            DocumentDefinition(id: -2, name: "PAN Card", companyName: nil, isRequired: true),
            DocumentDefinition(id: -3, name: "Passport", companyName: nil, isRequired: false)
        ]
        return defs.map { DocumentSection(definition: $0) }
    }
    
    // MARK: - Company
    
    func selectCompany(_ company: CompanyOption) {
        selectedCompany = company
        availableDocumentsForSelectedCompany = company.documents
        businessSections.removeAll()
        computeContinueState()
        // Persist into draft for final signup body
        SignupDraft.shared.companyTypeId = company.id
        SignupDraft.shared.save()
    }
    
    // MARK: - Business Docs
    
    func addBusinessSection(for doc: DocumentDefinition) {
        guard !businessSections.contains(where: { $0.definition.id == doc.id }) else { return }
        businessSections.append(DocumentSection(definition: doc))
        availableDocumentsForSelectedCompany.removeAll { $0.id == doc.id }
    }
    
    func removeBusinessSection(_ section: DocumentSection) {
        businessSections.removeAll { $0.id == section.id }
        
        if let company = selectedCompany,
           company.documents.contains(where: { $0.id == section.definition.id }) {
            if !availableDocumentsForSelectedCompany.contains(where: { $0.id == section.definition.id }) {
                availableDocumentsForSelectedCompany.append(section.definition)
                availableDocumentsForSelectedCompany.sort { $0.name < $1.name }
            }
        }
        computeContinueState()
    }
    
    // MARK: - Mandatory Docs
    
    func clearMandatoryAttachment(_ id: UUID) {
        if let idx = mandatorySections.firstIndex(where: { $0.id == id }) {
            mandatorySections[idx].attachment = nil
            computeContinueState()
        }
    }
    
    // MARK: - Attachments
    
    func attach(_ attachment: DocumentAttachment, to sectionID: UUID) {
        if let idx = businessSections.firstIndex(where: { $0.id == sectionID }) {
            businessSections[idx].attachment = attachment
        } else if let idx = mandatorySections.firstIndex(where: { $0.id == sectionID }) {
            mandatorySections[idx].attachment = attachment
        }
        computeContinueState()
    }
    
    // MARK: - Upload entry points (called from View)
    
    func didPickImage(_ image: UIImage, for sectionID: UUID) {
        Task {
            await upload(attachment: .image(image), for: sectionID)
        }
    }
    
    func didPickFile(_ url: URL, for sectionID: UUID) {
        Task {
            await upload(attachment: .file(url), for: sectionID)
        }
    }
    
    // MARK: - Upload implementation
    
    private func upload(attachment: DocumentAttachment, for sectionID: UUID) async {
        await MainActor.run {
            self.isLoading = true            // 👈 show loader
        }
        
        // find the section & its doc definition
        guard let section = (businessSections.first { $0.id == sectionID }
                             ?? mandatorySections.first { $0.id == sectionID }) else {
            await MainActor.run { self.isLoading = false }
            return
        }
        
        // We need document_type, vendor_business_no, company_type
        guard let phone = SignupDraft.shared.businessPhone,
              !phone.trimmingCharacters(in: .whitespaces).isEmpty else {
#if DEBUG
            print("SignupDocumentsViewModel.upload: missing business phone in SignupDraft")
#endif
            await MainActor.run { self.isLoading = false }
            return
        }
        
        guard let company = selectedCompany else {
#if DEBUG
            print("SignupDocumentsViewModel.upload: no company selected")
#endif
            await MainActor.run { self.isLoading = false }
            return
        }
        
        // Prepare file data
        let data: Data
        let fileName: String
        let mime: String
        
        switch attachment {
        case .image(let uiImage):
            guard let jpeg = uiImage.jpegData(compressionQuality: 0.9) else {
                await MainActor.run { self.isLoading = false }
                return
            }
            data = jpeg
            fileName = "document-\(UUID().uuidString.prefix(8)).jpg"
            mime = "image/jpeg"
            
        case .file(let url):
            do {
                data = try Data(contentsOf: url)
            } catch {
#if DEBUG
                print("Failed to read file at \(url): \(error)")
#endif
                await MainActor.run { self.isLoading = false }
                return
            }
            fileName = url.lastPathComponent
            let ext = url.pathExtension.lowercased()
            if ext == "png" {
                mime = "image/png"
            } else if ext == "jpg" || ext == "jpeg" {
                mime = "image/jpeg"
            } else if ext == "pdf" {
                mime = "application/pdf"
            } else {
                mime = "application/octet-stream"
            }
        }
        
        // Build API
        let documentType = section.definition.name   // e.g. "GST", "Aadhar Card"
        let api = VendorAPI.uploadDocument(
            documentType: documentType,
            fileName: fileName,
            mime: mime,
            data: data,
            vendorBusinessNo: phone,
            companyTypeId: company.id
        )
        
        do {
            let response: UploadDocumentResponse = try await NetworkManager.shared
                .requestJSON(api, decode: UploadDocumentResponse.self)
            
            await MainActor.run {
                // 1. Attach thumbnail to section
                self.attach(attachment, to: sectionID)
                
                // 2. Append uploaded doc into SignupDraft for final signup body
                let draftDoc = response.document.toDraftDoc()
                SignupDraft.shared.uploadedDocuments.append(draftDoc)
                SignupDraft.shared.save()
                
                self.isLoading = false       // 👈 hide loader on success
            }
        } catch {
#if DEBUG
            print("Upload document failed: \(error)")
#endif
            await MainActor.run {
                self.isLoading = false       // 👈 hide loader on failure too
            }
        }
    }
    
    
    // MARK: - Picker & Preview
    
    func openPicker(for section: DocumentSection) {
        activePickerTarget = PickerTarget(sectionID: section.id, source: .photoLibrary)
    }
    
    func preview(_ section: DocumentSection) {
        guard let a = section.attachment else { return }
        activePreviewItem = PreviewItem(attachment: a, title: section.definition.name)
    }
    
    // MARK: - Continue
    private func computeContinueState() {
        // Only required docs (Aadhar, PAN) must have attachments
        let requiredMandatory = mandatorySections.filter { $0.definition.isRequired }
        let mandatoryOK = requiredMandatory.allSatisfy { $0.attachment != nil }
        
        // Business: at least 3 with attachments
        let businessOK = businessSections.filter { $0.attachment != nil }.count >= 3
        
        isContinueEnabled = mandatoryOK && businessOK
    }
    
    
    func handleContinueTapped(onSuccess: @escaping () -> Void) {
        guard isContinueEnabled else { return }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isLoading = false
            onSuccess()
        }
    }
}

// MARK: - Helpers

extension SignupDocumentsViewModel.DocumentAttachment {
    func filename(fallback: String) -> String {
        switch self {
        case .image:
            return fallback
        case .file(let url):
            return url.lastPathComponent
        }
    }
}

extension SignupDocumentsViewModel.DocumentSection {
    var readableSize: String? {
        guard let a = attachment else { return nil }
        
        let f = ByteCountFormatter()
        f.countStyle = .file
        
        switch a {
        case .image(let img):
            guard let data = img.jpegData(compressionQuality: 0.8) else { return nil }
            return f.string(fromByteCount: Int64(data.count))
        case .file(let url):
            let values = try? url.resourceValues(forKeys: [.fileSizeKey])
            if let size = values?.fileSize {
                return f.string(fromByteCount: Int64(size))
            }
            return nil
        }
    }
}
