//
//  StorageAPIService.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 27.01.2021.
//

import Foundation

class StorageAPIService: StorageAPIInterface {
    
    fileprivate let translationsKey = "translationsKey"
    fileprivate let debugKey = "debugTextKey"
    fileprivate let tutorialKey = "tutorialUserDefaultsKey"
    fileprivate let numberOfSuggestionsKey = "numberOfSuggestionsUserDefaultsKey"
    
    func isTranslationEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: translationsKey)
    }
    
    func isDebugEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: debugKey)
    }
    
    func isTutorialEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: tutorialKey)
    }
    
    func setTranslations(_ value: Bool) {
        UserDefaults.standard.setValue(value, forKey: translationsKey)
    }
    
    func setDebug(_ value: Bool) {
        UserDefaults.standard.setValue(value, forKey: debugKey)
    }
    
    func setTutorial(_ value: Bool) {
        UserDefaults.standard.setValue(value, forKey: tutorialKey)
    }
    
    func setNumberOfSuggestions(_ value: Int) {
        UserDefaults.standard.setValue(value, forKey: numberOfSuggestionsKey)
    }
    
    func getNumberOfSuggestions() -> Int {
        let value = UserDefaults.standard.integer(forKey: numberOfSuggestionsKey)
        if (value == 0) { return 1 } else { return value }
    }
    
}
