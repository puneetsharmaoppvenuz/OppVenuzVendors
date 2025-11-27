//
//  ImageLoader.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import UIKit

/// Very small image loader with URLCache + in-memory cache.
public final class ImageLoader {
    public static let shared = ImageLoader()
    
    private let memCache = NSCache<NSString, UIImage>()
    private init() { memCache.countLimit = 100 }
    
    public func load(_ url: URL, into imageView: UIImageView, placeholder: UIImage? = nil) {
        imageView.image = placeholder
        
        if let cached = memCache.object(forKey: url.absoluteString as NSString) {
            imageView.image = cached
            return
        }
        
        // Use default URLCache (respects HTTP cache headers)
        let req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        let task = URLSession.shared.dataTask(with: req) { [weak self, weak imageView] data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            self?.memCache.setObject(img, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                imageView?.image = img
            }
        }
        task.resume()
    }
}
