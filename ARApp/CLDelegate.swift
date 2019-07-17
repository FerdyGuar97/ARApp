//
//  CLDelegate.swift
//  ARApp
//
//  Created by Davide Della Monica on 17/07/2019.
//  Copyright © 2019 Ferdinando Guarino. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import ARKit

class LocationDelegate: NSObject, CLLocationManagerDelegate{
    
    var arView : ARSCNView?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let view = arView
            else {return}
        
        
    }
}
