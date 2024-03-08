//
//  Item.swift
//  
//
//  Created by Diego Otero on 2024-02-16.
//

import Foundation

public typealias ItemID = Int

public enum Item: Decodable, Identifiable, Hashable {
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
    
    public static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
            UUID().hashValue
        }
    }
    
    public var deleted: Bool? {
        switch self {
        case .job(let job):
            job.deleted
        case .story(let story):
            story.deleted
        case .comment(let comment):
            comment.deleted
        case .poll(let poll):
            poll.deleted
        case .pollOpt(let pollOpt):
            pollOpt.deleted
        default:
            nil
        }
    }
    
    public var by: Username {
        switch self {
        case .job(let job):
            job.by
        case .story(let story):
            story.by
        case .comment(let comment):
            comment.by
        case .poll(let poll):
            poll.by
        case .pollOpt(let pollOpt):
            pollOpt.by
        default:
            "[unknown]"
        }
    }
    
    public var time: Date {
        switch self {
        case .job(let job):
            job.time
        case .story(let story):
            story.time
        case .comment(let comment):
            comment.time
        case .poll(let poll):
            poll.time
        case .pollOpt(let pollOpt):
            pollOpt.time
        default:
            Date.distantPast
        }
    }
    
    public var dead: Bool? {
        switch self {
        case .job(let job):
            job.dead
        case .story(let story):
            story.dead
        case .comment(let comment):
            comment.dead
        case .poll(let poll):
            poll.dead
        case .pollOpt(let pollOpt):
            pollOpt.dead
        default:
            nil
        }
    }
    
    public var parent: ItemID? {
        switch self {
        case .comment(let comment):
            comment.parent
        default:
            nil
        }
    }
    
    public var poll: ItemID? {
        switch self {
        case .pollOpt(let pollOpt):
            pollOpt.poll
        default:
            nil
        }
    }
    
    public var kids: [ItemID]? {
        switch self {
        case .story(let story):
            story.kids
        case .comment(let comment):
            comment.kids
        case .poll(let poll):
            poll.kids
        default:
            nil
        }
    }
    
    public var url: URL? {
        switch self {
        case .job(let job):
            job.url
        case .story(let story):
            story.url
        default:
            nil
        }
    }
    
    public var score: Int? {
        switch self {
        case .story(let story):
            story.score
        case .poll(let poll):
            poll.score
        case .pollOpt(let pollOpt):
            pollOpt.score
        default:
            nil
        }
    }
    
    public var title: String? {
        switch self {
        case .job(let job):
            job.title
        case .story(let story):
            story.title
        case .poll(let poll):
            poll.title
        default:
            nil
        }
    }
    
    public var text: String? {
        switch self {
        case .job(let job):
            job.text
        case .story(let story):
            story.text
        case .comment(let comment):
            comment.text
        case .poll(let poll):
            poll.text
        case .pollOpt(let pollOpt):
            pollOpt.text
        default:
            nil
        }
    }
    
    public var parts: [ItemID]? {
        switch self {
        case .poll(let poll):
            poll.parts
        default:
            nil
        }
    }
    
    public var descendants: Int? {
        switch self {
        case .story(let story):
            story.descendants
        case .poll(let poll):
            poll.descendants
        default:
            nil
        }
    }
}
