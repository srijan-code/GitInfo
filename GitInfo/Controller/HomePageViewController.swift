//
//  ViewController.swift
//  GitInfo
//
//  Created by Srijan Kumar  on 02/09/22.
//

import UIKit

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var profileSearchTableView: UITableView!
    
    var profileName = ""
    private let kCellIdentifier = "HomeScreenTableViewCell"
    private var followerListViewController: FollowerListViewController?
    private var userData: UserInfo?
    private var urlCaller: InformationPageAPIManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewDelegate()
        registerCustomViewTableCell()
    }
    
    private func registerCustomViewTableCell() {
        let nib = UINib(nibName: kCellIdentifier, bundle: nil)
        profileSearchTableView.register(nib, forCellReuseIdentifier: kCellIdentifier)
    }
    
    private func setTableViewDelegate() {
        profileSearchTableView.delegate = self
        profileSearchTableView.dataSource = self
    }
    
    private func callAPI() {
        urlCaller = InformationPageAPIManager()
        for item in profileName {
            if item == " " {
                displayAlert(title: "wrong input", message: "profile name cannot contain spaces")
            }
        }
        urlCaller?.fetchUserInfo(userName: self.profileName)
        urlCaller?.dataPassingThroughClosure = { (data) in
            self.userData = data
            if self.userData?.login == nil {
                self.displayAlert(title: "User Alert", message: "No such user Exists")
            } else {
                DispatchQueue.main.async {
                    self.descriptionScreenNavigator()
                }
            }
        }
    }
}

extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = profileSearchTableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as? HomeScreenTableViewCell else{
            print("custom cell not being created")
            return UITableViewCell()
        }
        cell.passDataHandler = {(data) in
            self.profileName = data
        }
        cell.buttonTapHandler = { [weak self] in
            if self?.profileName == "" {
                self?.displayAlert(title: "User Name", message: "Field Empty")
            } else {
                self?.callAPI()                
            }
        }
        return cell
    }
    
    func descriptionScreenNavigator() {
        if let descriptionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DescriptionViewController") as? DescriptionViewController{
            descriptionViewController.userName = self.profileName
            self.navigationController?.present(descriptionViewController, animated: false)
            descriptionViewController.pushVC = { (data) in
                self.dismiss(animated: false, completion: nil)
                if let followersViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "FollowerListViewController") as? FollowerListViewController{
                    followersViewController.userName = data
                    self.navigationController?.pushViewController(followersViewController, animated: true)
                    followersViewController.presentDesc = { (data) in
                        self.profileName = data
                        self.descriptionScreenNavigator()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.view.frame.height-150)
    }
}

extension HomePageViewController {
    private func displayAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
