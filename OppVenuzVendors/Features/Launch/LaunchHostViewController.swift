//
//  LaunchHostViewController.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import UIKit

final class LaunchHostViewController: UIViewController {
    
    private let logo = UIImageView(image: UIImage(named: "logo")) // ensure same asset as LaunchScreen
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.contentMode = .scaleAspectFit
        view.addSubview(logo)
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logo.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.5),
            logo.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.25)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Simple pulse animation while API loads
        animatePulse()
    }
    
    private func animatePulse() {
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.fromValue = 0.95
        anim.toValue = 1.05
        anim.duration = 0.8
        anim.autoreverses = true
        anim.repeatCount = .greatestFiniteMagnitude
        logo.layer.add(anim, forKey: "pulse")
    }
}
