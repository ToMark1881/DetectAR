//
//  BaseService.swift
//  DetectAR
//
//  Created by Vladyslav Vdovycheko on 12.10.2020.
//

import Foundation

class BaseService {

    var loadingQueue: [String: Bool] = [String: Bool]()
    
    let operations: OperationQueue = OperationQueue()
    var parsingQueue: DispatchQueue!

    init() {self.parsingQueue = DispatchQueue(label: "com.tomark.parsing.queue.\(String(describing: type(of: self)))")
        let parsingQueueWithoutStringDescribing = DispatchQueue(label: "com.tomark.parsing.queue.\(type(of: self))")
        Logger.shared.log("actual: \(String(describing: self.parsingQueue)) and older one: \(parsingQueueWithoutStringDescribing)", type: .gcd)
    }
    
    final func nonHandle (_ completed: (() -> Void)? = nil) -> ((Error?) -> Void) {
        return { (error: Error?) -> Void in
            Logger.shared.log(error)
            completed?()
        }
    }
    
}
