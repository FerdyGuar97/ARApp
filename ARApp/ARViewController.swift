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
    
    var manager : CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        
        let billboardConstraint = SCNBillboardConstraint()
        
        billboardConstraint.freeAxes = .Y
        
        let root : SCNNode = sceneView.scene.rootNode
 
        let points = CoreDataController.shared.getLocations()
        
        for (_ , value) in points{
            let imgNode = SCNNode(geometry: SCNPlane(width: 1, height: 1))
            let translation = SCNMatrix4MakeTranslation(0, 0, Float(value.distance(from: manager!.location!)))
            let teta = ARViewController.bearingBetween(startLocation: manager!.location!, endLocation: value)
            let rotation = SCNMatrix4MakeRotation(teta, 0, 1, 0)
            
            let transform = SCNMatrix4Mult(translation, SCNMatrix4Mult(rotation, root.transform))
            
            imgNode.transform = transform
            imgNode.constraints = [billboardConstraint]
            imgNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "gandalfcage.png")
            
            sceneView.scene.rootNode.addChildNode(imgNode)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /**
     Precise bearing between two points.
     */
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
