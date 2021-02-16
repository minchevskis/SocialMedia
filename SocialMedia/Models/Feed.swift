//
//  Feed.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/30/20.
//

import UIKit
import Foundation

struct Feed: Codable {
    var id: String?
    var caption: String?
    var imageUrl: String?
    var creatorId: String?
    var createdAt: TimeInterval?
    var likeCount: Int?
    var shareCount: Int?
    var location: String?
}
