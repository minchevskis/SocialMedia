//
//  Following.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 26.12.20.
//

import Foundation

struct Following: Codable {
    var id: String?
    var userId: String?
    var createdAt: TimeInterval?
}

struct Follower: Codable {
    var id: String?
    var userId: String?
    var createdAt: TimeInterval?
}
