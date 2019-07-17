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
    
    func saveAnnotation(_ annotation: ARAppStdPointAnnotation) {
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
        
        let predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        fetchReq.predicate = predicate;
        
        do {
            // Le prime due righe sono identiche a saveAnnotation(_:)
            let ann = try context.fetch(fetchReq)
            guard ann.count > 0 else {print("Nessuna annotazione corrispondente");return nil}
            return ann[0]
        } catch let err {
            print("Errore \(err)")
        }
        return nil;
    }
    
    // Restituisce tutte le Annotation presenti nel Core Data
    func getAnnotations() -> [Annotation] {
        let fetchReq : NSFetchRequest<Annotation> = Annotation.fetchRequest()
        
        var array = [Annotation]();
        do {
            array = try context.fetch(fetchReq)
        } catch let err {
            print("Errore fetch \(err)")
        }
        return array;
    }
    
    func deleteAnnotation(byUUID uuid: UUID) {
        if let annToDelete = getAnnotation(byUUID: uuid) {
            self.context.delete(annToDelete)
            
            do {
                try self.context.save()
            } catch let error {
                print("\(error)")
            }
        }
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
    
    func getPointAnnotations() -> [ARAppStdPointAnnotation]? {
        return getAnnotations().map {
            (a) -> ARAppStdPointAnnotation in
            let newMKAnn = ARAppStdPointAnnotation()
            newMKAnn.uuid = a.uuid
            newMKAnn.title = a.title
            newMKAnn.subtitle = a.subtitle
            newMKAnn.coordinate.longitude = a.longitude
            newMKAnn.coordinate.latitude = a.latitude
            return newMKAnn
        }
    }
    
    // Restituisce la locazione di un punto in base all'UUID (Utile per calcolare distanze)
    func getLocation(byUUID uuid: UUID) -> CLLocation? {
        if let annotation = getAnnotation(byUUID: uuid) {
            return CLLocation(latitude: annotation.latitude, longitude: annotation.longitude)
        }
        return nil;
    }
    
    // Restituisce tutte le locazioni di tutte la Annotation
    func getLocations() -> [UUID:CLLocation] {
        let anns = getAnnotations()
        var dict = [UUID:CLLocation]()
        
        for a in anns { dict[a.uuid] = CLLocation(latitude: a.latitude, longitude: a.longitude) }
        return dict
    }
    
    func getLocations(near basePoint: CLLocation, widthMaxDistance distance: Double) -> [UUID:CLLocation] {
        return getLocations().filter {
            (key,value) in
            value.distance(from: basePoint) <= distance
        }
    }
}
