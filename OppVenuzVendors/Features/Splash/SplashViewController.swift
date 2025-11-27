//
//  SplashViewController.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import UIKit
import WebKit

final class SplashViewController: UIViewController {
    
    private var webView: WKWebView!
    
    override var prefersStatusBarHidden: Bool { true } // hide clock during splash
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        webView = WKWebView(frame: .zero)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        if let urlString = BaseAPIService.cachedGIFURL(),
           let url = URL(string: urlString) {
            loadGIFFullScreen(url)
        } else {
            showFallbackLogo()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            self?.routeToOnboarding()
        }
    }
    
    // MARK: - Helpers
    
    private func loadGIFFullScreen(_ url: URL) {
        // Fill the whole viewport; use object-fit: cover for full-bleed (may crop a little).
        // Switch to 'contain' if you prefer letterboxing.
        let html = """
        <!doctype html>
        <html>
          <head>
            <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, width=device-width, height=device-height">
            <style>
              html, body { margin:0; padding:0; background:#000; height:100%; }
              .wrap { position:fixed; inset:0; display:flex; align-items:center; justify-content:center; }
              img { width:100vw; height:100vh; object-fit:cover; }
            </style>
          </head>
          <body>
            <div class="wrap">
              <img src="\(url.absoluteString)" alt="splash">
            </div>
          </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    private func showFallbackLogo() {
        let fallback = UIImageView(image: UIImage(named: "logo"))
        fallback.contentMode = .scaleAspectFit
        fallback.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fallback)
        NSLayoutConstraint.activate([
            fallback.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fallback.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fallback.topAnchor.constraint(equalTo: view.topAnchor),
            fallback.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func routeToOnboarding() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController") else { return }
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first {
            window.rootViewController = UINavigationController(rootViewController: vc)
            window.makeKeyAndVisible()
        } else {
            navigationController?.setViewControllers([vc], animated: true)
        }
    }
}
