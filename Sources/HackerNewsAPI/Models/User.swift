//
//  User.swift
//  
//
//  Created by Diego Otero on 2024-02-16.
//

import Foundation

public typealias Username = String

public struct User: Codable, Identifiable, Equatable, Hashable {
    /// The user's unique username.
    public let id: Username
    
    /// The user's account creation date.
    public let created: Date
    
    /// The user's karma.
    public let karma: Int
    
    /// The user's self-description. Contains HTML.
    public let about: String?
    
    /// List of the user's submitted stories, polls and comments.
    public let submitted: [ItemID]
}
