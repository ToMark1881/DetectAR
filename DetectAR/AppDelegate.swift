//
//  AppDelegate.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 27.10.2020.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var servicesContainer: ServicesContainer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.initServices()
        
        self.configureRootViewController()
        
        self.setupUIAppearance()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

}

extension AppDelegate {
    
    fileprivate func initServices() {
        self.servicesContainer = ServicesContainer()
    }
    
    fileprivate func configureRootViewController() {
        let storyboard = UIStoryboard(name: "Content", bundle: nil)
        let rootViewController: (RootOutputProtocol & UIViewController) = storyboard.instantiateViewController(withIdentifier: "RootViewController") as! RootViewController
        let interactor: RootInputProtocol = RootInteractor()
        rootViewController.interactor = interactor
        interactor.view = rootViewController
        if let window = self.window {
            window.rootViewController = rootViewController
        }
    }
    
    fileprivate func setupUIAppearance() {
        var fontColor = UIColor.black
        if #available(iOS 13.0, *) { fontColor = .label }
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: fontColor]
        UINavigationBar.appearance().titleTextAttributes = attributes
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .highlighted)
        
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .focused)
        
        
        UINavigationBar.appearance().barTintColor = fontColor
        UINavigationBar.appearance().tintColor = fontColor
        UIBarButtonItem.appearance().tintColor = fontColor
    }
    
}

