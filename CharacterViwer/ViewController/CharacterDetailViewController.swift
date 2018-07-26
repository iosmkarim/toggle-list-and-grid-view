
import UIKit

class CharacterDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var person: Person? {
        didSet {
            refreshUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func refreshUI() {
        loadViewIfNeeded()
        self.title = person?.name
        nameLabel.text = person?.name
        descriptionLabel.text = person?.description
        
        if let iconUrlString = person?.iconName{
            if (iconUrlString.isEmpty){
                iconImageView.image = UIImage(named: "ic_no_person_image")
            }else{
                let url = URL(string: iconUrlString)
                iconImageView.kf.setImage(with: url)
            }
        }
    }
}

extension CharacterDetailViewController: PersonSelectionDelegate {
    func personSelected(_ newPerson: Person) {
        person = newPerson
    }
}
