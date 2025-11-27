//
//  OnboardingVC.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: GradientButton!
    
    private var items: [OnboardingImage] = []
    private var lastSize: CGSize = .zero
    private var currentPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Data from cached BaseAPI
        if let list = BaseAPIService.cachedEnvelope()?.data?.onboarding?.flash_screens {
            items = list.sorted { $0.order < $1.order }
        }
        
        // Collection setup
        collectionView.register(OnboardingImageCell.self,
                                forCellWithReuseIdentifier: OnboardingImageCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.itemSize = collectionView.bounds.size
        }
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.reloadData()
        
        styleContinue(for: currentPage)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure cells are full-screen and keep current page centered after size changes
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        if collectionView.bounds.size != lastSize {
            lastSize = collectionView.bounds.size
            layout.itemSize = lastSize
            layout.invalidateLayout()
            let offsetX = CGFloat(currentPage) * lastSize.width
            collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func didTapContinue(_ sender: GradientButton) {
        let last = max(items.count, 1) - 1
        if currentPage < last {
            goToPage(currentPage + 1, animated: true)
        } else {
            DefaultsStore.setBool(true, for: .onboardingSeen)
            routeToLogin()
        }
    }
    
    // MARK: - Helpers
    
    private func goToPage(_ page: Int, animated: Bool) {
        let target = max(0, min(page, max(items.count, 1) - 1))
        collectionView.layoutIfNeeded()
        let w = max(collectionView.bounds.width, 1)
        let targetOffset = CGPoint(x: CGFloat(target) * w, y: 0)
        collectionView.setContentOffset(targetOffset, animated: animated)
        currentPage = target
        styleContinue(for: currentPage)
        refreshVisibleCellShift()
    }
    
    private func styleContinue(for page: Int) {
        let last = max(items.count, 1) - 1
        let title = (page == last) ? "Get Started" : "Continue"
        continueButton.setTitle(title, for: .normal)
    }
    
    private func routeToLogin() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") else { return }
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first {
            window.rootViewController = UINavigationController(rootViewController: vc)
            window.makeKeyAndVisible()
        } else {
            navigationController?.setViewControllers([vc], animated: true)
        }
    }
    
    // Optional: if you nudged last image slightly left (as per earlier tweak)
    private func refreshVisibleCellShift() {
        let lastIndex = items.count - 1
        collectionView.visibleCells.forEach { c in
            if let cell = c as? OnboardingImageCell,
               let indexPath = collectionView.indexPath(for: cell) {
                if indexPath.item == lastIndex && currentPage == lastIndex {
                    cell.setHorizontalShift(-12) // adjust if needed
                } else {
                    cell.setHorizontalShift(0)
                }
            }
        }
    }
}

// MARK: - UICollectionView
extension OnboardingViewController: UICollectionViewDataSource,
                                    UICollectionViewDelegate,
                                    UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingImageCell.reuseID,
            for: indexPath
        ) as! OnboardingImageCell
        
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        
        let urlString = items[indexPath.item].media.image
        cell.configure(urlString: urlString)
        
        // Apply the optional last-page nudge only when that page is current
        if indexPath.item == items.count - 1 && currentPage == items.count - 1 {
            cell.setHorizontalShift(-12)
        } else {
            cell.setHorizontalShift(0)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let w = max(scrollView.bounds.width, 1)
        currentPage = Int(round(scrollView.contentOffset.x / w))
        styleContinue(for: currentPage)
        refreshVisibleCellShift()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let w = max(scrollView.bounds.width, 1)
        currentPage = Int(round(scrollView.contentOffset.x / w))
        styleContinue(for: currentPage)
        refreshVisibleCellShift()
    }
}
