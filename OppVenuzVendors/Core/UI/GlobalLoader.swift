//
//  GlobalLoader.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import UIKit

public final class GlobalLoader {
    
    public static let shared = GlobalLoader()
    private init() {}
    
    private var overlayWindow: UIWindow?
    private var activity: UIActivityIndicatorView?
    private var showCount = 0
    
    /// Show the loader overlay on top of everything.
    public func show() {
        DispatchQueue.main.async {
            self.showCount += 1
            
            // If already visible, no-op
            if self.overlayWindow != nil { return }
            
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.windowLevel = .alert + 1
            window.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()
            
            let vc = UIViewController()
            vc.view.backgroundColor = .clear
            vc.view.addSubview(spinner)
            NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
            ])
            
            window.rootViewController = vc
            window.isHidden = false
            
            self.overlayWindow = window
            self.activity = spinner
        }
    }
    
    /// Hide the loader after a minimum delay (to prevent flicker).
    /// - Parameter minDelay: seconds to wait before hiding from the moment this is called.
    public func hideAfterResponse(minDelay: TimeInterval = 1.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + minDelay) {
            self.hide(force: false)
        }
    }
    
    /// Force hide immediately, ignoring nested show counts.
    public func hide(force: Bool) {
        DispatchQueue.main.async {
            if !force {
                self.showCount = max(0, self.showCount - 1)
                if self.showCount > 0 { return }
            } else {
                self.showCount = 0
            }
            
            self.activity?.stopAnimating()
            self.overlayWindow?.isHidden = true
            self.overlayWindow = nil
            self.activity = nil
        }
    }
}
