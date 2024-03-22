//
//  Item.swift
//  
//
//  Created by Diego Otero on 2024-02-16.
//

import Foundation

public typealias ItemID = Int

public struct Item: Codable, Identifiable, Equatable, Hashable {
    /// The item's unique id.
    public var id: ItemID
    
    /// `true` if the item is deleted.
    public var deleted: Bool?
    
    /// The type of item. One of `job`, `story`, `comment`, `poll`, or `pollopt`.
    public var type: ItemType?
    
    /// The username of the item's author.
    public var by: Username?
    
    ///Creation date of the item.
    public var time: Date?
    
    /// The comment, story or poll text. HTML.
    public var text: String?
    
    /// `true` if the item is dead.
    public var dead: Bool?
    
    /// The comment's parent: either another comment or the relevant story.
    public var parent: ItemID?
    
    /// The pollopt's associated poll.
    public var poll: ItemID?
    
    /// The ids of the item's comments, in ranked display order.
    public var kids: [ItemID]?
    
    /// The URL of the story.
    public var url: URL?
    
    /// The story's score, or the votes for a pollopt.
    public var score: Int?
    
    /// The title of the story, poll or job. HTML.
    public var title: String?
    
    /// A list of related pollopts, in display order.
    public var parts: [ItemID]?
    
    /// In the case of stories or polls, the total comment count.
    public var descendants: Int?
    
    public init(
        id: ItemID,
        deleted: Bool? = nil,
        type: ItemType? = nil,
        by: Username? = nil,
        time: Date? = nil,
        text: String? = nil,
        dead: Bool? = nil,
        parent: ItemID? = nil,
        poll: ItemID? = nil,
        kids: [ItemID]? = nil,
        url: URL? = nil,
        score: Int? = nil,
        title: String? = nil,
        parts: [ItemID]? = nil,
        descendants: Int? = nil
    ) {
        self.id = id
        self.deleted = deleted
        self.type = type
        self.by = by
        self.time = time
        self.text = text
        self.dead = dead
        self.parent = parent
        self.poll = poll
        self.kids = kids
        self.url = url
        self.score = score
        self.title = title
        self.parts = parts
        self.descendants = descendants
    }
}
