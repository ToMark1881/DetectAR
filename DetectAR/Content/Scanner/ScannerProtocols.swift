//
//  ScannerProtocols.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 31.10.2020.
//

import Foundation
import ARKit
import CoreML

protocol ScannerInputProtocol: AnyObject {
    
    var view: ScannerOutputProtocol? { get set }
    
    func generateNode(with text: String, and depth: Float, completion: @escaping (SCNNode) -> Void)
    
    func getSavedModel() -> VNCoreMLModel?
    
    func updateCoreML(scene: ARSCNView, visionRequests: [VNRequest])
    
    func isTranslationEnabled() -> Bool
    
    func isDebugEnabled() -> Bool
    
    func isTutorialEnabled() -> Bool
    
    func setTutorial(_ value: Bool)
    
    func getSuggestionNumber() -> Int
    
    func getWorldCoordinateForNode(_ scene: ARSCNView, tapCoordinate: CGPoint) -> SCNVector3?
}

protocol ScannerOutputProtocol: AnyObject {
    
    var interactor: ScannerInputProtocol? { get set }
        
}
