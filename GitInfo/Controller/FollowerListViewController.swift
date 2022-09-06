//
//  FollowerListViewController.swift
//  GitInfo
//
//  Created by Srijan Kumar  on 03/09/22.
//

import UIKit

class FollowerListViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var followersSearchBar: UISearchBar!
    @IBOutlet weak var followersCollectionView: UICollectionView!
    
    private let kCellIdentifier = "FollowersCollectionViewCell"
    public var userName: String?
    private var displayFormat = "List"
    private var followerData: [UserInfo]?
    private var filteredData: [UserInfo]?
    private var urlCaller: FollowersListAPIManager?
    private var width: CGFloat?
    private var height: CGFloat?
    private var passDescription: ((String) -> Void)?
    private var pageNumber = 1
    private var refreshControl: UIRefreshControl?
    public var presentDesc: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCustomViewCell()
        setCollectionViewDelegate()
        setSearchBarDelegate()
        hideNavigationBar()
        fetchData()
        pullToRefresh()
        setButton()
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        if let userName = userName {
         presentDesc?(userName)
        }
    }
    
    @IBAction func toggleButton(_ sender: Any) {
        displayFormat = displayFormat == "List" ? "Grid" : "List"
        toggleButton.setTitle(displayFormat == "List" ? "Grid" : "List" , for: .normal)
        followersCollectionView.reloadData()
    }
    
    fileprivate func pullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetching...")
        self.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        followersCollectionView.refreshControl = self.refreshControl
        
    }
    
    @objc func refresh(sender:AnyObject) {
        pageNumber = 1
        fetchData()
        followersCollectionView.reloadData()
        self.refreshControl!.endRefreshing()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        followersCollectionView.reloadData()
    }
    
    private func registerCustomViewCell(){
        let nib = UINib(nibName: "FollowersCollectionViewCell", bundle: nil)
        followersCollectionView.register(nib, forCellWithReuseIdentifier: kCellIdentifier)
    }
    
    private func setCollectionViewDelegate() {
        followersCollectionView.delegate = self
        followersCollectionView.dataSource = self
    }
    
    private func setButton() {
        backButton.layer.cornerRadius = 4.0
        toggleButton.layer.cornerRadius = 4.0
        toggleButton.setTitle("Grid", for: .normal)
    }
    
    private func setSearchBarDelegate() {
        followersSearchBar.delegate = self
    }
    
    private func hideNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        followersCollectionView.reloadData()
    }
    
    private func calculateCellDimension() -> CGSize {
        if displayFormat == "List" {
            if UIDevice.current.orientation.isLandscape {
                width = followersCollectionView.bounds.width - 10.0
                height = followersCollectionView.bounds.height / 3
            } else {
                width = followersCollectionView.bounds.width - 10.0
                height = followersCollectionView.bounds.height / 6
            }
        } else {
            if UIDevice.current.orientation.isLandscape {
                width = followersCollectionView.bounds.width / 2 - 10.0
                height = followersCollectionView.bounds.height / 3
            } else {
                width = followersCollectionView.bounds.width / 2 - 10.0
                height = followersCollectionView.bounds.height / 5
            }
        }
        return CGSize(width: width ?? 0, height: height ?? 0)
    }
    
    private func fetchData() {
        urlCaller = FollowersListAPIManager()
        if let userName = userName {
            urlCaller?.fetchFollowerInfo(userName: userName, pageNumber: pageNumber)
        }
        urlCaller?.dataPassingThroughClosure = { (data) in
            if self.followerData == nil || self.pageNumber == 1 {
                self.followerData = data
                self.filteredData = data
            } else {
                if let data = data {
                    self.followerData?.append(contentsOf: data)
                    self.filteredData?.append(contentsOf: data)
                }
            }
            DispatchQueue.main.async {
                self.followersCollectionView.reloadData()
            }
        }
    }
}

extension FollowerListViewController {
    func loadImage(urlString: String?, imageView: UIImageView)  {
        if let unwrappedString = urlString,
           let url = URL(string: unwrappedString) {
            print(unwrappedString)
            
            DispatchQueue.global(qos: .background).async {
                do {
                    let imageData = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        let loadedImage = UIImage(data: imageData)
                        imageView.image = loadedImage
                        imageView.contentMode = .scaleAspectFit
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension FollowerListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = followersCollectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath) as? FollowersCollectionViewCell else{
            print("custom cell not being created")
            return UICollectionViewCell()
        }
        if let filteredData = filteredData, let id = filteredData[indexPath.row].id, let type = filteredData[indexPath.row].type, let name = filteredData[indexPath.row].login {
            cell.userId.text = "Id: \(id)"
            cell.userType.text = "Type: \(type)"
            cell.userName.text = "Name: \(name)"
        }
        cell.layer.borderWidth = 2.0
        cell.layer.cornerRadius = 10.0
        cell.layer.borderColor = UIColor.black.cgColor
        loadImage(urlString: filteredData?[indexPath.row].avatar_url, imageView: cell.userImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let descriptionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DescriptionViewController") as? DescriptionViewController{
            descriptionViewController.userName = filteredData?[indexPath.row].login
            self.navigationController?.present(descriptionViewController, animated: true)
            descriptionViewController.pushVC = { (data) in
                self.dismiss(animated: false, completion: nil)
                self.followerData?.removeAll()
                self.filteredData?.removeAll()
                self.pageNumber = 1
                self.userName = data
                self.fetchData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateCellDimension()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == (filteredData?.count ?? 0) - 4) && followersSearchBar.text == "" && (filteredData?.count ?? 0) >= 100 {
            pageNumber = pageNumber + 1
            fetchData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
}

extension FollowerListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData?.removeAll()
        var prefixString = followersSearchBar.text
        prefixString = prefixString?.lowercased()
        let sizeOfPrefix = prefixString?.count
        if followersSearchBar.text == "" {
            filteredData = followerData
        } else if sizeOfPrefix ?? 0 >= 3 {
            if let followerData = followerData, let prefixString = prefixString {
                for item in followerData {
                    if let login = item.login {
                        let subString = login.prefix(sizeOfPrefix ?? 0).lowercased()
                        if subString == prefixString {
                            filteredData?.append(item)
                        }
                    }
                }
            }
        }
        followersCollectionView.reloadData()
    }
}
