import UIKit

class CollectionViewCell: UICollectionViewCell {
    private weak var widthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        let widthConstraint = contentView.widthAnchor.constraint(equalToConstant: contentView.bounds.width)
        widthConstraint.priority = .required - 1 // don't conflict with UIView-Encapsulated-Layout-Width
        widthConstraint.isActive = true
        self.widthConstraint = widthConstraint
    }

    func setup(width: CGFloat) {
        widthConstraint.constant = width
    }
}
