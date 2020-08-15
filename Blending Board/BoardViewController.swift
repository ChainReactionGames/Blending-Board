//
//  ViewController.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/6/20.
//

import UIKit

class BoardViewController: UIViewController, UIPickerViewDelegate {

    @IBOutlet var stacks: [CardStack]!
    var pack = LetterPack.standardOpen
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		setupStacks()
		deckPicker.delegate = self
    }
	func setupStacks() {
		pack = newPack
        stacks[0].setup(pack.beginning)
        stacks[1].setup(pack.middle)
        stacks[2].setup(pack.end)
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateDeckEditRadius(animationDuration: 0)
	}
    @IBAction func changeTint(_ sender: UIButton) {
        view.tintColor = sender.tintColor
    }
    
	@IBOutlet weak var deckEditView: UIVisualEffectView!
	func updateDeckEditRadius(animationDuration: TimeInterval = 0.25) {
		print(deckEditView.layer.cornerRadius)
		let open = !deckEditStack.isHidden
		UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut) {
			self.deckEditView.layer.cornerRadius = open ? 15 : self.deckEditView.bounds.height / 2
			self.deckEditView.layer.cornerCurve = open ? .continuous : .circular
		}.startAnimation()
	}
	@IBOutlet weak var editDeckButtonView: UIVisualEffectView!
	@IBOutlet weak var deckEditStack: UIStackView!
	@IBOutlet weak var deckPickContainerView: UIVisualEffectView!
	@IBOutlet weak var deckPicker: DeckPicker!
	@IBAction func toggleDeckEdit(_ sender: Any) {
		let openingStack = deckEditStack.isHidden
		UIView.animate(withDuration: 0.25, animations: {
			self.editDeckButtonView.stackViewHidden = openingStack
			self.deckEditStack.stackViewHidden = !openingStack
		}, completion: nil)
		updateDeckEditRadius()
		if newPack != pack {
			setupStacks()
		}
	}
	let positions: [LetterSet.Position] = [.beginning, .middle, .end]
	var editingTag = 0
	@IBOutlet var deckEditBtns: [UIButton]!
	@IBAction func pickDeck(_ sender: UIButton) {
		deckEditStack.changeViewPosition(self.deckPickContainerView, to: sender.tag + 1)
		deckPicker.setup(for: positions[sender.tag])
		editingTag = sender.tag
	}
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
				guard let picker = pickerView as? DeckPicker, let name = picker.deckPickerSource?.letterSets[row].name else { return nil }
		var font = UIFont.systemFont(ofSize: 5)
		if let roundDescript = font.fontDescriptor.withDesign(.rounded) {
			font = UIFont(descriptor: roundDescript, size: 5)
		}
		return NSAttributedString(string: name)//, attributes: [.foregroundColor: UIColor.white, .font: font])
	}
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		let lbl = view as? UILabel ?? UILabel()
		func prepareLbl(_ lbl: UILabel) {
			var font = UIFont.systemFont(ofSize: 17)
			if let roundDescript = font.fontDescriptor.withDesign(.rounded) {
				font = UIFont(descriptor: roundDescript, size: 17)
			}
			lbl.textColor = .white
			lbl.textAlignment = .center
			if let picker = pickerView as? DeckPicker, let data = picker.deckPickerSource {
				lbl.text = data.letterSets[row].name
			}
			lbl.font = font
		}
		prepareLbl(lbl)
		return lbl

	}
	var newPack: LetterPack = LetterPack.standardOpen
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		guard let picker = pickerView as? DeckPicker, let set = picker.deckPickerSource?.letterSets[row], let name = set.name else { return  }
		deckEditBtns[editingTag].setTitle(name, for: .normal)
		switch positions[editingTag] {
		case .middle:
			newPack.middle = set
		case .end:
			newPack.end = set
		default:
			newPack.beginning = set
		}
	}
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
class DeckPicker: UIPickerView {
	var deckPickerSource: DeckPickerDataSource? {
		willSet {
			self.dataSource = newValue
		}
	}
	func setup(for position: LetterSet.Position) {
		let letterSets = LetterSet.sets(for: position)
		deckPickerSource = DeckPickerDataSource(letterSets: letterSets)
	}
}
class DeckPickerDataSource: NSObject, UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		letterSets.count
	}
	var letterSets: [LetterSet]
	init(letterSets: [LetterSet]) {
		self.letterSets = letterSets
	}
}
