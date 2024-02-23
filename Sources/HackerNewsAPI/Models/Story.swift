//
//  Story.swift
//  
//
//  Created by Diego Otero on 2024-02-16.
//

import Foundation

public struct Story: Decodable, Identifiable {
    /// The story's unique ID.
    public let id: ItemID
    
    /// The story's total comment count.
    public let descendants: Int
    
    /// The username of the story's author.
    public let by: Username
    
    /// The IDs of the story's comments, in ranked display order.
    public let kids: [ItemID]?
    
    /// The story's score.
    public let score: Int
    
    /// The story's title.
    public let title: String
    
    /// The story's URL.
    public let url: URL?
    
    /// The story's text. Contains HTML.
    public let text: String?
    
    /// The story's creation date.
    public let time: Date
}
