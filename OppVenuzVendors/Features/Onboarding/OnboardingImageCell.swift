//
//  OnboardingImageCell.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import UIKit

final class OnboardingImageCell: UICollectionViewCell {
    static let reuseID = "OnboardingImageCell"
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .systemBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(urlString: String?) {
        guard let s = urlString, let url = URL(string: s) else {
            imageView.image = nil
            return
        }
        ImageLoader.shared.load(url, into: imageView)
    }
    // Reset any previous transform when the cell is reused
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.transform = .identity
    }
    
    /// Slight horizontal nudge (use negative to shift left)
    func setHorizontalShift(_ points: CGFloat) {
        if points == 0 {
            imageView.transform = .identity
        } else {
            imageView.transform = CGAffineTransform(translationX: points, y: 0)
        }
    }
    
}
