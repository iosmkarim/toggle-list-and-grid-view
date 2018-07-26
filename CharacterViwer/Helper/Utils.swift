
import UIKit
import Foundation

func alertWithTitle(title: String!, message: String, viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil);
    
    alert.addAction(action)
    viewController.present(alert, animated: true, completion:nil)
}
