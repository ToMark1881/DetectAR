//
//  TapticEngineGenerator.swift
//  SuperDealNew
//
//  Created by iosdev on 21.02.2020.
//  Copyright © 2020 SuperDeal Limited Liability Company. All rights reserved.
//

import Foundation
import UIKit

enum TapticEngineFeedbackStyle {
    
    case light
    
    case medium
    
    case heavy
}

enum TapticEngineFeedbackType {
    
    case success

    case warning

    case error
    
}

class TapticEngineGenerator {
    
    static let shared = TapticEngineGenerator()
    
    private init() {}
    
    func generateFeedback(_ style: TapticEngineFeedbackStyle) {
        if #available(iOS 10.0, *) {
            var feedbackType = UIImpactFeedbackGenerator.FeedbackStyle.light
            
            switch style {
            case .light: feedbackType = .light
            case .medium: feedbackType = .medium
            case .heavy: feedbackType = .heavy
            }
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator(style: feedbackType).impactOccurred()
            }
        }
    }
    
    func generateNotification(_ type: TapticEngineFeedbackType) {
        if #available(iOS 10.0, *) {
            var notificationType = UINotificationFeedbackGenerator.FeedbackType.success
            
            switch type {
            case .error: notificationType = .error
            case .success: notificationType = .success
            case .warning: notificationType = .warning
            }
            DispatchQueue.main.async {
                UINotificationFeedbackGenerator().notificationOccurred(notificationType)
            }
        }
    }
    
}
