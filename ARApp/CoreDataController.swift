//
//  CoreDataDelegate.swift
//  ARApp
//
//  Created by Armando Falanga on 15/07/2019.
//  Copyright © 2019 Ferdinando Guarino. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class CoreDataController {
    static let shared = CoreDataController()
    
    private var context: NSManagedObjectContext
    
    private init() {
        let application = UIApplication.shared.delegate as! AppDelegate
        self.context = application.persistentContainer.viewContext
    }
    
    func save(annotation: MKAnnotation) {
        let entity = NSEntityDescription.entity(forEntityName: "Annotation", in: self.context)
        let CoreDataAnn = Annotation(entity: entity!, insertInto: context)
        
        CoreDataAnn.title = annotation.title!
        CoreDataAnn.subtitle = annotation.subtitle!
        CoreDataAnn.latitude = annotation.coordinate.latitude
        CoreDataAnn.longitude = annotation.coordinate.longitude
    }
    
    func getSavedAnnotations() -> [MKPointAnnotation]? {
        let fetchReq : NSFetchRequest<Annotation> = Annotation.fetchRequest()
        var rtrn = [MKPointAnnotation]()
        
        do {
            let array = try context.fetch(fetchReq)
            guard array.count > 0 else {print("Rip fra, 0 elementi..."); return nil;}
            for x in array {
                let newMKAnn = MKPointAnnotation()
                newMKAnn.title = x.title
                newMKAnn.subtitle = x.subtitle
                newMKAnn.coordinate.longitude = x.longitude
                newMKAnn.coordinate.latitude = x.latitude
                
                rtrn.append(newMKAnn)
            }
        } catch let err {
            print("Errore fetch \(err)")
        }
        return rtrn
    }
}
