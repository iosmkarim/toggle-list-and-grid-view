
import UIKit

class CharacterViewerMainViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CharacterViewerMainViewController: UISplitViewControllerDelegate{
    
    //MARK: SplitViewControllerDelegate
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
