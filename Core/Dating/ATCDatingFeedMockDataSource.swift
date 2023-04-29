//
//  DatingFeedMockDataSource.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCDatingFeedMockDataSource: ATCDatingFeedDataSource {
    static let photos = ["https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/48928977_10161315701405381_4556391724695420928_n.jpg?_nc_cat=108&_nc_log=1&_nc_oc=AQn3EBe5qaFBQzBR2lNTJjpw43LMNDz-Porz68s5Q7Xwm9_WoJOIhL4LEZFhzcYyfBGv2sPIiYSc6n8WgC7K62mh&_nc_ht=scontent-sjc3-1.xx&oh=3bc05649fa50c9ada2dea724756b4494&oe=5CB32B6C",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/50084472_10161355249865381_2738187877656559616_n.jpg?_nc_cat=110&_nc_log=1&_nc_oc=AQnyoZJgOc4QH_JqnZHVF_s8XXDfuxw8pqOAUVb-oD6TRmE9zDasTjOfL4jEGriCd_8gM-c-RU1Czf5VpW5Q3zCI&_nc_ht=scontent-sjc3-1.xx&oh=99c3aae641ab2426d70571fc386f5c94&oe=5D00DFC5",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/48384654_10161299187740381_5742144113931714560_n.jpg?_nc_cat=104&_nc_log=1&_nc_oc=AQldw-sRJzft3pAvaEP2siM2eY_3c3TefTHjECy4Kcl12yQe-CDVOvK5aBouzhSJBw-Mc_Yhj5OyDAE6i_5ymZZq&_nc_ht=scontent-sjc3-1.xx&oh=c37664ff1011889229f77faa8fdd8f11&oe=5CBDBE0D",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/47576121_10161270692915381_7060972641745633280_n.jpg?_nc_cat=101&_nc_log=1&_nc_oc=AQmFaBt7wRA9fJUjxABFb7ZTJd90CpiPhgvi9BolX9XyeYvypq-A_FMfbKxQ_NQ36ZNRijkoeVmGo31W5bqKk1Vg&_nc_ht=scontent-sjc3-1.xx&oh=8cf90135eb30470e4137d2155835b05c&oe=5CB53D67",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/46473252_10161196532865381_6109672016002940928_n.jpg?_nc_cat=102&_nc_log=1&_nc_oc=AQlx8mjIGN-QpEmxYW7zDOgXCTpvtqqf7Wbh6_IofCiSFRVpYpCBPf9zDfdu0lawGF7wagoRbCXkInAcwizBRnfz&_nc_ht=scontent-sjc3-1.xx&oh=0bc691918a8df7c2ed4c004c9e06b90d&oe=5CB3210C",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/44750656_10161098840090381_3358904857741230080_n.jpg?_nc_cat=106&_nc_log=1&_nc_oc=AQlQMsQLO3M_a2Fo0meZR7FR7udeqSYLgmfrUygDYFfJTRFq6h2eEOO2n9ZR_TMCrJfwlQhtEqioKOPiTnnR4LEP&_nc_ht=scontent-sjc3-1.xx&oh=4f282c8835a8c50940e049bf9d8d2710&oe=5CB358D3",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/43877775_10161054252600381_6379536051140034560_n.jpg?_nc_cat=111&_nc_log=1&_nc_oc=AQl3fqyZOL3iVuKn57VUBlWawebRRAW1A7lp3JMteHsowrQJ3hZenlqUdjVoeMq3nasHpGUfmmkeQIoJxPH3Ef9l&_nc_ht=scontent-sjc3-1.xx&oh=ecdddfedb086e59ca066a0163366f433&oe=5CBE0220",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/42123611_10160974151575381_611038511801303040_n.jpg?_nc_cat=102&_nc_log=1&_nc_oc=AQnCWlPyNdi8rHDZ4WQj0LwQvUfPjVO6IwlUliBBI1PYQtUoR7xBi4XQmExcJbxsRAMp06T79qAbf0azCfmqbdlI&_nc_ht=scontent-sjc3-1.xx&oh=70bd89822bce73c591a1153eb47991c5&oe=5CB41D3E",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/39580572_10160855647020381_2222018527634653184_n.jpg?_nc_cat=104&_nc_log=1&_nc_oc=AQmex7Q8bdEj7zqxq7kiTc7cN7LrCCwYl5CuUlHXzuNZ3rabZ88NfnYLmJKfnCtbCbkoFFHz6_JSt-Z1dy2MIIyX&_nc_ht=scontent-sjc3-1.xx&oh=680e53700a62a904b4f65795f73754f2&oe=5CC39ED6",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/37994125_10160768835790381_5462673164666404864_n.jpg?_nc_cat=107&_nc_log=1&_nc_oc=AQkpvEjv3wPAsQIayrlJgb4eVt-HUOhTJIGvqoXHUFy2cTlm5WfvH-b1np1b4fZmyFKC-QUJZOqm8bQey-iJ3CpD&_nc_ht=scontent-sjc3-1.xx&oh=d8c6f8640ac45bfa0bafac06f1211e62&oe=5CF911EB",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/37205465_10160716922470381_6044027362188722176_n.jpg?_nc_cat=103&_nc_log=1&_nc_oc=AQnQQGrd71HHpI3qHpt1be84rww3A6JpO17lHeIK7Q6W2_G-rUg1ma5wAT6txFHCL7cM6rjJsD1IoJD9KnXehUZa&_nc_ht=scontent-sjc3-1.xx&oh=c6022e33817338901efa5deee20bc4ec&oe=5CCC82A9",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/34875709_10160572227135381_3999028845121372160_n.jpg?_nc_cat=105&_nc_log=1&_nc_oc=AQkBz3JQXnK7lQo1UDeEELOysKNIU_ChbROAlhwA04wjsamq_CouVao0pYotZkcz4-_6iIwsP6pSrH7fz4gHSTzU&_nc_ht=scontent-sjc3-1.xx&oh=38bb7e7c4710f2fed302dd9315defe95&oe=5CC511F3",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/33311780_10160504674900381_3133275974980861952_n.jpg?_nc_cat=103&_nc_log=1&_nc_oc=AQnchxuP_DUMdfKnKTq0oOBoWE39nODLsbb2dj0ZWRbfmAJ1I8g6gPb642n7dK7BHypKk53TnvqMPAzkpllSS3rz&_nc_ht=scontent-sjc3-1.xx&oh=c39c7ea81ebe136b0664b6c6041d05a9&oe=5CC4C257",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/31389379_10160407656335381_4324969405493634862_n.jpg?_nc_cat=100&_nc_log=1&_nc_oc=AQnID-joAU90v7rup3uMcNBhLZIb8NhtI3sN2d64QN4GzBWitBNOo-leidLhFM15itX-_pjpUk0pUB7nn94Vuez_&_nc_ht=scontent-sjc3-1.xx&oh=1acfccf9872a03c0a735d3901d127e84&oe=5CB32036",
                         "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/28377694_10160107115400381_3052584311869923514_n.jpg?_nc_cat=108&_nc_log=1&_nc_oc=AQmNOdjI-m6vcVuYJDspjmq9dmZFGx5I94GSHERoKgO3njpxc9dhxbEsk81V9J4D-40EvJjQ5PRRvintFncF-e7i&_nc_ht=scontent-sjc3-1.xx&oh=fb16fc79489f4d323a303ae621513f38&oe=5CF6ED62"]
    static let mockProfiles = [ATCDatingProfile(uid: "0000aaaabcdating",
                                                firstName: "Anna",
                                                lastName: "",
                                                avatarURL: "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/48928977_10161315701405381_4556391724695420928_n.jpg?_nc_cat=108&_nc_log=1&_nc_oc=AQn3EBe5qaFBQzBR2lNTJjpw43LMNDz-Porz68s5Q7Xwm9_WoJOIhL4LEZFhzcYyfBGv2sPIiYSc6n8WgC7K62mh&_nc_ht=scontent-sjc3-1.xx&oh=3bc05649fa50c9ada2dea724756b4494&oe=5CB32B6C",
                                                school: "University of San Francisco",
                                                distance: "1 mile away",
                                                photos: ATCDatingFeedMockDataSource.photos,
                                                instagramPhotos: ATCDatingFeedMockDataSource.photos,
                                                age: "19",
                                                email: "test@tes.com",
                                                bio: "Moved from the East Coast & just want to meet some new people.",
                                                gender: "Male",
                                                genderPreference: "Female",
                                                locationPreference: "50 miles",
                                                pushToken: "cwMoTGKRRdE:APA91bFKoyWz9i2yW0UMRYT9bhe8wjZiPdj4v6h9pk-1uWEiUfNrEn6P3eisaJyiFxBqA1KPPaotqQT4WxgZ36PkkJeV2nT6AUdnqXu7x79jchp8f6j4geo_4GdXExvVaba9X50j884M",
                                                isOnline: false),
                               ATCDatingProfile(uid: "0000aaaabcdating",
                                                firstName: "Christina",
                                                lastName: "",
                                                avatarURL: "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/13103374_10153556993626027_3538065589395491871_n.jpg?_nc_cat=104&_nc_log=1&_nc_oc=AQnPN96GZm983kunNYLhUYEn06iV6bvsiZeXFdGmDbToI1I53CQ4I3S6iHqrWPatc6JYchJ6cKMcRlnUdvjvIuAA&_nc_ht=scontent-sjc3-1.xx&oh=5328972ec063939d1026919e42d4c452&oe=5CB33844",
                                                school: "UCLA",
                                                distance: "5 miles away",
                                                photos: ["https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/13103374_10153556993626027_3538065589395491871_n.jpg?_nc_cat=104&_nc_log=1&_nc_oc=AQnPN96GZm983kunNYLhUYEn06iV6bvsiZeXFdGmDbToI1I53CQ4I3S6iHqrWPatc6JYchJ6cKMcRlnUdvjvIuAA&_nc_ht=scontent-sjc3-1.xx&oh=5328972ec063939d1026919e42d4c452&oe=5CB33844"],
                                                instagramPhotos: ATCDatingFeedMockDataSource.photos,
                                                age: "24",
                                                email: "test@tes.com",
                                                bio: "Moved from the East Coast & just want to meet some new people.",
                                                gender: "Male",
                                                genderPreference: "Female",
                                                locationPreference: "50 miles",
                                                pushToken: "cwMoTGKRRdE:APA91bFKoyWz9i2yW0UMRYT9bhe8wjZiPdj4v6h9pk-1uWEiUfNrEn6P3eisaJyiFxBqA1KPPaotqQT4WxgZ36PkkJeV2nT6AUdnqXu7x79jchp8f6j4geo_4GdXExvVaba9X50j884M",
                                                isOnline: false),
                               ATCDatingProfile(uid: "0000aaaabcdating",
                                                firstName: "Mary",
                                                lastName: "",
                                                avatarURL: "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/17362014_10154344097956027_1233766330534117256_n.jpg?_nc_cat=107&_nc_log=1&_nc_oc=AQkcI-mY1pBXPwnXSgFUFIG61-N0S-ebk2UazsWDdCMfdTKs1RkMCHyz0hCpQlPTeAGyg3ifB1iAgq2MKDz_Y6U0&_nc_ht=scontent-sjc3-1.xx&oh=465d482ba3427823de2e2d8888a7acb7&oe=5CB86283",
                                                school: "Stanford University",
                                                distance: "4 miles away",
                                                photos: ["https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/17362014_10154344097956027_1233766330534117256_n.jpg?_nc_cat=107&_nc_log=1&_nc_oc=AQkcI-mY1pBXPwnXSgFUFIG61-N0S-ebk2UazsWDdCMfdTKs1RkMCHyz0hCpQlPTeAGyg3ifB1iAgq2MKDz_Y6U0&_nc_ht=scontent-sjc3-1.xx&oh=465d482ba3427823de2e2d8888a7acb7&oe=5CB86283"],
                                                instagramPhotos: ATCDatingFeedMockDataSource.photos,
                                                age: "27",
                                                email: "test@tes.com",
                                                bio: "Moved from the East Coast & just want to meet some new people.",
                                                gender: "Male",
                                                genderPreference: "Female",
                                                locationPreference: "50 miles",
                                                pushToken: "cwMoTGKRRdE:APA91bFKoyWz9i2yW0UMRYT9bhe8wjZiPdj4v6h9pk-1uWEiUfNrEn6P3eisaJyiFxBqA1KPPaotqQT4WxgZ36PkkJeV2nT6AUdnqXu7x79jchp8f6j4geo_4GdXExvVaba9X50j884M",
                                                isOnline: false),
                               ATCDatingProfile(uid: "0000aaaabcdating",
                                                firstName: "Ariana",
                                                lastName: "",
                                                avatarURL: "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/17021946_10154297487971027_1950093192812613595_n.jpg?_nc_cat=105&_nc_log=1&_nc_oc=AQlsnZ9fRBhJ7DpYnBq5fxcjRSTWETVJ46nHDm6LmRf5l5YvHtm2HfG0HM5SoJx0Bh_ckTcP1N2dD4sryfqCJerw&_nc_ht=scontent-sjc3-1.xx&oh=bc158eec835f97af63c6c1401d65227f&oe=5CEEE03A",
                                                school: "Berkeley",
                                                distance: "31 miles away",
                                                photos: ["https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/17021946_10154297487971027_1950093192812613595_n.jpg?_nc_cat=105&_nc_log=1&_nc_oc=AQlsnZ9fRBhJ7DpYnBq5fxcjRSTWETVJ46nHDm6LmRf5l5YvHtm2HfG0HM5SoJx0Bh_ckTcP1N2dD4sryfqCJerw&_nc_ht=scontent-sjc3-1.xx&oh=bc158eec835f97af63c6c1401d65227f&oe=5CEEE03A"],
                                                instagramPhotos: ATCDatingFeedMockDataSource.photos,
                                                age: "18",
                                                email: "test@tes.com",
                                                bio: "Moved from the East Coast & just want to meet some new people.",
                                                gender: "Male",
                                                genderPreference: "Female",
                                                locationPreference: "50 miles",
                                                pushToken: "cwMoTGKRRdE:APA91bFKoyWz9i2yW0UMRYT9bhe8wjZiPdj4v6h9pk-1uWEiUfNrEn6P3eisaJyiFxBqA1KPPaotqQT4WxgZ36PkkJeV2nT6AUdnqXu7x79jchp8f6j4geo_4GdXExvVaba9X50j884M",
                                                isOnline: false),
                               ATCDatingProfile(uid: "0000aaaabcdating",
                                                firstName: "Jennifer",
                                                lastName: "",
                                                avatarURL: "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/16003020_10154178173291027_3108301655622996559_n.jpg?_nc_cat=101&_nc_log=1&_nc_oc=AQmGAkZmkfEFzLsW1IjgqpAm16cYpdIFJaQwWDISYqxx_tWFhv-LAkz_7979Flhiozoz7qC-2s8z703ujFgzC3CW&_nc_ht=scontent-sjc3-1.xx&oh=746b278346ff76643a1df50e6d24ac22&oe=5CFB3691",
                                                school: "University of San Francisco",
                                                distance: "3 miles away",
                                                photos: ["https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/16003020_10154178173291027_3108301655622996559_n.jpg?_nc_cat=101&_nc_log=1&_nc_oc=AQmGAkZmkfEFzLsW1IjgqpAm16cYpdIFJaQwWDISYqxx_tWFhv-LAkz_7979Flhiozoz7qC-2s8z703ujFgzC3CW&_nc_ht=scontent-sjc3-1.xx&oh=746b278346ff76643a1df50e6d24ac22&oe=5CFB3691"],
                                                instagramPhotos: ATCDatingFeedMockDataSource.photos,
                                                age: "25",
                                                email: "test@tes.com",
                                                bio: "Moved from the East Coast & just want to meet some new people.",
                                                gender: "Male",
                                                genderPreference: "Female",
                                                locationPreference: "50 miles",
                                                pushToken: "cwMoTGKRRdE:APA91bFKoyWz9i2yW0UMRYT9bhe8wjZiPdj4v6h9pk-1uWEiUfNrEn6P3eisaJyiFxBqA1KPPaotqQT4WxgZ36PkkJeV2nT6AUdnqXu7x79jchp8f6j4geo_4GdXExvVaba9X50j884M",
                                                isOnline: false)
                               ]

    var viewer: ATCDatingProfile? = nil
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?

    func object(at index: Int) -> ATCGenericBaseModel? {
        return ATCDatingFeedMockDataSource.mockProfiles[index%5]
    }

    func numberOfObjects() -> Int {
        return 100
    }

    func loadFirst() {
        self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: [])
    }

    func loadBottom() {
        self.delegate?.genericCollectionViewControllerDataSource(self, didLoadBottom: [])
    }

    func loadTop() {
        self.delegate?.genericCollectionViewControllerDataSource(self, didLoadTop: [])
    }
}
