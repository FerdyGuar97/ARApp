//
//  Document+CoreDataProperties.swift
//  ARApp
//
//  Created by Armando Falanga on 17/07/2019.
//  Copyright © 2019 Ferdinando Guarino. All rights reserved.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var descrizione: String?
    @NSManaged public var annotation: Annotation?

}
