//
//  Footwear+CoreDataProperties.swift
//  FootwearManagementApp
//
//  Created by Gilbert Andrei Floarea on 13/04/2019.
//  Copyright © 2019 Gilbert Andrei Floarea. All rights reserved.
//
//

import Foundation
import CoreData


extension Footwear {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Footwear> {
        return NSFetchRequest<Footwear>(entityName: "Footwear")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastWorn: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var photoData: NSData?
    @NSManaged public var rating: Double
    @NSManaged public var searchKey: String?
    @NSManaged public var timesWorn: Int32
    @NSManaged public var tintColor: NSObject?
    @NSManaged public var url: URL?

}
