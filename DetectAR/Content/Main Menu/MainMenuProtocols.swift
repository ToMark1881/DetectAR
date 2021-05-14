//
//  MainMenuProtocols.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 25.01.2021.
//

import Foundation

protocol MainMenuInputProtocol: AnyObject {
    
    var view: MainMenuOutputProtocol? { get set }
}

protocol MainMenuOutputProtocol: AnyObject {
    
    var interactor: MainMenuInputProtocol? { get set }
}
