# HackerNewsAPI

HackerNewsAPI is a Swift package to get data and interact with the Hacker News website, written using Swift Concurrency (async/await).

### Features
- Get items, users and lists through the [HN Firebase API](https://github.com/HackerNews/API)
- Search stories by name through the [HN Algolia API](https://hn.algolia.com/api)
- Perform the following authenticated actions through POST requests: 
  - flag
  - upvote, downvote
  - favorite, unfavorite
  - comment

### Dependencies
- FirebaseDatabase (from [firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk))