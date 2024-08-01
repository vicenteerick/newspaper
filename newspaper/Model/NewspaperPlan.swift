//
//  SubscriptionPlan.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import Foundation

struct NewspaperPlan: Decodable, Equatable {
    let id: String
    let record: Record
    let metadata: Metadata

    static var mock: Self {
        .init(id: "66a950f0e41b4d34e41961f8",
              record: .mock,
              metadata: .mock)
    }
}

struct Record: Decodable, Equatable {
    let headerLogo: URL
    let subscription: Subscription

    static var mock: Self {
        .init(headerLogo: URL(string: "https://cdn.us-corp-qa-3.vip.tnqa.net//nativeapp.www.us-corp-qa-3.tnqa.net//content//tncms//assets//v3//media//9//e0//9e0dae9e-240b-11ef-9068-000c299ccbc9//6661be72a43be.image.png?resize=762%2C174")!,
              subscription: .mock)
    }
}

struct Metadata: Decodable, Equatable {
    let name: String
    let readCountRemaining: Int
    let timeToExpire: Int
    let createdAt: String

    func hasExpired() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let createdDate = dateFormatter.date(from: createdAt) else {
            return true
        }

        let expirationDate = createdDate.addingTimeInterval(TimeInterval(timeToExpire))
        let currentDate = Date()

        return currentDate < expirationDate
    }

    static var mock: Self {
        .init(name: "",
              readCountRemaining: 2,
              timeToExpire: 69238,
              createdAt: "2024-07-31T23:00:22.775Z")
    }
}

struct Subscription: Decodable, Equatable {
    let offerPageStyle: String
    let coverImage: URL
    let subscribeTitle: String
    let subscribeSubtitle: String
    let offers: Offers
    let benefits: [String]
    let disclaimer: String

    static var mock: Self {
        .init(offerPageStyle: "square",
              coverImage: URL(string: "https://cdn.us-corp-qa-3.vip.tnqa.net/nativeapp.www.us-corp-qa-3.tnqa.net/content/tncms/assets/v3/media/8/18/818482c0-09d7-11ed-ad65-000c299ccbc9/62dac9c7602ba.image.jpg?resize=750%2C420")!,
              subscribeTitle: "Get Unlimited Access",
              subscribeSubtitle: "STLToday.com is where your story lives. Stay in the loop with unlimited access to articles, podcasts, videos and the E-edition. Plus unlock breaking news and customized real-time alerts for sports, weather, and more.",
              offers: .mock,
              benefits: ["Benefit statement 1",
                         "Benefit statement 2",
                         "Benefit statement 3"],
              disclaimer: "* Does not extend to E-edition or 3rd party websites such as obituaries, Marketplace, Jobs etc., or our content on social media platforms.\n\nBy starting your subscription, you agree to our [Terms and Conditions](https://google.com) and [Privacy Policy](https://facebook.com).")
    }
}

struct Offers: Decodable, Equatable {
    let id0: Offer
    let id1: Offer

    static var mock: Self {
        .init(id0: .mock(price: 35.99), id1: .mock())
    }
}

struct Offer: Decodable, Equatable {
    let price: Double
    let description: String

    static func mock(price: Double = 25.99,
                     description: String = "Billed monthly. Renews on MM/DD/YY.") -> Self {
        .init(price: price, description: description)
    }
}
