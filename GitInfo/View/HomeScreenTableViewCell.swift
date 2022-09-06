//
//  HomeScreenTableViewCell.swift
//  GitInfo
//
//  Created by Srijan Kumar  on 02/09/22.
//

import UIKit

class HomeScreenTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var gitImage: UIImageView!
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var getFollowersButton: UIButton!
    @IBOutlet weak var followerLabel: UILabel!
    
    var passDataHandler: ((String) -> Void)?
    var buttonTapHandler: (() -> Void)?
    
    @IBAction func getFollowersButton(_ sender: Any) {
        self.buttonTapHandler?()
    }
    @IBAction func profileNameTextField(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDelegate()
        setImage()
        setButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func setDelegate() {
        profileNameTextField.delegate = self
    }
    
    private func setImage() {
        gitImage.image = UIImage(named: "github_image.png")
        gitImage.contentMode = .scaleAspectFit
    }
    
    private func setButton() {
        getFollowersButton.layer.cornerRadius = 5.0
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.passDataHandler?(profileNameTextField.text!)
    }
}
