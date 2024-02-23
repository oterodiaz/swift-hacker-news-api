//
//  Algolia.swift
//
//
//  Created by Diego Otero on 2024-02-21.
//

import Foundation

struct AlgoliaSearchResults: Codable {
    var hits: [AlgoliaSearchHit]
}

struct AlgoliaSearchHit: Codable {
    var storyId: ItemID
}
