//
//  DataManager.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import Foundation
import CoreData

enum DataManagerError: Error {
    case entityNotFound
    case dataNotFound
}

enum EntityType: String {
    case newspaperData = "NewspaperData"
    case offerData = "OfferData"
    case offersData = "OffersData"
    case recordData = "RecordData"
    case subscriptionData = "SubscriptionData"
    case metadataEntity = "MetadataEntity"
}

struct DataManager {
    let context: NSManagedObjectContext

    func get(entity: EntityType) throws -> NSManagedObject {
        guard let entity = NSEntityDescription.entity(forEntityName: entity.rawValue, in: context) else {
            throw DataManagerError.entityNotFound
        }

        return NSManagedObject(entity: entity, insertInto: context)
    }

    func save() throws {
        try context.save()
    }

    func fetch(entity: EntityType) throws -> NSManagedObject {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        request.returnsObjectsAsFaults = false
        let results = try context.fetch(request)

        guard let data = results.first as? NSManagedObject else {
            throw DataManagerError.dataNotFound
        }

        return data
    }

    func delete(object: NSManagedObject) throws {
        context.delete(object)
        try save()
    }
}
