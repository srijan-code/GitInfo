//
//  FollowersCollectionViewCell.swift
//  GitInfo
//
//  Created by Srijan Kumar  on 03/09/22.
//

import UIKit

class FollowersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userType: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setImage()
    }

    private func setImage() {
        userImage.layer.cornerRadius = 25.0
    }
}
