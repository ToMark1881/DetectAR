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
import Instructions

class ScannerViewController: BaseViewController {
    
    var interactor: ScannerInputProtocol?
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var clearAllButton: BigBounceButton!
    @IBOutlet weak var undoButton: BigBounceButton!
    @IBOutlet weak var suggestionsView: UIView!
    fileprivate lazy var coachMarksController = { return CoachMarksController() }()
    
    // MARK:- SCENE
    fileprivate let bubbleDepth : Float = 0.01 // the 'depth' of 3D text
    fileprivate var latestPrediction: String = "" // a variable containing the latest CoreML prediction
    fileprivate var isShowing: Bool = true
    fileprivate var needToTranslate: Bool = false
    fileprivate var nodes = [SCNNode]()
    
    // MARK:- COREML
    fileprivate var visionRequests = [VNRequest]()
    fileprivate let dispatchQueueML = DispatchQueue(label: "com.tomark.dispatchqueueml") // A Serial Queue
    
    fileprivate let coachMarks: [String] = ["Point the camera at an object. The application will try to recognize it".localized,
                                            "This field contains the name of the intended object that the camera sees".localized,
                                            "Tap on an object to add a sticker on it".localized,
                                            "The object will be named by the first name from the list".localized,
                                            "You can remove the last sticker by clicking on this button".localized,
                                            "You can remove the all stickers by clicking on this button".localized]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScene()
        self.addTapRecognizer()
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isShowing = true
        if (self.interactor?.isTranslationEnabled() == true) && (TranslationsLoader.shared.isModelAlreadyAvailable() && ApplicationLanguage.currentLanguage != .english) {
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
        if self.interactor?.isTutorialEnabled() == false {
            self.coachMarksController.start(in: .window(over: self))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        self.clearAllNodes()
        if self.interactor?.isTutorialEnabled() == false {
            self.coachMarksController.stop(immediately: true)
        }
        self.isShowing = false
    }
    
    @IBAction func didTapOnClearAllButton(_ sender: Any) {
        self.clearAllNodes()
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
    
    fileprivate func clearAllNodes() {
        sceneView.scene.rootNode.childNodes.forEach({ $0.removeFromParentNode() })
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
        
        guard let numberOfSuggestions = self.interactor?.getSuggestionNumber() else {
            print("No suggestion number")
            return
        }
        
        // Get Classifications
        let classifications = observations[0...(numberOfSuggestions - 1)] // top 3 results
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

extension ScannerViewController: CoachMarksControllerDelegate,
                                 CoachMarksControllerDataSource {
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )
        
        coachViews.bodyView.hintLabel.text = self.coachMarks[index]
        coachViews.bodyView.nextLabel.text = "Ok".localized
        
        coachViews.bodyView.hintLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        coachViews.bodyView.nextLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: centerView) // point camera
        case 1:
            return coachMarksController.helper.makeCoachMark(for: suggestionsView) // field with suggestions
        case 2:
            return coachMarksController.helper.makeCoachMark(for: centerView) // add sticker
        case 3:
            return coachMarksController.helper.makeCoachMark(for: suggestionsView) // when click suggestion
        case 4:
            return coachMarksController.helper.makeCoachMark(for: undoButton) // remove last sticker
        case 5:
            return coachMarksController.helper.makeCoachMark(for: clearAllButton) // remove all stickers
        default:
            return coachMarksController.helper.makeCoachMark(for: centerView)
        }
    }
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return coachMarks.count
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didShow coachMark: CoachMark, afterChanging change: ConfigurationChange, at index: Int) {
        self.interactor?.setTutorial(true)
    }
    
    
}
