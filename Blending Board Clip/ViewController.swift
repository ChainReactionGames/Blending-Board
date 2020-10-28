//
//  ViewController.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/6/20.
//

import UIKit
extension Notification.Name {
	static let packChosen = Notification.Name("Pack Chosen")
}
class SimpleBoardViewController: UIViewController {
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
	var doubleReg: Bool {
		traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
	}
	@IBOutlet var stacks: [CardStack]!
	var pack = LetterPack.standardOpen
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		setupStacks()
		NotificationCenter.default.addObserver(self, selector: #selector(packConfirmed(_:)), name: .packChosen, object: nil)
		view.tintColor = .systemBlue
		cardStackView.tintColor = .systemYellow
	}
	@IBOutlet weak var cardStackView: UIStackView!
	@objc func packConfirmed(_ notif: Notification) {
		guard let pack = notif.object as? LetterPack else { return }
		newPack = pack
		setupStacks()
		UIView.animate(withDuration: 0.25) { [self] in
			cardStackView.alpha = 1
		}
	}
	func setupStacks() {
		pack = newPack
		stacks[0].setup(pack.beginning)
		stacks[1].setup(pack.middle)
		stacks[2].setup(pack.end)
	}
	let positions: [LetterSet.Position] = [.beginning, .middle, .end]
	var editingTag = 0
	var newPack: LetterPack = LetterPack.standardOpen
}
extension UIView {
	var stackViewHidden: Bool {
		get { isHidden }
		set {
			UIView.animate(withDuration: 0.25, animations: {
				self.isHidden = newValue
				self.alpha = self.isHidden ? 0 : 1
			}, completion: nil)
		}
	}
}
extension UIStackView {
	func stackIndex(of view: UIView) -> Int? {
		arrangedSubviews.firstIndex(of: view)
	}
	func changeViewPosition(_ view: UIView, to position: Int) {
		let alreadyThere = stackIndex(of: view) == position
		if alreadyThere { return }
		view.stackViewHidden = true
		Time.delay(0.25) { [weak self] in
			self?.removeArrangedSubview(view)
			self?.setNeedsLayout()
			self?.layoutIfNeeded()
			self?.insertArrangedSubview(view, at: position)
			view.stackViewHidden = false
		}
	}
}
struct Time {
	static func delay(_ delay: Double, closure: @escaping () -> () ){
		let when = DispatchTime.now() + delay
		DispatchQueue.main.asyncAfter(deadline: when) {
			closure()
		}
	}
	static func repeating(_ interval: TimeInterval, closure: @escaping (_ timer: Timer) -> () ) -> Timer {
		Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer) in
			closure(timer)
		}
	}
}
extension LetterPack {
	static var allPacks = defaultPacks
}
struct Colors {
	static let text = make(named: "Text", defaultColor: .label)
	static func make(named name: String, defaultColor: UIColor) -> UIColor {
		if let returningColor = UIColor(named: name) {
			return returningColor
		}
		return defaultColor
	}
}
extension UIView {
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
}
