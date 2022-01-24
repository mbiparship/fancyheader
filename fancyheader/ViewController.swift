import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var headerContainerView: UIView!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var headerTitleLabel: UILabel!
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var backgroundViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var collectionView: UICollectionView!

    private enum Constants {
        static let imageParallaxFactor: CGFloat = 0.25
        static let titleParallaxFactor: CGFloat = 0.33
        static let cornerRadius: CGFloat = 32
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // this doesn't work from IB
        collectionView.backgroundColor = .clear

        setupBackgroundView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustContentInset()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        adjustContentInset()
    }

    private func adjustContentInset() {
        collectionView.contentInset.top = headerContainerView.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
    }

    private func setupBackgroundView() {
        backgroundView.layer.cornerRadius = Constants.cornerRadius
        backgroundView.layer.cornerCurve = .continuous
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundView.layer.masksToBounds = true
    }

}

extension ViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let sectionInset = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset
        let width = collectionView.safeAreaLayoutGuide.layoutFrame.width
            - (sectionInset?.left ?? 0)
            - (sectionInset?.right ?? 0)
        (cell as? CollectionViewCell)?.setup(width: width)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let headerHeight = headerContainerView.bounds.height
        let contentOffsetY = scrollView.contentOffset.y
        let relativeContentOffsetY = contentOffsetY + scrollView.adjustedContentInset.top

        // move background along
        backgroundViewTopConstraint.constant = relativeContentOffsetY

        if relativeContentOffsetY < 0.0 { // scrolling down

            // stretchy header
            let updatedHeight = min(
                    collectionView.frame.height,
                    max(headerHeight, headerHeight - relativeContentOffsetY)
            )
            let scaleFactor = updatedHeight / headerHeight
            let delta = (updatedHeight - headerHeight) / 2
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            let translationY = min(relativeContentOffsetY, headerHeight) + delta
            headerImageView.transform = scale.concatenating(CGAffineTransform(translationX: 0, y: -translationY))
            headerTitleLabel.transform = CGAffineTransform(translationX: 0, y: -translationY)

            headerTitleLabel.alpha = 1

        } else { // scrolling up

            // parallax
            let imageTranslationY = relativeContentOffsetY * Constants.imageParallaxFactor
            headerImageView.transform = CGAffineTransform(translationX: 0, y: -imageTranslationY)

            let titleTranslationY = relativeContentOffsetY * Constants.titleParallaxFactor
            headerTitleLabel.transform = CGAffineTransform(translationX: 0, y: -titleTranslationY)

            // fade
            let relativeY = abs(min(0, contentOffsetY))
            let maxY = headerContainerView.frame.maxY
//            let headerAlpha: CGFloat = relativeY / maxY

            let titleMinY = headerTitleLabel.frame.minY
            let titleYDistance = round(relativeY - titleMinY)
            let titleOriginalMinY = titleMinY + titleTranslationY
            let titleOriginalYDistance = round(maxY - titleOriginalMinY)
            let titleAlpha: CGFloat = max(0, titleYDistance) / titleOriginalYDistance
            headerTitleLabel.alpha = titleAlpha
        }
    }
}
