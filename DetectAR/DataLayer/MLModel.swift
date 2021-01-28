//
//  MLModel.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 25.01.2021.
//

import Foundation

class Model: NSObject {
    
    private(set) var title: String?
    private(set) var information: String?
    private(set) var type: MLModelType?
    
    convenience init(_ dict: NSDictionary) {
        self.init()
        self.information = dict["information"] as? String
        if let title = dict["title"] as? String {
            self.title = title
            self.type = MLModelType(rawValue: title)
        }
    }
}
