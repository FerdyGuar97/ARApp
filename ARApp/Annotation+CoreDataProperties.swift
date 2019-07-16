//
//  Annotation+CoreDataProperties.swift
//  ARApp
//
//  Created by Armando Falanga on 15/07/2019.
//  Copyright © 2019 Ferdinando Guarino. All rights reserved.
//
//

import Foundation
import CoreData


extension Annotation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Annotation> {
        return NSFetchRequest<Annotation>(entityName: "Annotation")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var uuid: UUID
}
