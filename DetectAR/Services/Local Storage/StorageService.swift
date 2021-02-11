//
//  StorageService.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 27.01.2021.
//

import Foundation

class StorageSerice: BaseService {
    
    var api: StorageAPIInterface?
    
    func isTranslationEnabled() -> Bool {
        return self.api?.isTranslationEnabled() ?? false
    }
    
    func isDebugEnabled() -> Bool {
        return self.api?.isDebugEnabled() ?? false
    }
    
    func isTutorialEnabled() -> Bool {
        return self.api?.isTutorialEnabled() ?? false
    }
    
    func setTranslations(_ value: Bool) {
        self.api?.setTranslations(value)
    }
    
    func setDebug(_ value: Bool) {
        self.api?.setDebug(value)
    }
    
    func setTutorial(_ value: Bool) {
        self.api?.setTutorial(value)
    }
    
}
