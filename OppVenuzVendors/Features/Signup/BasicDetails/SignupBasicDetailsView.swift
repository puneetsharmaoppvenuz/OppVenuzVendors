//
//  SignupBasicDetailsView.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 14/11/25.
//

import SwiftUI

// Month labels so "Apr" never breaks
private let shortMonthNames: [String] = [
    "Jan","Feb","Mar","Apr","May","Jun",
    "Jul","Aug","Sep","Oct","Nov","Dec"
]

private func genderImageName(_ gender: Gender) -> String {
    switch gender {
    case .male:   return "male"
    case .female: return "female"
    case .other:  return "other"
    }
}

struct SignupBasicDetailsView: View {
    
    @StateObject private var viewModel = SignupBasicDetailsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var onContinue: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    progressHeader
                    
                    Image("signup2")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .padding(.top, 8)
                    
                    Text("Add Basic Details")
                        .font(RobotoFont.bold(20))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 4)
                    
                    textFieldSection(title: "Enter Your First Name",
                                     placeholder: "Enter Your First Name",
                                     text: $viewModel.firstName)
                    
                    textFieldSection(title: "Enter Your Middle Name (Optional)",
                                     placeholder: "Enter Your Middle Name",
                                     text: $viewModel.middleName)
                    
                    textFieldSection(title: "Enter Your Last Name",
                                     placeholder: "Enter Your Last Name",
                                     text: $viewModel.lastName)
                    
                    textFieldSection(title: "Enter Your Business Name",
                                     placeholder: "Business Name",
                                     text: $viewModel.businessName)
                    
                    genderSection
                    dobSection
                    businessCategorySection
                    bestSuitedSection
                    experienceSection
                    
                    Button {
                        viewModel.saveDraft()
                        onContinue?()
                    } label: {
                        Text("Continue")
                            .font(RobotoFont.medium(17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .background(
                        viewModel.canContinue
                        ? LinearGradient(
                            colors: [Color(hex: "#5A69FC"), Color(hex: "#AF6AEF")],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                        : LinearGradient(
                            colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                    )
                    .cornerRadius(12)
                    .shadow(
                        color: Color.black.opacity(viewModel.canContinue ? 0.1 : 0.0),
                        radius: 14, x: 0, y: 7
                    )
                    .disabled(!viewModel.canContinue)
                    .padding(.top, 12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .tint(.primary)
            .sheet(isPresented: $viewModel.isBusinessCategorySheetPresented) {
                BusinessCategorySheet(
                    categories: viewModel.businessCategories,
                    selected: viewModel.selectedBusinessCategory
                ) { chosen in
                    viewModel.selectedBusinessCategory = chosen
                }
            }
            .sheet(isPresented: $viewModel.isBestSuitedSheetPresented) {
                BestSuitedSheet(
                    types: viewModel.bestSuitedTypes,
                    selectedIds: viewModel.selectedBestSuitedIds
                ) { newSelection in
                    viewModel.selectedBestSuitedIds = newSelection
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Sections
    
    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("1/3")
                .font(RobotoFont.medium(12))
                .foregroundColor(.primary)
            
            HStack(spacing: 6) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#5A69FC"), Color(hex: "#AF6AEF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 6)
                
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
            }
        }
        .padding(.top, 16)
    }
    
    private func textFieldSection(title: String,
                                  placeholder: String,
                                  text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(RobotoFont.medium(15))
            TextField(placeholder, text: text)
                .font(RobotoFont.regular(14))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var genderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gender")
                .font(RobotoFont.medium(15))
            
            HStack(spacing: 10) {
                ForEach(Gender.allCases) { gender in
                    genderButton(gender)
                }
            }
        }
    }
    
    private func genderButton(_ gender: Gender) -> some View {
        let isSelected = viewModel.gender == gender
        
        return Button {
            viewModel.gender = gender
        } label: {
            HStack(spacing: 4) {
                Image(genderImageName(gender))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text(gender.displayTitle)
                    .font(RobotoFont.medium(14))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    LinearGradient(
                        colors: [Color(hex: "#5A69FC"), Color(hex: "#AF6AEF")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    Color.white
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color.clear : Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .cornerRadius(10)
        }
    }
    
    private var dobSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("D.O.B")
                .font(RobotoFont.medium(15))
            
            HStack(spacing: 10) {
                Picker("", selection: $viewModel.dobDayIndex) {
                    Text("DD").tag(0)
                    ForEach(0..<viewModel.days.count, id: \.self) { index in
                        Text(String(format: "%02d", viewModel.days[index]))
                            .tag(index + 1)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                Picker("", selection: $viewModel.dobMonthIndex) {
                    Text("MM").tag(0)
                    ForEach(0..<viewModel.months.count, id: \.self) { index in
                        Text(String(format: "%02d", viewModel.months[index]))
                            .tag(index + 1)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                Picker("", selection: $viewModel.dobYearIndex) {
                    Text("YYY").tag(0)
                    ForEach(0..<viewModel.years.count, id: \.self) { index in
                        Text(String(viewModel.years[index]))
                            .tag(index + 1)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    private var businessCategorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Enter your Business Category")
                .font(RobotoFont.medium(15))
            
            Button {
                viewModel.isBusinessCategorySheetPresented = true
            } label: {
                HStack {
                    Text(viewModel.selectedBusinessCategory?.name ?? "Select Business Category")
                        .font(RobotoFont.regular(14))
                        .foregroundColor(
                            viewModel.selectedBusinessCategory == nil
                            ? .secondary
                            : .primary
                        )
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    private var bestSuitedSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Select What Your Business Is Best Suited For")
                .font(RobotoFont.medium(15))
            
            Button {
                viewModel.isBestSuitedSheetPresented = true
            } label: {
                HStack {
                    Text(viewModel.bestSuitedSummary.isEmpty
                         ? "Select What Your Business Is Best Suited For"
                         : viewModel.bestSuitedSummary)
                        .font(RobotoFont.regular(14))
                        .foregroundColor(
                            viewModel.bestSuitedSummary.isEmpty ? .secondary : .primary
                        )
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    private var experienceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Year’s of Experience")
                .font(RobotoFont.medium(15))
            
            HStack(spacing: 10) {
                Picker("", selection: $viewModel.expMonthIndex) {
                    Text("MM").tag(0)
                    ForEach(0..<viewModel.months.count, id: \.self) { index in
                        Text(shortMonthNames[index])
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .tag(index + 1)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                Picker("", selection: $viewModel.expYearIndex) {
                    Text("YYYY").tag(0)
                    ForEach(0..<viewModel.expYears.count, id: \.self) { index in
                        Text(String(viewModel.expYears[index]))
                            .tag(index + 1)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            if !viewModel.experienceLabel.isEmpty {
                Text(viewModel.experienceLabel)
                    .font(RobotoFont.regular(12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Business Category Sheet

private struct BusinessCategorySheet: View {
    let categories: [BusinessCategory]
    let selected: BusinessCategory?
    var onSave: (BusinessCategory?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var tempSelected: BusinessCategory?
    
    init(categories: [BusinessCategory],
         selected: BusinessCategory?,
         onSave: @escaping (BusinessCategory?) -> Void) {
        self.categories = categories
        self.selected = selected
        self.onSave = onSave
        _tempSelected = State(initialValue: selected)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .padding(8)
                    }
                }
                
                Text("Select Business Category")
                    .font(RobotoFont.medium(18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(categories) { category in
                            HStack {
                                Text(category.name)
                                    .font(RobotoFont.regular(14))
                                Spacer()
                                if category.id == tempSelected?.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: "#5A69FC"))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                tempSelected = category
                            }
                        }
                    }
                }
                
                Button {
                    onSave(tempSelected)
                    dismiss()
                } label: {
                    Text("Save")
                        .font(RobotoFont.medium(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#5A69FC"), Color(hex: "#AF6AEF")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .frame(maxWidth: 360)
        }
    }
}

// MARK: - Best Suited Sheet

private struct BestSuitedSheet: View {
    let types: [BestSuitedType]
    var onSave: (Set<Int>) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var tempSelection: Set<Int>
    
    init(types: [BestSuitedType],
         selectedIds: Set<Int>,
         onSave: @escaping (Set<Int>) -> Void) {
        self.types = types
        self.onSave = onSave
        _tempSelection = State(initialValue: selectedIds)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .padding(8)
                    }
                }
                
                Text("Please Select Best Suitable Type")
                    .font(RobotoFont.medium(18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(types) { type in
                            HStack(spacing: 12) {
                                Image(systemName: tempSelection.contains(type.id)
                                      ? "checkmark.square.fill"
                                      : "square")
                                    .foregroundColor(
                                        tempSelection.contains(type.id)
                                        ? Color(hex: "#5A69FC")
                                        : .secondary
                                    )
                                    .font(.system(size: 18))
                                
                                Text(type.name)
                                    .font(RobotoFont.regular(14))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if tempSelection.contains(type.id) {
                                    tempSelection.remove(type.id)
                                } else {
                                    tempSelection.insert(type.id)
                                }
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                
                Button {
                    onSave(tempSelection)
                    dismiss()
                } label: {
                    Text("Save")
                        .font(RobotoFont.medium(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#5A69FC"), Color(hex: "#AF6AEF")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .frame(maxWidth: 360)
        }
    }
}
