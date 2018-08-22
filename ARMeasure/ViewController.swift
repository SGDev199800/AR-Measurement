//
//  ViewController.swift
//  ARMeasure
//
//  Created by Saurav Gupta on 07/08/18.
//  Copyright © 2018 Saurav Gupta. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate{

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sceneViewLAbel: UILabel!
    
    var dotNodes = [SCNNode]()
    var lineNodes = [SCNNode]()
    var textNode = SCNNode()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneViewLAbel.text = ""
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 4{
           
            for dots in dotNodes{
                dots.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
            updateText(text: "", atPosition: SCNVector3(0, 0, 0) )
            sceneViewLAbel.text = ""
            
            for lines in lineNodes{
                lines.removeFromParentNode()
            }
            lineNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView){
            
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first{
                addDot(at: hitResult)
            }
        }

    }
    
    func addDot(at hitResult : ARHitTestResult){
        
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 4 {
            calculateAreaQuad()
        
            lineNodes[2].removeFromParentNode()
            
        }else if dotNodes.count >= 3 {
            calculateAreaTriangle()
        }else if dotNodes.count >= 2{
            calculateDistance()
            
        }
        
    }
    
    func calculateAreaTriangle(){
        let firstPoint = dotNodes[0]
        let secondPoint = dotNodes[1]
        let thirdPoint = dotNodes[2]
        
        // area of triange Area    =     √     p     (    p    −    a    )     (    p    −    b    )     (    p    −    c   ) herons formula
        
        let side1 = sqrt(pow(secondPoint.position.x - firstPoint.position.x, 2) + pow(secondPoint.position.y - firstPoint.position.y , 2) + pow(secondPoint.position.z - firstPoint.position.z, 2))
        
        let side2 = sqrt(pow(thirdPoint.position.x - secondPoint.position.x, 2) + pow(thirdPoint.position.y - secondPoint.position.y, 2) + pow(thirdPoint.position.z - secondPoint.position.z, 2))
        
        let side3 = sqrt(pow(firstPoint.position.x - thirdPoint.position.x, 2) + pow(firstPoint.position.y - thirdPoint.position.y, 2) + pow(firstPoint.position.z - thirdPoint.position.z, 2))
        
        let p = (side1 + side2 + side3)/3
        
        let triangleArea = sqrt(p*(p-side1)*(p-side2)*(p-side3)) * 10000
        
        updateText(text: "\(triangleArea) sq cm", atPosition: thirdPoint.position)
        sceneViewLAbel.text = "AREA = \(triangleArea) sq cm"
        
        let line2 = SCNGeometry.line(from: secondPoint.position, to: thirdPoint.position)
        let line3 = SCNGeometry.line(from: thirdPoint.position, to: firstPoint.position)
        let lineNode2 = SCNNode(geometry: line2)
        let lineNode3 = SCNNode(geometry: line3)
        lineNode2.position = SCNVector3Zero
        lineNode3.position = SCNVector3Zero
        sceneView.scene.rootNode.addChildNode(lineNode2)
        lineNodes.append(lineNode2)
        sceneView.scene.rootNode.addChildNode(lineNode3)
        lineNodes.append(lineNode3)
    }
    
    func calculateAreaQuad(){
        
        let firstPoint = dotNodes[0]
        let secondPoint = dotNodes[1]
        let thirdPoint = dotNodes[2]
        let fourthPoint = dotNodes[3]
        
        let side1 = sqrt(pow(secondPoint.position.x - firstPoint.position.x, 2) + pow(secondPoint.position.y - firstPoint.position.y , 2) + pow(secondPoint.position.z - firstPoint.position.z, 2))
        
        let side2 = sqrt(pow(thirdPoint.position.x - secondPoint.position.x, 2) + pow(thirdPoint.position.y - secondPoint.position.y, 2) + pow(thirdPoint.position.z - secondPoint.position.z, 2))
        
        let side3 = sqrt(pow(fourthPoint.position.x - thirdPoint.position.x, 2) + pow(fourthPoint.position.y - thirdPoint.position.y, 2) + pow(fourthPoint.position.z - thirdPoint.position.z, 2))
        
        let side4 = sqrt(pow(firstPoint.position.x - fourthPoint.position.x, 2) + pow(firstPoint.position.y - fourthPoint.position.y, 2) + pow(firstPoint.position.z - fourthPoint.position.z, 2))
        
        let s = (side3 + side2 + side1 + side4)/2
        
        let areaQuad = sqrt((s-side1)*(s-side2)*(s-side3)*(s-side4)) * 10000
  
        updateText(text: "\(areaQuad) sq cm", atPosition: fourthPoint.position)
        sceneViewLAbel.text = "AREA = \(areaQuad) sq cm"
        
        let line4 = SCNGeometry.line(from: fourthPoint.position, to: thirdPoint.position)
        let line5 = SCNGeometry.line(from: fourthPoint.position, to: firstPoint.position)
        let lineNode4 = SCNNode(geometry: line4)
        let lineNode5 = SCNNode(geometry: line5)
        lineNode4.position = SCNVector3Zero
        lineNode5.position = SCNVector3Zero
        sceneView.scene.rootNode.addChildNode(lineNode4)
        lineNodes.append(lineNode4)
        sceneView.scene.rootNode.addChildNode(lineNode5)
        lineNodes.append(lineNode5)
    }
    
    func calculateDistance(){
        let start = dotNodes[0]
        let end = dotNodes[1]
 
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2)) * 100
        
        updateText(text: "\(distance) cm", atPosition: end.position)
        
        sceneViewLAbel.text = "DISTANCE = \(distance) cm"
        
        let line1 = SCNGeometry.line(from: start.position, to: end.position)
        let lineNode1 = SCNNode(geometry: line1)
        lineNode1.position = SCNVector3Zero
        sceneView.scene.rootNode.addChildNode(lineNode1)
        lineNodes.append(lineNode1)
    }
    
    
    
    func updateText(text: String, atPosition position: SCNVector3){
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x, position.y + 0.1, position.z)
        
        textNode.scale = SCNVector3(0.005, 0.005, 0.005)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
        
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        
        for dots in dotNodes{
            dots.removeFromParentNode()
        }
        dotNodes = [SCNNode]()
        updateText(text: "", atPosition: SCNVector3(0, 0, 0) )
        
        for lines in lineNodes{
            lines.removeFromParentNode()
        }
        lineNodes = [SCNNode]()
        sceneViewLAbel.text = ""
        
    }
    
}

extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}










