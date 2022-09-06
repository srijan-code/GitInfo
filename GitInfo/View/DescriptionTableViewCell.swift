//
//  DescriptionTableViewCell.swift
//  GitInfo
//
//  Created by Srijan Kumar  on 02/09/22.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var loginName: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var getFollowerButton: UIButton!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var detailView: UIView!
    
    var navigateToFollowersHandler: (() -> Void)?
    
    @IBAction func getFollowerButton(_ sender: Any) {
        navigateToFollowersHandler?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setImage()
        setView()
        setButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setButton() {
        getFollowerButton.layer.cornerRadius = 10.0
    }
    
    private func setView() {
        detailView.layer.cornerRadius = 10.0
    }
    
    private func setImage() {
        profileImage.layer.cornerRadius = 5.0
    }
}
