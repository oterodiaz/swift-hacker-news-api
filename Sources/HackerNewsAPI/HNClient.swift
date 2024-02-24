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
    private var decoder = JSONDecoder()
    
    private let hnURL = URL(string: "https://news.ycombinator.com")!
    private let algoliaURL = URL(string: "https://hn.algolia.com/api/v1/search")!
    
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
    }
    
    private func get<T: Decodable>(path: String) async throws -> T {
        Logger.network.info("Getting data from \(self.ref.url)/\(path, privacy: .private(mask: .hash))")
        let snapshot = try await ref.child(path).getData()
        
        guard
            let data = snapshot.data,
            let result = try? decoder.decode(T.self, from: data)
        else {
            Logger.network.error("Failed to decode data into '\(String(describing: T.self))' (\(self.ref.url)/\(path, privacy: .private(mask: .hash))")
            throw URLError(.cannotDecodeRawData)
        }
        
        return result
    }
    
    public func getItems(_ itemIDs: [ItemID]) async -> [Item] {
        await withTaskGroup(of: Item?.self) { group -> [Item] in
            for itemID in itemIDs {
                group.addTask { try? await self.getItem(itemID) }
            }
            
            let result = await group.reduce(into: [Item]()) { result, element in
                if let element {
                    result.append(element)
                }
            }
            
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
        
        return await getItems(itemIDs)
    }
    
    public func search(_ query: String) async throws -> [Item] {
        var components = URLComponents(url: algoliaURL, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            .init(name: "query", value: query),
            .init(name: "tags", value: "story")
        ]
        
        guard let url = components?.url else { throw URLError(.badURL) }
        
        Logger.network.info("Searching for \"\(query, privacy: .private(mask: .hash))\"")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (200...299).contains((response as! HTTPURLResponse).statusCode) else { return [] }
        let itemIDs = try decoder.decode(AlgoliaSearchResults.self, from: data).hits.map { $0.storyId }
        
        return await getItems(itemIDs)
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
        
        // We bypass the need to provide an authentication token (that would require web scraping)
        // by logging in and performing the action (if any) at the same time.
        logOut()
        
        let (_, response) = try await URLSession.shared.data(for: request)
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
