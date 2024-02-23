//
//  Item.swift
//  
//
//  Created by Diego Otero on 2024-02-16.
//

import Foundation

public typealias ItemID = Int

public enum Item: Decodable, Identifiable {
    case job(Job)
    case story(Story)
    case comment(Comment)
    case poll(Poll)
    case pollOpt(PollOpt)
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let selfContainer = try decoder.singleValueContainer()
        let typeContainer = try decoder.container(keyedBy: CodingKeys.self)
        let type = try typeContainer.decode(String.self, forKey: .type)
        
        switch type {
        case "job":
            self = .job(try selfContainer.decode(Job.self))
        case "story":
            self = .story(try selfContainer.decode(Story.self))
        case "comment":
            self = .comment(try selfContainer.decode(Comment.self))
        case "poll":
            self = .poll(try selfContainer.decode(Poll.self))
        case "pollOpt":
            self = .pollOpt(try selfContainer.decode(PollOpt.self))
        default:
            self = .unknown
        }
    }
    
    public var id: ItemID {
        switch self {
        case .job(let job):
            job.id
        case .story(let story):
            story.id
        case .comment(let comment):
            comment.id
        case .poll(let poll):
            poll.id
        case .pollOpt(let pollOpt):
            pollOpt.id
        case .unknown:
            -1
        }
    }
}
