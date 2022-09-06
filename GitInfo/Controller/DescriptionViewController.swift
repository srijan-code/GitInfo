//
//  DescriptionViewController.swift
//  GitInfo
//
//  Created by Srijan Kumar  on 02/09/22.
//

import UIKit

class DescriptionViewController: UIViewController {
    
    @IBOutlet weak var descriptionTableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    private let kCellIdentifier = "DescriptionTableViewCell"
    private var month: String = ""
    private var year: String?
    private var homeVC: HomePageViewController?
    public var pushVC: ((String) -> Void)?
    public var dismissScreen: (() -> Void)?
    let monthArray: [String:String] = ["01":"Jan", "02":"Feb", "03":"Mar", "04":"Apr", "05":"May", "06":"Jun", "07":"Jul", "08":"Aug", "09":"Sep", "10":"Oct", "11":"Nov", "12":"Dec"]
    public var userName: String?
    private var urlCaller: InformationPageAPIManager?
    private var userData: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeVC = HomePageViewController()
        setTableViewDelegate()
        callAPI()
        setButton()
        registerCustomViewTableCell()
    }
    
    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setButton() {
        doneButton.layer.cornerRadius = 5.0
    }
    
    private func registerCustomViewTableCell() {
        let nib = UINib(nibName: kCellIdentifier, bundle: nil)
        descriptionTableView.register(nib, forCellReuseIdentifier: kCellIdentifier)
    }
    
    private func setTableViewDelegate() {
        descriptionTableView.delegate = self
        descriptionTableView.dataSource = self
    }
    
    private func callAPI() {
        urlCaller = InformationPageAPIManager()
        if let userName = userName {
        urlCaller?.fetchUserInfo(userName: userName)
        }
        urlCaller?.dataPassingThroughClosure = { (data) in
            self.userData = data
            DispatchQueue.main.async {
                self.getMonthYear()
                self.descriptionTableView.reloadData()
            }
        }
    }
    
    private func getMonthYear() {
        if let userData = userData, let created = userData.created_at {
            year = String(created.prefix(4))
            month = String(created.suffix(created.count-14).prefix(6))
            month = monthArray[month] ?? "Jan"
        }
    }
}

extension DescriptionViewController {
    func loadImage(urlString: String?, imageView: UIImageView)  {
        if let unwrappedString = urlString,
           let url = URL(string: unwrappedString) {
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

extension DescriptionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = descriptionTableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as? DescriptionTableViewCell else{
            print("custom cell not being created")
            return UITableViewCell()
        }
        cell.loginName.text = userData?.login
        cell.name.text = userData?.name
        cell.desc.text = userData?.bio
        if let userData = userData, let followers = userData.followers, let following = userData.following {
            cell.followerLabel.text = "\(followers)"
            cell.followingLabel.text = "\(following)"
        }
        cell.location.text = userData?.location
        if let year = year {
        cell.createdDate.text = "On GitHub since \(month) \(year)"
        }
        loadImage(urlString: userData?.avatar_url, imageView: cell.profileImage)
        cell.navigateToFollowersHandler = { [weak self] in
            if let userName = self?.userName {
                self?.pushVC?(userName)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
