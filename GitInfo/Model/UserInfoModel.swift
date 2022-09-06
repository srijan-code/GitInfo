//
//  UserInfoModel.swift
//  GitInfo
//
//  Created by Srijan Kumar  on 02/09/22.
//

import Foundation

struct UserInfo: Codable {
    let login: String?
    let name: String?
    let location: String?
    let avatar_url: String?
    let bio: String?
    let followers: Int?
    let following: Int?
    let created_at: String?
    let type: String?
    let id: Int?
}
