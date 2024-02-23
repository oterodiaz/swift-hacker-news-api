//
//  DataSnapshot.swift
//
//
//  Created by Diego Otero on 2024-02-21.
//

import Firebase
import Foundation

public extension DataSnapshot {
    // TODO: This could exclude certain comments. Investigate.
    var data: Data? {
        guard
            let value = self.value,
            JSONSerialization.isValidJSONObject(value),
            let data = try? JSONSerialization.data(withJSONObject: value)
        else { return nil }
        
        return data
    }
}
