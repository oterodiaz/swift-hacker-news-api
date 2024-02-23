//
//  Logger.swift
//
//
//  Created by Diego Otero on 2024-02-21.
//

import OSLog
import Foundation

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let network = Logger(subsystem: subsystem, category: "network")
}
