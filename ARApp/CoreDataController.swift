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
    
    func save(annotation: ARAppStdPointAnnotation) {
        let entity = NSEntityDescription.entity(forEntityName: "Annotation", in: self.context)
        let CoreDataAnn = Annotation(entity: entity!, insertInto: context)
        
        CoreDataAnn.uuid = annotation.uuid
        CoreDataAnn.title = annotation.title!
        CoreDataAnn.subtitle = annotation.subtitle!
        CoreDataAnn.latitude = annotation.coordinate.latitude
        CoreDataAnn.longitude = annotation.coordinate.longitude
    }
    
    func getAnnotation(byUUID uuid: UUID) -> Annotation? {
        let fetchReq : NSFetchRequest<Annotation> = Annotation.fetchRequest()
        fetchReq.returnsObjectsAsFaults = false
        
        // lf sta per long float, un normale float non permetteva di recuperare correttamente l'annotazione, da cambiare con gli ID
        let predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        fetchReq.predicate = predicate;
        
        do {
            // Le prime due righe sono identiche a save(annotation:)
            let ann = try context.fetch(fetchReq)
            guard ann.count > 0 else {print("Nessuna annotazione corrispondente");return nil}
            return ann[0]
        } catch let err {
            print("Errore \(err)")
        }
        return nil;
    }
    
    func getLocation(byUUID uuid: UUID) -> CLLocation? {
        if let annotation = getAnnotation(byUUID: uuid) {
            return CLLocation(latitude: annotation.latitude, longitude: annotation.longitude)
        }
        return nil;
    }
    
    func moveAnnotation(withUUID uuid: UUID, to point: CLLocationCoordinate2D) {
        if let annotationToMove = getAnnotation(byUUID: uuid) {
            do {
                annotationToMove.latitude = point.latitude
                annotationToMove.longitude = point.longitude
                try annotationToMove.managedObjectContext!.save()
            } catch let error {
                print("\(error)")
            }
        }
    }
    
    func getSavedAnnotations() -> [ARAppStdPointAnnotation]? {
        let fetchReq : NSFetchRequest<Annotation> = Annotation.fetchRequest()
        var rtrn = [ARAppStdPointAnnotation]()
        
        do {
            let array = try context.fetch(fetchReq)
            guard array.count > 0 else {print("Rip fra, 0 elementi..."); return nil;}
            for x in array {
                let newMKAnn = ARAppStdPointAnnotation()
                newMKAnn.uuid = x.uuid
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
