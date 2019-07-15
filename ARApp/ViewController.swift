//
//  ViewController.swift
//  ARApp
//
//  Created by Ferdinando Guarino on 10/07/2019.
//  Copyright © 2019 Ferdinando Guarino. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    // Oggetto che consente di ottenere la posizione GPS del dispositivo
    var locationManager = CLLocationManager()
    
    // Valore di default per l'ampiezza della regione da visualizzare
    let regionRadius: Double = 1200
    
    // Richiesta all'utente di abilitare i permessi di geolocalizzazione
    func allowGPS() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Permette di centare la visuale sulla posizione dell'utente
    func centerPosition(regionRadius: Double) {
        /* Memorizza la posizione corrente */
        guard let coordinate = locationManager.location?.coordinate else {return}
        /* Setta il centro e la grandezza della regione da visualizzare in base a regionRadius */
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        /* Mostra la regione impostata in precedenza */
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Visualizza sulla mappa la posizione dell'utente e centra la visuale
    func showCurrentPosition() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest   // Imposto il livello di accuratezza massima
        locationManager.distanceFilter = kCLDistanceFilterNone  // Tutti i movimenti devono essere riportati
        locationManager.startUpdatingLocation() // Tiene traccia del cambiamento di posizione
        mapView.showsScale = true   // Mostra la scala della mappa nell'angolo a sinistra
        mapView.showsUserLocation = true    // Mostra la posizione dell'utente sulla mappa
        centerPosition(regionRadius: regionRadius)
    }
    
    // Crea una nuova annotazione posizionandola sulla posizione corrente dell'utente
    @IBAction func addAnnotation(_ sender: UIButton) {
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = mapView.userLocation.coordinate
        
        let alert = UIAlertController(title: "Nuova annotazione", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in textField.placeholder = "Titolo" })
        
        alert.addTextField(configurationHandler: { textField in textField.placeholder = "Descrizione" })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if alert.textFields![0].text != "" { newAnnotation.title = alert.textFields![0].text }
            else { newAnnotation.title = "Inserisci titolo" }
            if alert.textFields![1].text != "" { newAnnotation.subtitle = alert.textFields![1].text }
            else { newAnnotation.subtitle = "Inserisci descrizione" }
            
            self.mapView.addAnnotation(newAnnotation)
            print("Nuova annotazione aggiunta alla mappa")
        }))
        
        self.present(alert, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil;
        }
        
        let reuseId = "reuse"
        if let anyAnn = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) {
            anyAnn.annotation = annotation;
            return anyAnn;
        }
        
        let anyAnn = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        anyAnn.canShowCallout = true;
        anyAnn.pinTintColor  = .green
        anyAnn.isDraggable = true;
        return anyAnn;
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
        default: break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allowGPS()
        showCurrentPosition()
        mapView.delegate = self
    }

}

