//
//  ScannerViewController.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 27.10.2020.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ScannerViewController: BaseViewController {
    
    var interactor: ScannerInputProtocol?
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var debugTextView: UITextView!
    
    // SCENE
    fileprivate let bubbleDepth : Float = 0.01 // the 'depth' of 3D text
    fileprivate var latestPrediction: String = "" // a variable containing the latest CoreML prediction
    fileprivate var isShowing: Bool = true
    fileprivate var needToTranslate: Bool = false
    fileprivate var nodes = [SCNNode]()
    
    // COREML
    fileprivate var visionRequests = [VNRequest]()
    fileprivate let dispatchQueueML = DispatchQueue(label: "com.tomark.dispatchqueueml") // A Serial Queue
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScene()
        self.addTapRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isShowing = true
        if (self.interactor?.isTranslationEnabled() == true) && (TranslationsLoader.shared.isModelAlredayAvailable() && ApplicationLanguage.currentLanguage != .english) {
            self.needToTranslate = true
        }
        else {
            self.needToTranslate = false
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setModel()
        self.setupSceneInformation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        sceneView.scene.rootNode.childNodes.forEach({ $0.removeFromParentNode() })
        self.isShowing = false
    }
    
    @IBAction func didTapOnUndoButton(_ sender: Any) {
        if let lastNode = nodes.last {
            lastNode.removeFromParentNode()
            self.nodes.remove(at: nodes.count - 1) //remove last
        }
    }
    
    fileprivate func setupScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
    }
    
    fileprivate func setupSceneInformation() {
        if let debug = self.interactor?.isDebugEnabled() {
            sceneView.showsStatistics = debug
        }
    }
    
    fileprivate func addTapRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setModel() {
        guard let selectedModel = self.selectModel() else { return }
        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
        visionRequests = [classificationRequest]
        
        // Begin Loop to Update CoreML
        loopCoreMLUpdate()
    }
    
    fileprivate func selectModel() -> VNCoreMLModel? {
        return self.interactor?.getSavedModel()
    }
    
    @objc fileprivate func handleTap(gestureRecognize: UITapGestureRecognizer) {
        let screenCentre: CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults: [ARHitTestResult] = sceneView.hitTest(screenCentre,
                                                                    types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x,
                                                         transform.columns.3.y,
                                                         transform.columns.3.z)
            
            // Create 3D Text
            self.interactor?.generateNode(with: latestPrediction, and: bubbleDepth, completion: { [weak self] (node) in
                self?.sceneView.scene.rootNode.addChildNode(node)
                self?.nodes.append(node)
                node.position = worldCoord
            })
        }
    }
    
    // MARK: - CoreML Vision Handling
    
    fileprivate func loopCoreMLUpdate() {
        if !self.isShowing { return }
        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
        let delay = needToTranslate ? 0.7 : 0.4
        dispatchQueueML.asyncAfter(deadline: .now() + delay) { [weak self] in
            if let sSelf = self {
                // 1. Run Update.
                sSelf.interactor?.updateCoreML(scene: sSelf.sceneView, visionRequests: sSelf.visionRequests)
                
                // 2. Loop this function.
                sSelf.loopCoreMLUpdate()
            }
        }
        
    }
    
    fileprivate func classificationCompleteHandler(request: VNRequest, error: Error?) {
        // Catch Errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        // Get Classifications
        let classifications = observations[0...2] // top 3 results
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) - \(self.convertToPercent($0.confidence));" })
            .joined(separator: "\n")
        
        translateClassifications(classifications) { [weak self] (translatedText) in
            DispatchQueue.main.async {
                // Display Debug Text on screen
                var debugText: String = ""
                debugText += translatedText
                self?.debugTextView.text = debugText
                
                // Store the latest prediction
                var objectName: String = "…"
                objectName = translatedText.components(separatedBy: "-")[0]
                objectName = objectName.components(separatedBy: ",")[0]
                self?.latestPrediction = objectName
                
            }
        }
    }
    
    fileprivate func convertToPercent(_ value: VNConfidence) -> String {
        return "\(Int(value * 100))%"
    }
    
    fileprivate func translateClassifications(_ classifications: String, completed: @escaping (String) -> Void) {
        if needToTranslate {
            TranslationsLoader.shared.translateText(classifications) { (translatedText) in
                completed(translatedText)
            } failure: { (error) in
                print("Error: \(error?.localizedDescription ?? "")")
                completed(classifications)
            }
        }
        else {
            completed(classifications)
        }
    }
}

// MARK: - ScannerOutputProtocol
extension ScannerViewController: ScannerOutputProtocol {
    
}
