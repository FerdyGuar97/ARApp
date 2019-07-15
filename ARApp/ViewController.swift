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
    // Area di testo per inserire il titolo dell'annotazione
    @IBOutlet weak var titleTextField: UITextField!
    // Area di testo per inserire la descrizione dell'annotazione
    @IBOutlet weak var descriptionTextField: UITextField!
    
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
            
            if let name = alert.textFields?.first?.text {
                print("Your name: \(name)")
            }
        }))
        
        
        self.present(alert, animated: true)
        
        if titleTextField != nil { newAnnotation.title = titleTextField.text }
        else { newAnnotation.title = "Inserisci titolo" }
        if descriptionTextField != nil { newAnnotation.subtitle = descriptionTextField.text }
        else { newAnnotation.subtitle = "Inserisci descrizione" }
        mapView.addAnnotation(newAnnotation)
        print("Nuova annotazione aggiunta alla mappa")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allowGPS()
        showCurrentPosition()
        mapView.delegate = self
    }

}

