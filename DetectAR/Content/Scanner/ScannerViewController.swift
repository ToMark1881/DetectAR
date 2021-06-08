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
    fileprivate let depthOfBubble : Float = 0.01
    fileprivate var topPrediction: String = ""
    fileprivate var isShowing: Bool = true
    fileprivate var needToTranslate: Bool = false
    fileprivate var nodes = [SCNNode]()
    
    // MARK:- COREML
    fileprivate var mlRequests = [VNRequest]()
    fileprivate let dispatchQueueML = DispatchQueue(label: "com.tomark.dispatchqueueml")
    
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
        else { self.needToTranslate = false }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        guard let camera = self.sceneView.pointOfView?.camera else { return }
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
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
        if #available(iOS 13.0, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.addCoaching()
            }
        }
    }
    
    fileprivate func addTapRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnScreen(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setModel() {
        guard let selectedModel = self.selectModel() else { return }
        let classificationObject = Classification(suggestionNumber: self.interactor?.getSuggestionNumber() ?? 1, isNeedToTranslate: self.needToTranslate)
        let request = VNCoreMLRequest(model: selectedModel) { request, error in
            classificationObject.classificationCompleteHandler(request: request, error: error) { [weak self] fullText, topPrediction in
                DispatchQueue.main.async {
                    self?.debugTextView.text = fullText
                    self?.topPrediction = topPrediction
                }
            }
        }
        request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        mlRequests = [request]
        loopCoreMLUpdate()
    }
    
    fileprivate func selectModel() -> VNCoreMLModel? {
        return self.interactor?.getSavedModel()
    }
    
    @objc fileprivate func handleTapOnScreen(gestureRecognize: UITapGestureRecognizer) {
        let tapCoordinate = gestureRecognize.location(in: self.sceneView)
        if let worldCoord = self.interactor?.getWorldCoordinateForNode(self.sceneView, tapCoordinate: tapCoordinate) {
            self.interactor?.generateNode(with: topPrediction, and: depthOfBubble, completion: { [weak self] (node) in
                self?.sceneView.scene.rootNode.addChildNode(node)
                self?.nodes.append(node)
                node.position = worldCoord
            })
        }
    }
    
    // MARK: - CoreML Vision Handling
    fileprivate func loopCoreMLUpdate() {
        if !self.isShowing { return }
        let delay = needToTranslate ? 0.7 : 0.4
        dispatchQueueML.asyncAfter(deadline: .now() + delay) { [weak self] in
            if let self = self {
                // 1. Run Update.
                self.interactor?.updateCoreML(scene: self.sceneView, visionRequests: self.mlRequests)
                // 2. Recursion
                self.loopCoreMLUpdate()
            }
        }
    }
}

// MARK: - ScannerOutputProtocol
extension ScannerViewController: ScannerOutputProtocol { }

extension ScannerViewController: CoachMarksControllerDelegate,
                                 CoachMarksControllerDataSource {
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )
        
        coachViews.bodyView.hintLabel.text = ScannerCoachMarks.shared.coachMarks[index]
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
        return ScannerCoachMarks.shared.coachMarks.count
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didShow coachMark: CoachMark, afterChanging change: ConfigurationChange, at index: Int) {
        self.interactor?.setTutorial(true)
    }
}

extension ScannerViewController: ARCoachingOverlayViewDelegate {
    
    @available(iOS 13.0, *)
    func addCoaching() {
        let guidanceOverlay = ARCoachingOverlayView()
        guidanceOverlay.session = self.sceneView.session
        guidanceOverlay.delegate = self
        self.sceneView.addSubview(guidanceOverlay)

        //2. Set It To Fill Our View
        NSLayoutConstraint.activate([
          NSLayoutConstraint(item:  guidanceOverlay, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
          NSLayoutConstraint(item:  guidanceOverlay, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
          NSLayoutConstraint(item:  guidanceOverlay, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
          NSLayoutConstraint(item:  guidanceOverlay, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
          ])
        guidanceOverlay.translatesAutoresizingMaskIntoConstraints = false
        guidanceOverlay.activatesAutomatically = true
        guidanceOverlay.goal = .verticalPlane
    }
    
    // Example callback for the delegate object
    
    @available(iOS 13.0, *)
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView ) { }
}
