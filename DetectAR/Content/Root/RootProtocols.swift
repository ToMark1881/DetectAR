//
//  RootProtocols.swift
//  DetectAR
//
//  Created by Vladyslav Vdovycheko on 30.09.2020.
//

import Foundation

protocol RootInputProtocol: AnyObject {
    
    var view: RootOutputProtocol? { get set }
}

protocol RootOutputProtocol: AnyObject {
    
    var interactor: RootInputProtocol? { get set }
}
