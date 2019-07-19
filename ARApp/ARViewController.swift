//
//  ARViewController.swift
//  ARApp
//
//  Created by Davide Della Monica on 16/07/2019.
//  Copyright © 2019 Ferdinando Guarino. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    var locationManager : CLLocationManager?
    
    var worldCenter: CLLocation?
    
    static var mostAccurateLocation: CLLocation?
    
    let worldRecenteringThreshold: Double = 8.0
    
    var pins: [UUID: CLLocation] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nil
        sceneView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateWorldCenter(ARViewController.mostAccurateLocation ?? (locationManager?.location)!)
        placeNodes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func updateWorldCenter(_ location: CLLocation) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        sceneView.session.run(configuration, options: [.resetTracking])
        worldCenter = location
        
        pins = CoreDataController.shared.getLocations(near: worldCenter!, widthMaxDistance: 75)
    }
    
    private func makeTransform(from origin: CLLocation, to node: CLLocation) -> SCNMatrix4{
        let distance = origin.distance(from: node)
        let translation = SCNMatrix4Translate(SCNMatrix4Identity, 0, 0, -Float(distance))
        let angle = ARViewController.bearingBetween(startLocation: origin, endLocation: node)
        let transform = SCNMatrix4Rotate(translation, -angle, 0, 1, 0)
        return transform
    }
    
    func placeNodes() {
        guard let center = worldCenter else {
            return
        }
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y

        
        
        for (id , pin) in pins {
            let node = SCNNode(geometry: SCNPlane(width: 2, height: 1))
            node.transform = makeTransform(from: center, to: pin)
            node.constraints = [billboardConstraint]
            node.geometry?.firstMaterial?.diffuse.contents = CoreDataController.shared.getViewImage(byUUID: id)
            
            sceneView.scene.rootNode.addChildNode(node)
            
        }
    }
    
    func removeAllNodes() {
        let root = sceneView.scene.rootNode
        root.childNodes.forEach({
            $0.removeFromParentNode()
        })
        
        pins = [:]
    }

    
    static func bearingBetween(startLocation: CLLocation, endLocation: CLLocation) -> Float {
        var azimuth: Float = 0
        let lat1 = GLKMathDegreesToRadians(
            Float(startLocation.coordinate.latitude)
        )
        let lon1 = GLKMathDegreesToRadians(
            Float(startLocation.coordinate.longitude)
        )
        let lat2 = GLKMathDegreesToRadians(
            Float(endLocation.coordinate.latitude)
        )
        let lon2 = GLKMathDegreesToRadians(
            Float(endLocation.coordinate.longitude)
        )
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        azimuth = GLKMathRadiansToDegrees(Float(radiansBearing))
        if(azimuth < 0) { azimuth += 360 }
        return azimuth
    }
    
}
