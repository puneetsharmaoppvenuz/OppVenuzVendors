//
//  UIApplication+TopMost.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 21/11/25.
//

import UIKit

extension UIApplication {

    /// Returns the top-most (visible) view controller in the key window.
    var topMostViewController: UIViewController? {
        guard let root = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
            return nil
        }
        return root.topMostViewController()
    }
}

extension UIViewController {

    /// Recursively find the top-most presented / visible view controller.
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }

        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }

        return self
    }
}
