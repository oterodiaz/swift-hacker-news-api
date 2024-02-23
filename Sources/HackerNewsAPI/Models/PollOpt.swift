//
//  PollOpt.swift
//  
//
//  Created by Diego Otero on 2024-02-16.
//

import Foundation

public struct PollOpt: Decodable, Identifiable {
    /// The pollOpt's unique ID.
    public let id: ItemID
    
    /// The poll the pollOpt belongs to.
    public let poll: ItemID
    
    /// The username of the pollOpt's author.
    public let by: Username
    
    /// The pollOpt's votes.
    public let score: Int
    
    /// The pollOpt's text. Contains HTML.
    public let text: String?
    
    /// The pollOpt's creation date.
    public let time: Date
}
