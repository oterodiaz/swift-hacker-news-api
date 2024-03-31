//
//  HNClient.swift
//
//
//  Created by Diego Otero on 2024-02-16.
//

import OSLog
import Firebase
import Foundation

public final class HNClient {
    public static var shared = HNClient()
    
    private var ref: DatabaseReference
    private var urlSession: URLSession
    private var decoder = JSONDecoder()
    
    private let hnURL = URL(string: "https://news.ycombinator.com")!
    private let algoliaURL = URL(string: "https://hn.algolia.com/api/v1/")!
    
    private init(firebaseOptions: FirebaseOptions? = nil) {
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // This will look for the GoogleService-Info.plist file in your project and
        // configure the database accordingly. You need to edit the file and add the
        // following key:
        //
        // <key>DATABASE_URL</key>
        // <string>https://hacker-news.firebaseio.com</string>
        if let firebaseOptions {
            FirebaseApp.configure(options: firebaseOptions)
        } else {
            FirebaseApp.configure()
        }
        
        // Configure default child `v0` since the HN database URL
        // is `https://hacker-news.firebaseio.com/v0`
        self.ref = Database.database().reference().child("v0")
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 30
        
        self.urlSession = URLSession(configuration: configuration)
    }
    
    private func get<T: Decodable>(path: String) async throws -> T {
        Logger.network.info("Getting data from \(self.ref.url)/\(path, privacy: .private(mask: .hash))")
        let snapshot = try await ref.child(path).getData()
        
        try Task.checkCancellation()
        
        guard
            let data = snapshot.data,
            let result = try? decoder.decode(T.self, from: data)
        else {
            Logger.network.error("Failed to decode data into '\(String(describing: T.self))' (\(self.ref.url)/\(path, privacy: .private(mask: .hash))")
            throw URLError(.cannotDecodeRawData)
        }
        
        try Task.checkCancellation()
        
        return result
    }
        
    public func getItems(_ itemIDs: [ItemID]) async throws -> [Item] {
        try await withThrowingTaskGroup(of: Item?.self) { group -> [Item] in
            for itemID in itemIDs {
                try Task.checkCancellation()
                let _ = group.addTaskUnlessCancelled { try? await self.getItem(itemID) }
            }
            
            try Task.checkCancellation()
            
            let result = try await group.reduce(into: [Item]()) { result, element in
                try Task.checkCancellation()
                if let element {
                    result.append(element)
                }
            }
            
            try Task.checkCancellation()
            
            return result.sorted { itemIDs.firstIndex(of: $0.id)! < itemIDs.firstIndex(of: $1.id)! }
        }
    }
        
    public func getItem(_ itemID: ItemID) async throws -> Item {
        try await get(path: "item/\(itemID)")
    }
    
    public func getUser(_ username: Username) async throws -> User {
        try await get(path: "user/\(username)")
    }
    
    public func getList(_ list: HNList) async throws -> [Item] {
        let itemIDs: [ItemID] = try await get(path: list.rawValue.lowercased())
        
        return try await getItems(itemIDs)
    }
    
    public func getListIDs(_ list: HNList) async throws -> [ItemID] {
        let itemIDs: [ItemID] = try await get(path: list.rawValue.lowercased())
        
        return itemIDs
    }

    public func getParentStoryID(ofCommentWithID commentID: ItemID) async throws -> ItemID {
        var components = URLComponents(url: algoliaURL, resolvingAgainstBaseURL: true)
        components?.path += "items/\(commentID)"
        
        guard let url = components?.url else { throw URLError(.badURL) }
        
        Logger.network.info("Getting comment with ID \(commentID, privacy: .private(mask: .hash))")
        let (data, response) = try await urlSession.data(from: url)
        guard (200...299).contains((response as! HTTPURLResponse).statusCode) else { throw URLError(.badServerResponse) }
        
        try Task.checkCancellation()
        
        let parentStoryID = try decoder.decode(AlgoliaComment.self, from: data).storyID
        
        try Task.checkCancellation()
        
        return parentStoryID
    }
    
    public func search(_ query: String, by searchType: SearchType = .exactMatch) async throws -> [Item] {
        var components = URLComponents(url: algoliaURL, resolvingAgainstBaseURL: true)
        components?.path += searchType == .exactMatch ? "search" : "search_by_date"
        components?.queryItems = [
            .init(name: "query", value: query),
            .init(name: "tags", value: "(story,poll)")
        ]
        
        guard let url = components?.url else { throw URLError(.badURL) }
        
        Logger.network.info("Searching for \"\(query, privacy: .private(mask: .hash))\"")
        let (data, response) = try await urlSession.data(from: url)
        guard (200...299).contains((response as! HTTPURLResponse).statusCode) else { return [] }
        
        try Task.checkCancellation()
        
        let itemIDs = try decoder.decode(AlgoliaSearchResults.self, from: data).hits.compactMap { Int($0.id) }
        
        try Task.checkCancellation()
        
        return try await getItems(itemIDs)
    }
    
    public func isLoggedIn() -> Bool {
        if let cookies = HTTPCookieStorage.shared.cookies(for: hnURL),
           !cookies.isEmpty {
            true
        } else {
            false
        }
    }
    
    public func logOut() {
        if let cookies = HTTPCookieStorage.shared.cookies(for: hnURL) {
            cookies.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
        }
    }
    
    private func authenticadedAction(
        path: String,
        parameters: [String: Any]
    ) async throws {
        var components = URLComponents(url: hnURL, resolvingAgainstBaseURL: true)
        components?.path = path
        
        guard let url = components?.url else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = parameters.reduce(into: [String]()) { result, parameter in
            result.append("\(parameter.key)=\(parameter.value)")
        }
        .joined(separator: "&")
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        .data(using: .utf8)
        
        try Task.checkCancellation()
        
        // We bypass the need to provide an authentication token (that would require web scraping)
        // by logging in and performing the action (if any) at the same time.
        logOut()
        
        try Task.checkCancellation()
        
        let (_, response) = try await urlSession.data(for: request)
        guard (200...299).contains((response as! HTTPURLResponse).statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    public func logIn(username: Username, password: String) async throws -> Bool {
        Logger.network.info("Performing log in request")
        try await authenticadedAction(
            path: "/login",
            parameters: [
                "goto": "news",
                "acct": username,
                "pw": password
            ]
        )
        
        return isLoggedIn()
    }
    
    public func flag(username: Username, password: String, itemID: ItemID) async throws {
        Logger.network.info("Requesting to flag item \(itemID, privacy: .private(mask: .hash))")
        try await authenticadedAction(
            path: "/flag",
            parameters: [
                "acct": username,
                "pw": password,
                "id": itemID
            ]
        )
    }
    
    public func upvote(username: Username, password: String, itemID: ItemID) async throws {
        Logger.network.info("Requesting to upvote item \(itemID, privacy: .private(mask: .hash))")
        try await authenticadedAction(
            path: "/vote",
            parameters: [
                "acct": username,
                "pw": password,
                "id": itemID,
                "how": "up"
            ]
        )
    }
    
    public func downvote(username: Username, password: String, itemID: ItemID) async throws {
        Logger.network.info("Requesting to downvote item \(itemID, privacy: .private(mask: .hash))")
        try await authenticadedAction(
            path: "/vote",
            parameters: [
                "acct": username,
                "pw": password,
                "id": itemID,
                "how": "down"
            ]
        )
    }
    
    public func unvote(username: Username, password: String, itemID: ItemID) async throws {
        Logger.network.info("Requesting to downvote item \(itemID, privacy: .private(mask: .hash))")
        try await authenticadedAction(
            path: "/vote",
            parameters: [
                "acct": username,
                "pw": password,
                "id": itemID,
                "how": "un"
            ]
        )
    }

    public func fav(username: Username, password: String, itemID: ItemID) async throws {
        Logger.network.info("Requesting to favorite item \(itemID, privacy: .private(mask: .hash))")
        try await authenticadedAction(
            path: "/fave",
            parameters: [
                "acct": username,
                "pw": password,
                "id": itemID
            ]
        )
    }
    
    
    public func unfav(username: Username, password: String, itemID: ItemID) async throws {
        Logger.network.info("Requesting to unfavorite item \(itemID, privacy: .private(mask: .hash))")
        try await authenticadedAction(
            path: "/fave",
            parameters: [
                "acct": username,
                "pw": password,
                "id": itemID,
                "un": "t"
            ]
        )
    }
    
    public func reply(username: Username, password: String, parentID: ItemID, text: String) async throws {
        Logger.network.info("Requesting to reply to item \(parentID, privacy: .private(mask: .hash))")
        try await authenticadedAction(
            path: "/comment",
            parameters: [
                "acct": username,
                "pw": password,
                "parent": parentID,
                "text": text
            ]
        )
    }
}
