//
//  ServiceProvider.swift
//  DetectAR
//
//  Created by Vladyslav Vdovycheko on 30.09.2020.
//

import Foundation


class ServicesContainer {
    
    var mlService: MLService!
    var arKitService: ARKitService!
    var storageService: StorageSerice!
    var translationService: TranslationService!
    
    init() {
        self.mlService = MLService()
        self.mlService.api = MLAPIService()
        
        self.arKitService = ARKitService()
        self.arKitService.api = ARKitAPIService()
        
        self.storageService = StorageSerice()
        self.storageService.api = StorageAPIService()
        
        self.translationService = TranslationService()
        self.translationService.api = TranslationAPIService()
    }
    
}
