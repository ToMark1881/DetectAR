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
    
    func isTranslationEnabled() -> Bool {
        return self.servicesContainer.storageService.isTranslationEnabled()
    }
    
    func isDebugEnabled() -> Bool {
        return self.servicesContainer.storageService.isDebugEnabled()
    }
    
    func isTutorialEnabled() -> Bool {
        return self.servicesContainer.storageService.isTutorialEnabled()
    }
    
    func setTutorial(_ value: Bool) {
        self.servicesContainer.storageService.setTutorial(value)
    }
    
    func updateCoreML(scene: ARSCNView, visionRequests: [VNRequest]) {
        ///////////////////////////
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = (scene.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        // Note: Not entirely sure if the ciImage is being interpreted as RGB, but for now it works with the Inception model.
        // Note2: Also uncertain if the pixelBuffer should be rotated before handing off to Vision (VNImageRequestHandler) - regardless, for now, it still works well with the Inception model.
        
        ///////////////////////////
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        // let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage!, orientation: myOrientation, options: [:]) // Alternatively; we can convert the above to an RGB CGImage and use that. Also UIInterfaceOrientation can inform orientation values.
        
        ///////////////////////////
        // Run Image Request
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
        // Warning: Creating 3D Text is susceptible to crashing. To reduce chances of crashing; reduce number of polygons, letters, smoothness, etc.
        DispatchQueue.global(qos: .userInitiated).async {
            // TEXT BILLBOARD CONSTRAINT
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = SCNBillboardAxis.Y
            
            // BUBBLE-TEXT
            let bubble = SCNText(string: text, extrusionDepth: CGFloat(depth))
            var font = UIFont(name: "HelveticaNeue-Medium", size: 0.18)
            font = font?.withTraits(traits: .traitBold)
            bubble.font = font
            bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            bubble.firstMaterial?.diffuse.contents = UIColor(named: "Accent")
            bubble.firstMaterial?.specular.contents = UIColor.white
            bubble.firstMaterial?.isDoubleSided = true
            // bubble.flatness // setting this too low can cause crashes.
            bubble.chamferRadius = CGFloat(depth)
            
            // BUBBLE NODE
            let (minBound, maxBound) = bubble.boundingBox
            let bubbleNode = SCNNode(geometry: bubble)
            // Centre Node - to Centre-Bottom point
            bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, depth/2)
            // Reduce default text size
            bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
            
            // CENTRE POINT NODE
            let sphere = SCNSphere(radius: 0.005)
            sphere.firstMaterial?.diffuse.contents = UIColor.red
            let sphereNode = SCNNode(geometry: sphere)
            DispatchQueue.main.async {
                // BUBBLE PARENT NODE
                let bubbleNodeParent = SCNNode()
                bubbleNodeParent.addChildNode(bubbleNode)
                bubbleNodeParent.addChildNode(sphereNode)
                bubbleNodeParent.constraints = [billboardConstraint]
                
                completion(bubbleNodeParent)
            }
        }
        
    }
    
}
