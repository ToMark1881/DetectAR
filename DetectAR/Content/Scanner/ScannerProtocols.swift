//
//  ScannerProtocols.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 31.10.2020.
//

import Foundation
import ARKit
import CoreML

protocol ScannerInputProtocol: class {
    
    var view: ScannerOutputProtocol? { get set }
    
    func generateNode(with text: String, and depth: Float) -> SCNNode
    
    func getSavedModel() -> VNCoreMLModel?
    
    func updateCoreML(scene: ARSCNView, visionRequests: [VNRequest])
    
    func isTranslationEnabled() -> Bool
    
    func isDebugEnabled() -> Bool
    
}

protocol ScannerOutputProtocol: class {
    
    var interactor: ScannerInputProtocol? { get set }
        
}