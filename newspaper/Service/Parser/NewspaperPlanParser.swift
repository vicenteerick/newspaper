//
//  NewspaperPlanParser.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import Foundation
import CoreData

enum ParseError: Error {
    case couldNotParse(String)
}

protocol NewspaperPlanParseble {
    func parse(entity: NSManagedObject) throws -> NewspaperPlan
    func parse(object: NewspaperPlan) throws -> NSManagedObject
}

struct NewspaperPlanParser: NewspaperPlanParseble {
    let dataManager: DataManager

    func parse(entity: NSManagedObject) throws -> NewspaperPlan {
        guard let id = entity.value(forKey: "id") as? String,
              let record = entity.value(forKey: "record") as? NSManagedObject,
              let metadata = entity.value(forKey: "metadata") as? NSManagedObject else {
            throw ParseError.couldNotParse("NewspaperPlanData")
        }

        guard let headerLogo = record.value(forKey: "headerLogo") as? URL,
              let subscription = record.value(forKey: "subscription") as? NSManagedObject else {
            throw ParseError.couldNotParse("RecordData")
        }

        guard let createdAt = metadata.value(forKey: "createdAt") as? String,
              let name = metadata.value(forKey: "name") as? String,
              let readCountRemaining = metadata.value(forKey: "readCountRemaining") as? Int,
              let timeToExpire = metadata.value(forKey: "timeToExpire") as? Int else {
            throw ParseError.couldNotParse("MetadataEntity")
        }

        guard let benefits = subscription.value(forKey: "benefits") as? [String],
              let coverImage = subscription.value(forKey: "coverImage") as? URL,
              let disclaimer = subscription.value(forKey: "disclaimer") as? String,
              let offerPageStyle = subscription.value(forKey: "offerPageStyle") as? String,
              let subscribeSubtitle = subscription.value(forKey: "subscribeSubtitle") as? String,
              let subscribeTitle = subscription.value(forKey: "subscribeTitle") as? String,
              let offers = subscription.value(forKey: "offers") as? NSManagedObject else {
            throw ParseError.couldNotParse("SubscriptionData")
        }

        guard let offerId0 = offers.value(forKey: "id0") as? NSManagedObject,
              let offerId1 = offers.value(forKey: "id1") as? NSManagedObject else {
            throw ParseError.couldNotParse("OffersData")
        }

        guard let offerDescription0 = offerId0.value(forKey: "offerDescription") as? String,
              let offerPrice0 = offerId0.value(forKey: "price") as? Double else {
            throw ParseError.couldNotParse("OfferDataId0")
        }

        guard let offerDescription1 = offerId1.value(forKey: "offerDescription") as? String,
              let offerPrice1 = offerId1.value(forKey: "price") as? Double else {
            throw ParseError.couldNotParse("OfferDataId1")
        }

        return NewspaperPlan(
            id: id,
            record: Record(
                headerLogo: headerLogo,
                subscription: Subscription(
                    offerPageStyle: offerPageStyle,
                    coverImage: coverImage,
                    subscribeTitle: subscribeTitle,
                    subscribeSubtitle: subscribeSubtitle,
                    offers: Offers(
                        id0: Offer(
                            price: offerPrice0,
                            description: offerDescription0),
                        id1: Offer(
                            price: offerPrice1,
                            description: offerDescription1)
                    ),
                    benefits: benefits,
                    disclaimer: disclaimer)), 
            metadata: Metadata(
                name: name,
                readCountRemaining: readCountRemaining,
                timeToExpire: timeToExpire,
                createdAt: createdAt))
    }

    func parse(object: NewspaperPlan) throws -> NSManagedObject {
        let offerData0 = try dataManager.get(entity: .offerData)
        offerData0.setValue(object.record.subscription.offers.id0.description, forKey: "offerDescription")
        offerData0.setValue(object.record.subscription.offers.id0.price, forKey: "price")

        let offerData1 = try dataManager.get(entity: .offerData)
        offerData1.setValue(object.record.subscription.offers.id1.description, forKey: "offerDescription")
        offerData1.setValue(object.record.subscription.offers.id1.price, forKey: "price")

        let offersData = try dataManager.get(entity: .offersData)
        offersData.setValue(offerData0, forKey: "id0")
        offersData.setValue(offerData1, forKey: "id1")

        let subscriptionData = try dataManager.get(entity: .subscriptionData)
        subscriptionData.setValue(object.record.subscription.benefits, forKey: "benefits")
        subscriptionData.setValue(object.record.subscription.coverImage, forKey: "coverImage")
        subscriptionData.setValue(object.record.subscription.disclaimer, forKey: "disclaimer")
        subscriptionData.setValue(object.record.subscription.offerPageStyle, forKey: "offerPageStyle")
        subscriptionData.setValue(object.record.subscription.subscribeTitle, forKey: "subscribeTitle")
        subscriptionData.setValue(object.record.subscription.subscribeSubtitle, forKey: "subscribeSubtitle")
        subscriptionData.setValue(offersData, forKey: "offers")

        let recordData = try dataManager.get(entity: .recordData)
        recordData.setValue(object.record.headerLogo, forKey: "headerLogo")
        recordData.setValue(subscriptionData, forKey: "subscription")

        let metadataEntity = try dataManager.get(entity: .metadataEntity)
        metadataEntity.setValue(object.metadata.createdAt, forKey: "createdAt")
        metadataEntity.setValue(object.metadata.name, forKey: "name")
        metadataEntity.setValue(object.metadata.readCountRemaining, forKey: "readCountRemaining")
        metadataEntity.setValue(object.metadata.timeToExpire, forKey: "timeToExpire")

        let newspaperData = try dataManager.get(entity: .newspaperData)
        newspaperData.setValue(object.id, forKey: "id")
        newspaperData.setValue(recordData, forKey: "record")
        newspaperData.setValue(metadataEntity, forKey: "metadata")

        return newspaperData
    }
}
