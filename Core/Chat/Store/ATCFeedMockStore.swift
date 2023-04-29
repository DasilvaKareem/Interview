//
//  ATCFeedMockStore.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 07/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCFeedMockStore {
    
    static let post = [
        
//        ATCPost(postUserName: "Craig Fedherighi", postText: "The new iOS 13 is the best release ever. It has dark mode. A feature many people wanted.", postLikes: 756, postComment: "243", postMedia: ["https://www.imore.com/sites/imore.com/files/field/image/2014/03/topic_craig_federighi.png"], profileImage: "https://www.imore.com/sites/imore.com/files/field/image/2014/03/topic_craig_federighi.png", createdAt: Date(), authorID: "", location: "San Francisco", id: "1", longitude: 0, latitude: 0),
//
//       ATCPost(postUserName: "Tim Cook", postText: "The new mac pro is made for professionals. The 6K monitor is a beautiful peice of technology. And to make it simpler for eveyone, we have priced it at 6000$. 6k - 6000 get it!. Okay how are you all this is just random text", postLikes: 56, postComment: "867", postMedia: ["https://pbs.twimg.com/profile_images/1035649273721847809/B0f8n_oe_400x400.jpg", "https://pbs.twimg.com/profile_images/1035649273721847809/B0f8n_oe_400x400.jpg"] , profileImage: "https://pbs.twimg.com/profile_images/1035649273721847809/B0f8n_oe_400x400.jpg", createdAt: Date(), authorID: "", location: "San Francisco", id: "2", longitude: 0, latitude: 0),
//
//       ATCPost(postUserName: "Jony Ive", postText: "Sir Jonathan Paul Jony Ive, KBE, HonFREng, RDI is a British industrial designer who is currently serving as the Chief Design Officer of Apple and Chancellor of the Royal College of Art in London. He joined Apple in 1992.Sir Jonathan Paul Jony Ive, KBE, HonFREng, RDI is a British industrial designer who is currently serving as the Chief Design Officer of Apple and Chancellor of the Royal College of Art in London. He joined Apple in 1992.Sir Jonathan Paul Jony Ive, KBE, HonFREng, RDI is a British industrial designer who is currently serving as the Chief Design Officer of Apple and Chancellor of the Royal College of Art in London.", postLikes: 13, postComment: "242", postMedia:  ["https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/11/02/13/jonyive.jpg", "https://pbs.twimg.com/profile_images/1035649273721847809/B0f8n_oe_400x400.jpg"], profileImage: "https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/11/02/13/jonyive.jpg", createdAt: Date(), authorID: "", location: "San Francisco", id: "3", longitude: 0, latitude: 0),
//
//       ATCPost(postUserName: "Phil Schiller", postText: "The new mac pro is made for professionals. The 6K monitor is a beautiful peice of technology. And to make it simpler for eveyone, we have priced it at 6000$. 6k - 6000 get it!. Okay I am more of a hardware person.The new mac pro is made for professionals. The 6K monitor is a beautiful peice of technology. And to make it simpler for eveyone, we have priced it at 6000$. 6k - 6000 get it!. Okay I am more of a hardware person. ", postLikes: 233, postComment: "243", postMedia: [], profileImage: "https://image.cnbcfm.com/api/v1/image/103700007-GettyImages-154624465.jpg", createdAt: Date(), authorID: "", location: "San Francisco", id: "4", longitude: 0, latitude: 0),
//
//       ATCPost(postUserName: "Craig Fedherighi", postText: "The new iOS 13 is the best release ever. It has dark mode. A feature many people wanted.", postLikes: 10, postComment: "932", postMedia: ["https://pbs.twimg.com/profile_images/1085351371380019205/LdKUOJTz.jpg", "https://image.cnbcfm.com/api/v1/image/103700007-GettyImages-154624465.jpg","https://pbs.twimg.com/profile_images/1035649273721847809/B0f8n_oe_400x400.jpg" ], profileImage: "https://www.imore.com/sites/imore.com/files/field/image/2014/03/topic_craig_federighi.png", createdAt: Date(), authorID: "", location: "San Francisco", id: "5",longitude: 0, latitude: 0),
//
//       ATCPost(postUserName: "Scott Forestall", postText: "Remeber me bros?", postLikes: 34, postComment: "24", postMedia: [], profileImage: "https://pbs.twimg.com/profile_images/1085351371380019205/LdKUOJTz.jpg", createdAt: Date(), authorID: "", location: "San Francisco", id: "6", longitude: 0, latitude: 0),
//
//       ATCPost(postUserName: "Tim Cook", postText: "Today we launched iPad Pro?", postLikes: 43, postComment: "24", postMedia:  ["https://pbs.twimg.com/profile_images/1035649273721847809/B0f8n_oe_400x400.jpg"], profileImage: "https://pbs.twimg.com/profile_images/1035649273721847809/B0f8n_oe_400x400.jpg", createdAt: Date(), authorID: "", location: "San Francisco", id: "7", longitude: 0, latitude: 0)
        
        
        ATCPost(postUserName: "Tim Cook", postText: "Today we launched iPad Pro and a whole new Mac Pro", postLikes: 23, postComment: 32, postMedia: ["https://pbs.twimg.com/profile_images/1035649273721847809/B0f8n_oe_400x400.jpg"], profileImage: "https://pbs.twimg.com/profile_images/1035649273721847809/B0f8n_oe_400x400.jpg", createdAt: Date(), authorID: "1", location: "San Francisco", id: "7", latitude: 0.0, longitude: 0.0, postReactions: [:], selectedReaction: "like", postVideoPreview: [], postVideo: [])
       
    ]
    
    
    
    static let userStory = [ATCStory(storyType: "image", storyMediaURL: "https://papers.co/wallpaper/papers.co-nu46-lake-mountain-water-dark-nature-34-iphone6-plus-wallpaper.jpg", storyAuthorID: "1", createdAt: Date()),
                            ATCStory(storyType: "video", storyMediaURL: "https://exploringswift.com/wp-content/uploads/2019/06/Superb_sunset.mp4", storyAuthorID: "1", createdAt: Date()),
                            ATCStory(storyType: "image", storyMediaURL: "https://papers.co/wallpaper/papers.co-np32-mountain-wood-night-dark-river-nature-blue-41-iphone-wallpaper.jpg", storyAuthorID: "1", createdAt: Date()),
                            ATCStory(storyType: "image", storyMediaURL: "https://papers.co/wallpaper/papers.co-nu46-lake-mountain-water-dark-nature-34-iphone6-plus-wallpaper.jpg", storyAuthorID: "1", createdAt: Date()),
                            ATCStory(storyType: "video", storyMediaURL: "https://exploringswift.com/wp-content/uploads/2019/06/Hway.mp4", storyAuthorID: "1", createdAt: Date()),
               ATCStory(storyType: "image", storyMediaURL: "https://papers.co/wallpaper/papers.co-np32-mountain-wood-night-dark-river-nature-blue-41-iphone-wallpaper.jpg", storyAuthorID: "1", createdAt: Date()),
               ATCStory(storyType: "image", storyMediaURL: "https://i.pinimg.com/originals/fc/9c/de/fc9cde38bc5b9804f334a100358bbd45.jpg", storyAuthorID: "1", createdAt: Date())
    ]
    
    static let commentMock = [ATCComment(commentAuthorUsername: "Osama Naeem", commentAuthorProfilePicture: "https://pbs.twimg.com/profile_images/1035649273721847809/B0f8n_oe_400x400.jpg", commentText: "This is just a test comment just to see how well it show sup in twwelwkjwwjel", createdAt: Date())]
  
}
