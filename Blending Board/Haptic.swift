//
//  Haptic.swift
//  Blending Board
//
//  Created by Gary Gogis on 9/29/20.
//

import UIKit

struct Haptic {
	// MARK: - Default Haptics
	enum HapticType {
		case select, heavy, medium, light, rigid, soft, success, warning, failure
	}
	fileprivate static let selection = UISelectionFeedbackGenerator()
	fileprivate static let lightImpact = UIImpactFeedbackGenerator(style: .light)
	fileprivate static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
	fileprivate static let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
	fileprivate static let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
	fileprivate static let softImpact = UIImpactFeedbackGenerator(style: .soft)
	fileprivate static let notification = UINotificationFeedbackGenerator()
	
	/// Prepares a Haptic Feedback Generator to give feedback
	/// - Parameter type: the haptic type to use
	static func prepare(_ type: HapticType){
		switch type {
		case .select:
			selection.prepare()
		case .light:
			lightImpact.prepare()
		case .medium:
			mediumImpact.prepare()
		case .heavy:
			heavyImpact.prepare()
		case .rigid:
			rigidImpact.prepare()
		case .soft:
			softImpact.prepare()
			
		default:
			notification.prepare()
		}
	}
	/// Provides feedback from a Haptic Feedback Generator
	/// - Parameters:
	///   - type: the haptic type to use
	///   - intensity: If the feedback generator is a `UIImpactFeedbackGenerator`, which, in this case, are `.light, .medium, .heavy, .rigid, .soft`,
	///		the intensity of the haptic feedback
	///
	/// - Warning:
	///   If the feedback type is not one of the `UIImpactFeedbackGenerator` types (`.light, .medium, .heavy, .rigid, .soft`), the `intensity` parameter will not be used
	static func feedback(_ type: HapticType, intensity: CGFloat = 1.0){
		switch type {
		case .select:
			selection.selectionChanged()
		case .light:
			lightImpact.impactOccurred(intensity: intensity)
		case .medium:
			mediumImpact.impactOccurred(intensity: intensity)
		case .heavy:
			heavyImpact.impactOccurred(intensity: intensity)
		case .rigid:
			rigidImpact.impactOccurred(intensity: intensity)
		case .soft:
			softImpact.impactOccurred(intensity: intensity)
		case .success:
			notification.notificationOccurred(.success)
		case .warning:
			notification.notificationOccurred(.warning)
		case .failure:
			notification.notificationOccurred(.error)
		}
	}
	
}
