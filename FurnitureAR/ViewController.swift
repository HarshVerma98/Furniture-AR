//
//  ViewController.swift
//  FurnitureAR
//
//  Created by Harsh Verma on 26/03/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ARSCNViewDelegate {

    let itemArray = ["cup", "table", "boxing", "vase"]
    var selectedItem: String?
    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        self.itemCollectionView.delegate = self
        self.itemCollectionView.dataSource = self
        self.sceneView.delegate = self
        self.registerGesture()
    }
    
    func addItem(hitTestResult: ARHitTestResult) {
        if let selectedItem = self.selectedItem {
        let scene = SCNScene(named: "Model.scnassets/\(selectedItem).scn")
        
        let node = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
        let transform = hitTestResult.worldTransform
            let third = transform.columns.3
            node.position = SCNVector3(third.x, third.y, third.z)
            self.sceneView.scene.rootNode.addChildNode(node)
        }
        }
    
    func registerGesture() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        let pich = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        self.sceneView.addGestureRecognizer(pich)
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        
        let hitTest = sceneView.hitTest(pinchLocation)
        if !hitTest.isEmpty {
            
            let results = hitTest.first
            let node = results?.node
            let pinchAct = SCNAction.scale(by: sender.scale, duration: 0)
            node?.runAction(pinchAct)
            sender.scale = 1.0
        }
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        if !hitTest.isEmpty {
            self.addItem(hitTestResult: hitTest.first!)
            print("Hitting Surface")
        }
        else {
            print("No Hit on Surface")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! ItemCell
        cell.itemList.text = self.itemArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = itemArray[indexPath.row]
        cell?.backgroundColor = UIColor.green
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return }
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.planeDetected.isHidden = true
            }
        }
    }
}

