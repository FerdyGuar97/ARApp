//
//  ViewController.swift
//  ARApp
//
//  Created by Ferdinando Guarino on 10/07/2019.
//  Copyright © 2019 Ferdinando Guarino. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController,ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        
        let constr = SCNBillboardConstraint()
        
        constr.freeAxes = .Y
        
        let text = SCNText(string: "Aumentata", extrusionDepth: 1)
        let node = SCNNode()
        node.position = SCNVector3(x: 0, y: 0.4, z: 1)
        node.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        node.geometry = text
        node.geometry?.materials.first?.diffuse.contents = UIColor.white
        node.constraints = [constr]
        
        let imgNode1 = SCNNode(geometry: SCNPlane(width: 1, height: 1))
        imgNode1.position = SCNVector3(x: 0, y: 0.4, z: -1)
        imgNode1.physicsBody? = .static()
        imgNode1.geometry?.materials.first?.diffuse.contents = UIImage(named: "IMG_0016.JPEG")
        imgNode1.constraints = [constr]
        
        let imgNode2 = SCNNode(geometry: SCNPlane(width: 1, height: 1))
        imgNode2.position = SCNVector3(x: -1, y: 0.4, z: -1)
        imgNode2.physicsBody? = .static()
        imgNode2.geometry?.materials.first?.diffuse.contents = UIImage(named: "IMG_0016.JPEG")
        imgNode2.constraints = [constr]
        
        sceneView.scene.rootNode.addChildNode(node)
        sceneView.scene.rootNode.addChildNode(imgNode1)
        sceneView.scene.rootNode.addChildNode(imgNode2)
        sceneView.autoenablesDefaultLighting =  true
    }


}

