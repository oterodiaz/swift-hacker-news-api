//
//  Poll.swift
//  
//
//  Created by Diego Otero on 2024-02-16.
//

import Foundation

public struct Poll: Decodable, Identifiable {
    /// The poll's unique ID.
    public let id: ItemID
    
    /// The poll's total comment count.
    public let descendants: Int
    
    /// The username of the poll's author.
    public let by: Username
    
    /// The IDs of the poll's comments, in ranked display order.
    public let kids: [ItemID]?
    
    /// The list of related PollOpts, in display order.
    public let parts: [ItemID]
    
    /// The poll's score.
    public let score: Int
    
    /// The poll's title.
    public let title: String
    
    /// The poll's text. Contains HTML.
    public let text: String?
    
    /// The poll's creation date.
    public let time: Date
}
