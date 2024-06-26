//
//  Algolia.swift
//
//
//  Created by Diego Otero on 2024-02-21.
//

import Foundation

public enum SearchType {
    case exactMatch, mostRecent
}

struct AlgoliaSearchResults: Codable {
    var hits: [AlgoliaSearchHit]
}

struct AlgoliaComment: Codable {
    var storyID: ItemID
    
    enum CodingKeys: String, CodingKey {
        case storyID = "storyId"
    }
}

struct AlgoliaSearchHit: Codable {
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "objectID"
    }
}
