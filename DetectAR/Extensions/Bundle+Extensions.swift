//
//  Bundle+Extensions.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 27.01.2021.
//

import Foundation

extension Bundle {
    
    class func getIdentifier() -> String {
        guard let info = Bundle.main.infoDictionary,
            let bundleIdentifier = info["CFBundleIdentifier"] as? String else {
                return ""
        }
        
        return bundleIdentifier
    }
    
    class func getVersion() -> String {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String else {
                return ""
        }
        
        return currentVersion
    }
    
}
