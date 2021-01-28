//
//  ApplicationLanguage.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 28.01.2021.
//

import Foundation

enum AppLanguage: String {
    
    case english = "en"
    case russian = "ru"
    case ukrainian = "uk"
    
}

class ApplicationLanguage {
    
    static let currentLanguage: AppLanguage = {
        return (AppLanguage(rawValue: "currentLanguage".localized)) ?? .english
    }()
    
}
