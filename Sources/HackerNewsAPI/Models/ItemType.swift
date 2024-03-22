//
//  ItemType.swift
//
//
//  Created by Diego Otero on 2024-03-22.
//

import Foundation

public enum ItemType: String, CaseIterable, Codable {
    case comment
    case job
    case poll
    case pollopt
    case story
}
