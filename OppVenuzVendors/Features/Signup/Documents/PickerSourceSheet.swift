//
//  PickerSourceSheet.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 21/11/25.
//

import SwiftUI

struct PickerSourceSheet: View {

    let onSelectSource: (SignupDocumentsViewModel.PickerSource) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {

            Capsule()
                .fill(Color(.systemGray3))
                .frame(width: 36, height: 5)
                .padding(.top, 10)

            Text("Choose an Option")
                .font(.system(size: 16, weight: .semibold))
                .padding(.top, 14)

            VStack(spacing: 18) {
                optionRow(
                    icon: "camera.fill",
                    title: "Camera",
                    action: { choose(.camera) }
                )
                optionRow(
                    icon: "photo.fill.on.rectangle.fill",
                    title: "Photos",
                    action: { choose(.photoLibrary) }
                )
                optionRow(
                    icon: "folder.fill",
                    title: "Files",
                    action: { choose(.files) }
                )
            }
            .padding(.vertical, 20)

            Spacer(minLength: 10)
        }
        .presentationDetents([.height(250)])
    }

    private func choose(_ source: SignupDocumentsViewModel.PickerSource) {
        dismiss()
        onSelectSource(source)
    }

    private func optionRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .frame(width: 34, height: 34)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
    }
}
