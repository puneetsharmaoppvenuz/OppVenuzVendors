//
//  SceneDelegate.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        // 1) Start with LaunchHost (animated logo) while API loads
        let launchHost = LaunchHostViewController()
        window.rootViewController = launchHost
        window.makeKeyAndVisible()
        self.window = window
        
        // 2) Kick base API fetch
        Task { @MainActor in
            do {
                _ = try await BaseAPIService.fetchAndCache()
                // 3) On success, show Splash VC (GIF)
                self.showSplashGIF()
            } catch {
                // You can retry or proceed with cached data
                if BaseAPIService.cachedEnvelope() != nil {
                    self.showSplashGIF()
                } else {
                    // Minimal fallback: still proceed to splash GIF (will show fallback image)
                    self.showSplashGIF()
                }
            }
        }
    }
    
    @MainActor
    private func showSplashGIF() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let splash = sb.instantiateViewController(withIdentifier: "SplashViewController")
        // Replace stack with GIF VC
        window?.rootViewController = splash
        window?.makeKeyAndVisible()
    }
}
