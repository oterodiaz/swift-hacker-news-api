//
//  Job.swift
//  
//
//  Created by Diego Otero on 2024-02-16.
//

import Foundation

public struct Job: Decodable, Identifiable {
    /// The job's unique ID.
    public let id: ItemID
    
    /// True if the item is deleted.
    public let deleted: Bool?

    /// True if the item is dead.
    public let dead: Bool?

    /// The username of the job poster.
    public let by: Username
    
    /// The job's title.
    public let title: String
    
    /// The job's URL.
    public let url: URL?
    
    /// The job's text. Contains HTML.
    public let text: String?
    
    /// The job's creation date.
    public let time: Date
}

