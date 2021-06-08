//
//  ScannerInteractor.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 31.10.2020.
//

import Foundation
import ARKit
import CoreML

class ScannerInteractor: BaseInteractor {
    
    weak var view: ScannerOutputProtocol?
    
}

extension ScannerInteractor: ScannerInputProtocol {
    
    func getWorldCoordinateForNode(_ scene: ARSCNView, tapCoordinate: CGPoint) -> SCNVector3? {
        let arHitTestResults: [ARHitTestResult] = scene.hitTest(tapCoordinate,
                                                                    types: [.featurePoint])
        if let topResult = arHitTestResults.first {
            let transform : matrix_float4x4 = topResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            return worldCoord
        }
        return nil
    }
    
    func isTranslationEnabled() -> Bool { return self.servicesContainer.storageService.isTranslationEnabled() }
    
    func isDebugEnabled() -> Bool { return self.servicesContainer.storageService.isDebugEnabled() }
    
    func isTutorialEnabled() -> Bool { return self.servicesContainer.storageService.isTutorialEnabled() }
    
    func setTutorial(_ value: Bool) { self.servicesContainer.storageService.setTutorial(value) }
    
    func getSuggestionNumber() -> Int { return self.servicesContainer.storageService.getNumberOfSuggestions() }
    
    func updateCoreML(scene: ARSCNView, visionRequests: [VNRequest]) {
        let pixelbuff : CVPixelBuffer? = (scene.session.currentFrame?.capturedImage)
        if pixelbuff == nil { return }
        let image = CIImage(cvPixelBuffer: pixelbuff!)
        let imageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try imageRequestHandler.perform(visionRequests)
        } catch {
            print(error)
        }
    }
    
    func getSavedModel() -> VNCoreMLModel? {
        let modelType = self.servicesContainer.mlService.getSavedModel()
        
        switch modelType {
        case .MobileNetV2:
            return try? VNCoreMLModel(for: MobileNetV2(configuration: MLModelConfiguration()).model)
        case .Resnet50:
            return try? VNCoreMLModel(for: Resnet50(configuration: MLModelConfiguration()).model)
        case .SqueezeNet:
            return try? VNCoreMLModel(for: SqueezeNet(configuration: MLModelConfiguration()).model)
        }
    }
    
    func generateNode(with text: String, and depth: Float, completion: @escaping (SCNNode) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = SCNBillboardAxis.Y
            let bubble = SCNText(string: text, extrusionDepth: CGFloat(depth))
            var font = UIFont(name: "HelveticaNeue-Medium", size: 0.18)
            font = font?.withTraits(traits: .traitBold)
            bubble.font = font
            bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            bubble.firstMaterial?.diffuse.contents = UIColor.white
            bubble.firstMaterial?.specular.contents = UIColor.white
            bubble.firstMaterial?.isDoubleSided = true
            bubble.chamferRadius = CGFloat(depth)
            let (min, max) = bubble.boundingBox
            let bubbleNode = SCNNode(geometry: bubble)
            bubbleNode.pivot = SCNMatrix4MakeTranslation( (max.x - min.x)/2, min.y, depth/2)
            bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
            let sphere = SCNSphere(radius: 0.005)
            sphere.firstMaterial?.diffuse.contents = UIColor.red
            let sphereNode = SCNNode(geometry: sphere)
            DispatchQueue.main.async {
                let parentBubbleNode = SCNNode()
                parentBubbleNode.addChildNode(bubbleNode)
                parentBubbleNode.addChildNode(sphereNode)
                parentBubbleNode.constraints = [billboardConstraint]                
                completion(parentBubbleNode)
            }
        }
    }
}
