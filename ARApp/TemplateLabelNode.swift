/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Instantiates styled label nodes based on a template node in a scene file.
*/

import SpriteKit

/// - Tag: TemplateLabelNode
class TemplateLabelNode: SKReferenceNode {
    
    private let text: String
    
    init(text: String) {
        self.text = text
        // Force call to designated init(fileNamed: String?), not convenience init(fileNamed: String)
        super.init(fileNamed: Optional.some("LabelScene"))
        setScale(0.2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didLoad(_ node: SKNode?) {
        // Apply text to both labels loaded from the template.
        guard let parent = node?.childNode(withName: "LabelNode") else {
            fatalError("misconfigured SpriteKit template file")
        }
        
        for case let label as SKLabelNode in parent.children {
            label.name = text
            label.text = text
        }
        
        let desc = parent.childNode(withName: "DescriptionBox")
        let description = desc?.childNode(withName: "Description") as! SKLabelNode
        
        description.text = "Questa è la descrizione del monumento"
    }
}
