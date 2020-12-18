//
//  Color Views.swift
//  Blending Board
//
//  Created by Gary Gogis on 10/4/20.
//

import UIKit
class TintAdjustingLabel: UILabel {
	override func tintColorDidChange() {
		super.tintColorDidChange()
		UIView.transition(with: self, duration: 0.2, options: [.transitionCrossDissolve], animations: { [self] in
			if tintColor == .systemYellow {
				textColor = .systemOrange
			} else {
				textColor = tintColor
			}
		}, completion: nil)
	}
}
class TintAdjustingView: UIView {
	override func tintColorDidChange() {
		super.tintColorDidChange()
		UIView.animate(withDuration: 0.2) { [self] in
			backgroundColor = tintColor
		}
	}
}
class TintAdjustingBackgroundImage: UIImageView {
	override func tintColorDidChange() {
		super.tintColorDidChange()
		let imgName: String = {
			switch tintColor {
			case Colors.red:
				return "backgroundRed"
			case Colors.yellow:
				return "backgroundYellow"
			case Colors.green:
				return "backgroundGreen"
			case Colors.purple:
				return "backgroundPurple"
			case Colors.pink:
				return "backgroundPink"
			case Colors.gray:
				return "backgroundGray"
			case Colors.pumpkin:
				return "backgroundPumpkin"
			case Colors.winter:
				return "backgroundWinter"
			default:
				return "defaultBackground"
			}
		}()
		UIView.transition(with: self, duration: 0.2, options: [.transitionCrossDissolve], animations: {
			self.image = UIImage(named: imgName)
		}, completion: nil)
	}
}
extension UIView {
	func jiggle() {
		UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.calculationModeCubic], animations: {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/4) {
				self.center.x += 5
			}
			UIView.addKeyframe(withRelativeStartTime: 1/4, relativeDuration: 1/2) {
				self.center.x -= 10
			}
			UIView.addKeyframe(withRelativeStartTime: 3/4, relativeDuration: 1/4) {
				self.center.x += 5
			}
			
		}, completion: nil)
	}
	func constrain(to view: UIView) {
		let widthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
		let heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
		let centerX = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
		let centerY = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
		guard let superview = self.superview else { return }
		superview.addConstraints([widthConstraint, heightConstraint, centerX, centerY])
	}
	@IBInspectable var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
		}
	}
	@IBInspectable var radialCurve: Bool {
		get {
			self.layer.cornerCurve == .circular
		}
		set {
			self.layer.cornerCurve = newValue ? .circular : .continuous
		}
	}
	@IBInspectable var useBlurShadow: Bool {
		get {
			layer.shadowOpacity > 0
		}
		set {
			if newValue {
				blurShadow()
			}
		}
	}
	
	func blurShadow() {
		self.layer.masksToBounds = false
		self.layer.shadowRadius = 5
		self.layer.shadowOpacity = 0.6
		self.layer.shadowOffset = .zero
	}
	
}
