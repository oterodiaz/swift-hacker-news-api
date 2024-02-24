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

struct AlgoliaSearchHit: Codable {
    var storyId: ItemID
}
