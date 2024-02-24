//
//  Comment.swift
//  
//
//  Created by Diego Otero on 2024-02-16.
//

import Foundation

public struct Comment: Decodable, Identifiable {
    /// The comment's unique ID.
    public let id: ItemID
    
    /// The username of the story's author.
    public let by: Username

    /// The IDs of the comment's replies, in ranked display order.
    public let kids: [ItemID]?

    /// The ID of the comment's parent: either another comment or a story.
    public let parent: ItemID
    
    /// The comment's text. Contains HTML.
    public let text: String?
    
    /// The comment's creation date.
    public let time: Date
}