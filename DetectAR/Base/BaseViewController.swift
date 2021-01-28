//
//  BaseViewController.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 31.10.2020.
//

import UIKit

class BaseViewController: UIViewController {
    
    fileprivate var deferedError: NSError?
    fileprivate var visible: Bool = false
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    var needToHideNavigationBar: Bool = false
    var prefersLargeTitles: Bool = true
    
    override var prefersStatusBarHidden : Bool { return false }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Logger.shared.log("🆕 \(self)", type: .lifecycle)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        Logger.shared.log("🆕 \(self)", type: .lifecycle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        
        Logger.shared.log("viewDidLoad \(String(describing: self))", type: .lifecycle)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needToHideNavigationBar {
            self.navigationController?.setNavigationBarHidden(true, animated: animated) //hide
        }
        
        Logger.shared.log("viewWillAppear \(String(describing: self))", type: .lifecycle)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.visible = true

        if self.deferedError != nil {
            Logger.shared.log(deferedError)
        }
        
        Logger.shared.log("viewDidAppear \(String(describing: self))", type: .lifecycle)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if needToHideNavigationBar {
            self.navigationController?.setNavigationBarHidden(false, animated: animated) //show
        }
        Logger.shared.log("viewWillDisappear \(String(describing: self))", type: .lifecycle)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.shared.log("viewDidDisappear \(String(describing: self))", type: .lifecycle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        Logger.shared.log("😱 \(self)", type: .lifecycle)
    }

    deinit {
        Logger.shared.log("🗑 \(self)", type: .lifecycle)
    }
    
    final func subscribeToApplicationEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    final func unsubscribeFromApplicationEvents() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        // Override
    }

}
