//
//  RootProtocols.swift
//  DetectAR
//
//  Created by Vladyslav Vdovycheko on 30.09.2020.
//

import Foundation

protocol RootInputProtocol: class {
    
    var view: RootOutputProtocol? { get set }
}

protocol RootOutputProtocol: class {
    
    var interactor: RootInputProtocol? { get set }
}
