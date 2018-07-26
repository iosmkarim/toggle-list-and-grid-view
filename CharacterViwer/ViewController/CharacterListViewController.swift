
import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftyJSON
import Kingfisher

protocol PersonSelectionDelegate: class {
    func personSelected(_ newMonster: Person)
}

class CharacterListViewController: UICollectionViewController {
    
    let gridImage    = UIImage(named: "ic_grid")!
    let listImage    = UIImage(named: "ic_list")!
    let searchImage  = UIImage(named: "ic_search")!
    
    var isListView = false
    var toggleButton = UIBarButtonItem()
    
    weak var delegate: PersonSelectionDelegate?
    
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    
    var personsArray = [Person]()
    var searchableArray = [Person]()
    let screenSize = UIScreen.main.bounds
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x:0, y:0, width:screenSize.width/3, height:20))
    lazy var titleLabel:UILabel = UILabel(frame: CGRect(x:0, y:0, width:screenSize.width/3, height:20))
    
    let cellIdentifier = "ImageCell"
    let listCellIdentifier = "ListCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gridListButton   = UIBarButtonItem(image: listImage,  style: .plain, target: self, action: #selector(gridTapped(sender:)))
        let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(searchTapped(sender:)))
        
        navigationItem.rightBarButtonItems = [gridListButton, searchButton]
        
        if let displayName = Bundle.main.displayName {
            self.title = displayName
        }
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(GridCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: listCellIdentifier)
        
        showingLoader()
        
        let networkReachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
        networkReachabilityManager?.startListening()
        networkReachabilityManager?.listener = { _ in
            if let isNetworkReachable = networkReachabilityManager?.isReachable,
                isNetworkReachable == true {
                self.fetchData()
            } else {
                self.alert.dismiss(animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    alertWithTitle(title: "No internet", message: "Please connect with internet", viewController: self)
                }
            }
        }
    }
    
    @objc func gridTapped(sender: UIBarButtonItem) {
        if isListView {
            let editButton   = UIBarButtonItem(image: listImage,  style: .plain, target: self, action: #selector(gridTapped(sender:)))
            let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(searchTapped(sender:)))
            
            if (navigationItem.titleView == self.searchBar) {
                navigationItem.setRightBarButtonItems([editButton], animated: true)
            }else{
                navigationItem.setRightBarButtonItems([editButton, searchButton], animated: true)
            }
            isListView = false
        }else {
            
            let editButton   = UIBarButtonItem(image: gridImage,  style: .plain, target: self, action: #selector(gridTapped(sender:)))
            let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(searchTapped(sender:)))
            
            if (navigationItem.titleView == self.searchBar) {
                navigationItem.setRightBarButtonItems([editButton], animated: true)
            }else{
                navigationItem.setRightBarButtonItems([editButton, searchButton], animated: true)
            }
            
            isListView = true
        }
        
        self.collectionView?.reloadData()
    }
    
    @objc func searchTapped(sender: UIBarButtonItem) {
        
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        if isListView {
            let gridListButton = UIBarButtonItem(image: gridImage,  style: .plain, target: self, action: #selector(gridTapped(sender:)))
            navigationItem.setRightBarButtonItems([gridListButton], animated: true)
        }else {
            let gridListButton = UIBarButtonItem(image: listImage,  style: .plain, target: self, action: #selector(gridTapped(sender:)))
            navigationItem.setRightBarButtonItems([gridListButton], animated: true)
        }
    }
    
    fileprivate func showingLoader(){
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.present(self.alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func fetchData(){
        
        #if SIMPSONS
        let dataEndPoint = "http://api.duckduckgo.com/?q=simpsons+characters&format=json"
        #else
        let dataEndPoint = "http://api.duckduckgo.com/?q=the+wire+characters&format=json"
        #endif
        
        Alamofire.request(dataEndPoint)
            .responseSwiftyJSON { response in
                // check for errors
                guard response.result.error == nil else {
                    alertWithTitle(title: "Failed", message: response.result.error! as! String, viewController: self)
                    return
                }
                
                DispatchQueue.main.async {
                    if let relatedTopics = response.value?["RelatedTopics"] {
                        for i in 0..<relatedTopics.count{
                            
                            var title = ""
                            var description = ""
                            var iconUrlString = ""
                            
                            if relatedTopics[i]["Text"] != JSON.null {
                                
                                let descriptionText = relatedTopics[i]["Text"].string
                                var splitedTitleDescriptionArray = descriptionText?.split(separator: "-")
                                title = String(splitedTitleDescriptionArray![0])
                                
                                if (splitedTitleDescriptionArray?.count)! > 1{
                                    description = String(splitedTitleDescriptionArray![1])
                                }
                            }
                            if relatedTopics[i]["Icon"] != JSON.null  {
                                if relatedTopics[i]["Icon"]["URL"]  != JSON.null{
                                    iconUrlString = relatedTopics[i]["Icon"]["URL"].string!
                                }
                            }
                            
                            let singleItem = Person(name: title, description: description, iconName: iconUrlString)
                            
                            self.personsArray.append(singleItem)
                            
                        }
                        
                        self.collectionView?.reloadData()
                        self.alert.dismiss(animated: true, completion: nil)
                        self.searchableArray = self.personsArray
                    }
                }
        }
    }
    
    @objc func butonTapped(sender: UIBarButtonItem) {
        if isListView {
            toggleButton = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(butonTapped(sender:)))
            isListView = false
        }else {
            toggleButton = UIBarButtonItem(title: "Grid", style: .plain, target: self, action: #selector(butonTapped(sender:)))
            isListView = true
        }
        self.navigationItem.setRightBarButton(toggleButton, animated: true)
        self.collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CharacterListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        personsArray = searchableArray.filter { ($0.name ).range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil || ($0.description ).range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil }
        
        self.collectionView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if let displayName = Bundle.main.displayName {
            self.titleLabel.text = displayName
        }
        self.navigationItem.titleView = self.titleLabel
        
        if isListView {
            let editButton   = UIBarButtonItem(image: gridImage,  style: .plain, target: self, action: #selector(gridTapped(sender:)))
            let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(searchTapped(sender:)))
            navigationItem.setRightBarButtonItems([editButton, searchButton], animated: true)
            
        }else {
            let editButton   = UIBarButtonItem(image: listImage,  style: .plain, target: self, action: #selector(gridTapped(sender:)))
            let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(searchTapped(sender:)))
            navigationItem.setRightBarButtonItems([editButton, searchButton], animated: true)
        }
        self.personsArray = self.searchableArray
        self.collectionView?.reloadData()
    }
}

extension CharacterListViewController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return personsArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isListView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listCellIdentifier, for: indexPath) as! ListCollectionViewCell
            cell.titleLabel.text = personsArray[indexPath.item].name
            cell.descriptionLabel.text = personsArray[indexPath.item].description
            
            if personsArray[indexPath.item].iconName.isEmpty{
                cell.imgView.image = UIImage(named: "ic_no_person_image")
            }else{
                let url = URL(string: personsArray[indexPath.item].iconName)
                cell.imgView.kf.setImage(with: url)
            }
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GridCollectionViewCell
            
            if personsArray[indexPath.item].iconName.isEmpty {
                cell.imgView.image = UIImage(named: "ic_no_person_image")
            }else{
                let url = URL(string: personsArray[indexPath.item].iconName)
                cell.imgView.kf.setImage(with: url)
            }
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedMonster = personsArray[indexPath.item]
        delegate?.personSelected(selectedMonster)
        if let detailViewController = delegate as? CharacterDetailViewController,
            let detailNavigationController = detailViewController.navigationController {
            splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 10
        if isListView {
            return CGSize(width: width, height: 120)
        }else {
            return CGSize(width: (width - 15)/2, height: (width - 15)/2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}





