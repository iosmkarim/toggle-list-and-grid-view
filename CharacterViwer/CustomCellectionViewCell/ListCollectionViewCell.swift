import Foundation
import UIKit

class ListCollectionViewCell : UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imgView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_no_person_image")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title2)
        
        return label
    }()
    
    let descriptionLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        return label
    }()
    
    func setUpViews() {
        
        backgroundColor = UIColor.init(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        addSubview(imgView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        imgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        imgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        imgView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imgView.widthAnchor.constraint(equalToConstant: frame.height).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 8).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imgView.topAnchor, constant: 4).isActive = true
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 8).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: imgView.bottomAnchor, constant: -4).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
}
