//
//  Comment.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 16.12.20.
//

import Foundation

struct Comment: Codable {
    var id: String?
    var creatorId: String?
    var momentId: String?
    var createdAt: TimeInterval?
    var body: String?
}
