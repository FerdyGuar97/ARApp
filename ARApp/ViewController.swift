//
//  ViewController.swift
//  ARApp
//
//  Created by Ferdinando Guarino on 10/07/2019.
//  Copyright © 2019 Ferdinando Guarino. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import ARKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var arViewController : ARViewController?
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var positionButton: UIButton!
    @IBOutlet weak var ARbtn: UIButton!
    
    
    // Oggetto che consente di ottenere la posizione GPS del dispositivo
    var locationManager = CLLocationManager()
    
    // Valore di default per l'ampiezza della regione da visualizzare
    let regionRadius: Double = 500
    
    // Richiede all'utente di abilitare i permessi di geolocalizzazione
    func allowGPS() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined: // E' la prima volta che l'utente apre l'applicazione
            locationManager.requestWhenInUseAuthorization()
        case .restricted,.denied: // L'utente ha disattivato la geolocalizzazione
            self.openAlertToSettings(title: "Location in use disabled", description: "To enable location in usa change it in Settings")
        case .authorizedWhenInUse, .authorizedAlways: // Tutto ok, la geolocalizzazione è attivata ed abbiamo i permessi
            return;
        default: print("Unknown GPS Auth status")
        }
    }
    
    // Apre un'alert che porta ai settings della geolocalizzazione
    func openAlertToSettings(title: String, description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openSettings = UIAlertAction(title: "Open Settings", style: .default) {
            (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openSettings)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // Permette di centrare la visuale sulla posizione dell'utente
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
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation   // Imposto il livello di accuratezza massima
        locationManager.distanceFilter = kCLDistanceFilterNone  // Tutti i movimenti devono essere riportati
        locationManager.startUpdatingLocation() // Tiene traccia del cambiamento di posizione
        mapView.showsScale = true   // Mostra la scala della mappa nell'angolo a sinistra
        mapView.showsUserLocation = true    // Mostra la posizione dell'utente sulla mappa
        centerPosition(regionRadius: regionRadius)
    }
    
    @IBAction func myPositionButton(_ sender: UIButton) {
        showCurrentPosition()
    }
    
    
    @IBAction func longPressureAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began { // Per non far avviare la segue due volte
            performSegue(withIdentifier: "addSegue", sender: sender)
        }
    }
    
    /*
    // Crea una nuova annotazione posizionandola sulle coordinate passate come parametro
    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        let newAnnotation = ARAppStdPointAnnotation()
        newAnnotation.coordinate = coordinate
        
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
            CoreDataController.shared.saveAnnotation(newAnnotation)
            print("Nuova annotazione aggiunta alla mappa")
        }))
        
        self.present(alert, animated: true)
        
    }
    */
    
    // Elimina le annotazioni selezionate
    @objc func deleteAnnotation(_ sender: UIButton) {
        // Controllo se l'array delle annotazioni selezionate è vuoto
        if mapView.selectedAnnotations.isEmpty { return }
        else {
            // Rimuove tutte le annotazioni selezionate (generalmente una)
            for i in mapView.selectedAnnotations {
                let ann = i as! ARAppStdPointAnnotation
                self.mapView.removeAnnotation(ann)
                CoreDataController.shared.deleteAnnotation(byUUID: ann.uuid)
                print("Annotazione selezionata rimossa dalla mappa")
            }
        }
     }
    
    // Viene richiamata ogni volta che un'annotazione deve essera visualizzata sulla mappa, tale annotazione verrà visualizzata come una Annotation View
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Serve per escludere l'annotazione riguardante la posizione attuale dell'utente
        if annotation is MKUserLocation {
            return nil;
        }
        
        // Le Annotation View che sono fuori dalla regione visibile vengono marcate come riutilizzabili
        let reuseId = "reuse"
        if let anyAnn = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) {
            anyAnn.annotation = annotation;
            return anyAnn;
        }
        
        let anyAnn = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        anyAnn.canShowCallout = true;
        anyAnn.pinTintColor  = .green
        let btnCancel = UIButton(type: .custom)
        btnCancel.frame = CGRect(x: 0, y: 0, width: 18, height: 22)
        btnCancel.setImage(UIImage(named: "trash"), for: .normal)
        btnCancel.addTarget(self, action: #selector(ViewController.deleteAnnotation(_:)), for: .touchUpInside)
        anyAnn.rightCalloutAccessoryView = btnCancel
        // Questo parametro permette di fare lo spostamento dell'annotation view, la relativa annotazione verrà riscritta automaticamente
        anyAnn.isDraggable = true;
        return anyAnn;
    }
    
    // Serve per gestire gli stati di un pin che viene spostato
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .canceling, .ending:
            view.dragState = .none
            let ARAnn = view.annotation as! ARAppStdPointAnnotation
            // Prendo il nuovo punto e sposto la vecchia annotazione
            CoreDataController.shared.moveAnnotation(withUUID: ARAnn.uuid, to: ARAnn.coordinate)
        default: break
        }
    }

    // Carica le annotazioni dal Core Data
    func loadPointAnnotation() {
        guard let points = CoreDataController.shared.getPointAnnotations() else { return }
        for i in points {
            mapView.addAnnotation(i)
        }
    }

    
    func customButtons() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        let borderColor = UIColor(red: 229.0/255, green: 229.0/255, blue: 234.0/255, alpha: 0.9).cgColor
        let backgroundColor = UIColor(white: 1, alpha: 0.97).cgColor
        let borderWidth : CGFloat = 0.5
        let cornerRadius : CGFloat = 5.0
        let padAm : CGFloat = 7.0
        let imagePadding = UIEdgeInsets(top: padAm, left: padAm, bottom: padAm, right: padAm)
        
        moreButton.layer.borderColor = borderColor
        moreButton.layer.backgroundColor = backgroundColor
        moreButton.layer.borderWidth = borderWidth
        moreButton.layer.cornerRadius = cornerRadius
        moreButton.imageEdgeInsets = imagePadding
        
        plusButton.layer.borderColor = borderColor
        plusButton.layer.backgroundColor = backgroundColor
        plusButton.layer.borderWidth = borderWidth
        plusButton.layer.cornerRadius = cornerRadius
        plusButton.imageEdgeInsets = imagePadding
        
        positionButton.layer.borderColor = borderColor
        positionButton.layer.backgroundColor = backgroundColor
        positionButton.layer.borderWidth = borderWidth
        positionButton.layer.cornerRadius = cornerRadius
        positionButton.imageEdgeInsets = imagePadding
        
        ARbtn.alpha = 0.97
        
        let compassView = MKCompassButton(mapView:mapView)
        let const = buttonsStackView.widthAnchor.constraint(equalToConstant: compassView.frame.width * 1.3)
        const.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customButtons()
        mapView.delegate = self
        locationManager.activityType = .fitness
        locationManager.delegate = self
        allowGPS()
        showCurrentPosition()
        loadPointAnnotation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toARview":
            let dstView = segue.destination as! ARViewController
            dstView.locationManager = locationManager
            arViewController = dstView
        case "addSegue":
            let nextView = segue.destination as! PhotoViewController
            if sender is UIButton {
                nextView.location = locationManager.location?.coordinate
            } else if sender is UILongPressGestureRecognizer {
                let press = sender as! UILongPressGestureRecognizer
                let posMapView = press.location(in: mapView)
                let coordinate = mapView.convert(posMapView, toCoordinateFrom: mapView)
                nextView.location = coordinate
            }
        default:
            print(#function)
        }
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        switch segue.identifier {
        case "addSegueUnwind":
            let src = segue.source as! PhotoViewController
            let ann = CoreDataController.shared.getPointAnnotation(withUUID: src.uuid!)
            mapView.addAnnotation(ann!)
        default:
            print(#function)
        }
    }
    
//    Metodo del CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let newLocation = locations.last{
            if(newLocation.timestamp.timeIntervalSinceNow < 5){
                if(newLocation.horizontalAccuracy > 0 && newLocation.horizontalAccuracy < 8){
                    ARViewController.mostAccurateLocation = newLocation
                    print(newLocation.description)
                }
            }
        }
//
//        guard let arView = arViewController else {return}
//        
//        

//        if let location = locations.last {
//            if arView.worldCenter == nil || abs(arView.worldCenter!.distance(from: location)) > arView.worldRecenteringThreshold {
//                arView.removeAllNodes()
//                arView.updateWorldCenter(location)
//                arView.placeNodes()
//            }
//        }
    }
}
