//
//  ScannerCoachMarks.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 27.05.2021.
//

import Foundation

class ScannerCoachMarks {
    
    static let shared = ScannerCoachMarks()
    
    private init() {}
    
    let coachMarks: [String] = ["Point the camera at an object. The application will try to recognize it".localized,
                                            "This field contains the name of the intended object that the camera sees".localized,
                                            "Tap on an object to add a sticker on it".localized,
                                            "The object will be named by the first name from the list".localized,
                                            "You can remove the last sticker by clicking on this button".localized,
                                            "You can remove the all stickers by clicking on this button".localized]
    
}
