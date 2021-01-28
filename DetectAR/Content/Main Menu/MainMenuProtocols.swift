//
//  MainMenuProtocols.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 25.01.2021.
//

import Foundation

protocol MainMenuInputProtocol: class {
    
    var view: MainMenuOutputProtocol? { get set }
}

protocol MainMenuOutputProtocol: class {
    
    var interactor: MainMenuInputProtocol? { get set }
}
