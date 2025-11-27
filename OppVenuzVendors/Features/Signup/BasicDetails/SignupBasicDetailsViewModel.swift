//
//  SignupBasicDetailsViewModel.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 14/11/25.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Draft storage for this step

final class SignupBasicDraft {
    static let shared = SignupBasicDraft()
    
    var firstName: String = ""
    var middleName: String = ""
    var lastName: String = ""
    var businessName: String = ""
    var gender: Gender? = nil
    
    var dobDay: Int?
    var dobMonth: Int?
    var dobYear: Int?
    
    var businessCategoryId: Int?
    var businessCategoryName: String?
    
    var bestSuitedIds: [Int] = []
    var bestSuitedNames: [String] = []
    
    var experienceStartMonth: Int?
    var experienceStartYear: Int?
    var experienceTotalMonths: Int = 0
    var experienceLabel: String = ""
}

// MARK: - Simple master models

struct BusinessCategory: Identifiable, Hashable {
    let id: Int
    let name: String
}

struct BestSuitedType: Identifiable, Hashable {
    let id: Int
    let name: String
}

enum Gender: String, CaseIterable, Identifiable {
    case male
    case female
    case other
    
    var id: String { rawValue }
    
    var displayTitle: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other"
        }
    }
}

// MARK: - ViewModel

@MainActor
final class SignupBasicDetailsViewModel: ObservableObject {
    
    // MARK: - Input fields
    
    @Published var firstName: String = ""
    @Published var middleName: String = ""
    @Published var lastName: String = ""
    @Published var businessName: String = ""
    
    @Published var gender: Gender? = nil
    
    // DOB pickers use index 0 = placeholder, >0 real value
    @Published var dobDayIndex: Int = 0
    @Published var dobMonthIndex: Int = 0
    @Published var dobYearIndex: Int = 0
    
    // Business category
    @Published var businessCategories: [BusinessCategory] = []
    @Published var selectedBusinessCategory: BusinessCategory? = nil
    @Published var isBusinessCategorySheetPresented: Bool = false
    
    // Best suited types (multi-select)
    @Published var bestSuitedTypes: [BestSuitedType] = []
    @Published var selectedBestSuitedIds: Set<Int> = []
    @Published var isBestSuitedSheetPresented: Bool = false
    
    // Experience (start month/year)
    @Published var expMonthIndex: Int = 0
    @Published var expYearIndex: Int = 0
    
    // MARK: - Constants
    
    let days = Array(1...31)
    let months = Array(1...12)
    let years: [Int]       // DOB years (max = currentYear - 15)
    let expYears: [Int]    // Experience start year options
    
    private let currentYear: Int
    
    // MARK: - Init
    
    init() {
        currentYear = Calendar.current.component(.year, from: Date())
        
        // Vendor must be at least 15 years old
        let maxDobYear = currentYear - 15
        years = Array((maxDobYear - 80)...maxDobYear).reversed()
        
        expYears = Array((currentYear - 50)...currentYear).reversed()
        
        loadMasterData()
        loadDraft()
    }
    
    // MARK: - Derived values
    
    var selectedDay: Int? {
        dobDayIndex == 0 ? nil : days[dobDayIndex - 1]
    }
    
    var selectedMonth: Int? {
        dobMonthIndex == 0 ? nil : months[dobMonthIndex - 1]
    }
    
    var selectedYear: Int? {
        dobYearIndex == 0 ? nil : years[dobYearIndex - 1]
    }
    
    var selectedExpMonth: Int? {
        expMonthIndex == 0 ? nil : months[expMonthIndex - 1]
    }
    
    var selectedExpYear: Int? {
        expYearIndex == 0 ? nil : expYears[expYearIndex - 1]
    }
    
    var dobDisplay: String {
        guard let d = selectedDay,
              let m = selectedMonth,
              let y = selectedYear else {
            return ""
        }
        return String(format: "%02d/%02d/%04d", d, m, y)
    }
    
    // Show label even if only month is selected (use current year until user picks)
    var experienceLabel: String {
        guard let m = selectedExpMonth else { return "" }
        let y = selectedExpYear ?? currentYear
        let totalMonths = experienceMonths(fromMonth: m, year: y)
        return formattedExperience(months: totalMonths)
    }
    
    var bestSuitedSummary: String {
        guard !selectedBestSuitedIds.isEmpty else {
            return ""
        }
        let names = bestSuitedTypes
            .filter { selectedBestSuitedIds.contains($0.id) }
            .map(\.name)
        return names.joined(separator: ", ")
    }
    
    // NOTE: middleName is NOT mandatory
    var canContinue: Bool {
        !firstName.trimmed.isEmpty &&
        !lastName.trimmed.isEmpty &&
        !businessName.trimmed.isEmpty &&
        gender != nil &&
        selectedDay != nil &&
        selectedMonth != nil &&
        selectedYear != nil &&
        selectedBusinessCategory != nil &&
        !selectedBestSuitedIds.isEmpty &&
        selectedExpMonth != nil &&
        selectedExpYear != nil
    }
    
    // MARK: - Actions
    
    func toggleBestSuited(id: Int) {
        if selectedBestSuitedIds.contains(id) {
            selectedBestSuitedIds.remove(id)
        } else {
            selectedBestSuitedIds.insert(id)
        }
    }
    
    func saveDraft() {
        // 1. Save into step-specific draft (existing behavior)
        let draft = SignupBasicDraft.shared
        draft.firstName = firstName.trimmed
        draft.middleName = middleName.trimmed
        draft.lastName = lastName.trimmed
        draft.businessName = businessName.trimmed
        draft.gender = gender
        
        draft.dobDay = selectedDay
        draft.dobMonth = selectedMonth
        draft.dobYear = selectedYear
        
        draft.businessCategoryId = selectedBusinessCategory?.id
        draft.businessCategoryName = selectedBusinessCategory?.name
        
        draft.bestSuitedIds = Array(selectedBestSuitedIds)
        draft.bestSuitedNames = bestSuitedTypes
            .filter { selectedBestSuitedIds.contains($0.id) }
            .map(\.name)
        
        var yearsExperienceString: String? = nil
        var workingSinceISO: String? = nil
        
        if let m = selectedExpMonth,
           let y = selectedExpYear {
            let months = experienceMonths(fromMonth: m, year: y)
            draft.experienceStartMonth = m
            draft.experienceStartYear = y
            draft.experienceTotalMonths = months
            draft.experienceLabel = formattedExperience(months: months)
            
            let yearsOnly = max(0, months / 12)
            yearsExperienceString = String(yearsOnly)
            
            // Build working_since as YYYY-MM-01
            workingSinceISO = String(format: "%04d-%02d-01", y, m)
        }
        
        // 2. Also save into global SignupDraft for final API
        let signup = SignupDraft.shared
        
        // DOB
        let dobISO: String?
        if let d = selectedDay,
           let m = selectedMonth,
           let y = selectedYear {
            dobISO = String(format: "%04d-%02d-%02d", y, m, d)
        } else {
            dobISO = nil
        }
        
        signup.setBasic(
            firstName: firstName.trimmed.isEmpty ? nil : firstName.trimmed,
            middleName: middleName.trimmed.isEmpty ? nil : middleName.trimmed,
            lastName: lastName.trimmed.isEmpty ? nil : lastName.trimmed,
            businessName: businessName.trimmed.isEmpty ? nil : businessName.trimmed,
            gender: gender?.displayTitle,
            dobISO: dobISO,
            categoryId: selectedBusinessCategory?.id,
            bestSuitedIds: Array(selectedBestSuitedIds),
            yearsOfExperience: yearsExperienceString
        )
        
        signup.set(\.workingSince, workingSinceISO)
        
        signup.save()
    }
    
    
    
    // MARK: - Private helpers
    
    private func loadMasterData() {
        guard let envelope = BaseAPIService.cachedEnvelope(),
              let data = envelope.data else {
            businessCategories = []
            bestSuitedTypes = []
            return
        }
        
        if let categories = data.categories {
            businessCategories = categories.map {
                BusinessCategory(
                    id: $0.id,
                    name: $0.service_name
                )
            }
        } else {
            businessCategories = []
        }
        
        if let suited = data.best_suited_for {
            bestSuitedTypes = suited.map {
                BestSuitedType(
                    id: $0.id,
                    name: $0.name
                )
            }
        } else {
            bestSuitedTypes = []
        }
    }
    
    private func loadDraft() {
        let draft = SignupBasicDraft.shared
        
        firstName = draft.firstName
        middleName = draft.middleName
        lastName = draft.lastName
        businessName = draft.businessName
        gender = draft.gender
        
        if let d = draft.dobDay,
           let idx = days.firstIndex(of: d) {
            dobDayIndex = idx + 1
        }
        if let m = draft.dobMonth,
           let idx = months.firstIndex(of: m) {
            dobMonthIndex = idx + 1
        }
        if let y = draft.dobYear,
           let idx = years.firstIndex(of: y) {
            dobYearIndex = idx + 1
        }
        
        if let catId = draft.businessCategoryId,
           let cat = businessCategories.first(where: { $0.id == catId }) {
            selectedBusinessCategory = cat
        }
        
        selectedBestSuitedIds = Set(draft.bestSuitedIds)
        
        if let m = draft.experienceStartMonth,
           let y = draft.experienceStartYear,
           let mIdx = months.firstIndex(of: m),
           let yIdx = expYears.firstIndex(of: y) {
            expMonthIndex = mIdx + 1
            expYearIndex = yIdx + 1
        }
    }
    
    private func experienceMonths(fromMonth month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        
        guard let startDate = calendar.date(from: comps) else { return 1 }
        
        let diff = calendar.dateComponents([.month], from: startDate, to: now)
        let months = (diff.month ?? 0) + 1
        return max(1, months)
    }
    
    private func formattedExperience(months: Int) -> String {
        if months <= 1 {
            return "Less than 1 month"
        }
        
        if months < 12 {
            return "\(months) months"
        }
        
        let years = months / 12
        let remainingMonths = months % 12
        
        if remainingMonths == 0 {
            return years == 1 ? "1 year" : "\(years) years"
        } else {
            let yearPart = years == 1 ? "1 year" : "\(years) years"
            let monthPart = remainingMonths == 1 ? "1 month" : "\(remainingMonths) months"
            return "\(yearPart) \(monthPart)"
        }
    }
}

// MARK: - Small string helper

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
