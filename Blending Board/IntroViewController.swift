//
//  IntroViewController.swift
//  Blending Board
//
//  Created by Gary Gogis on 9/14/20.
//

import UIKit

class IntroViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	@IBOutlet weak var mainView: UIView!
	@IBOutlet weak var setCreationView: UIView!
	@IBAction func createDeck(_ sender: Any) {
		let width = self.view.bounds.width
		self.setCreationView.transform = CGAffineTransform(translationX: -width, y: 0)
		UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.calculationModeCubic], animations: {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 2/3) {
				self.mainView.transform = CGAffineTransform(translationX: width, y: 0)
			}
			UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3) {
				self.mainView.alpha = 0
			}
			UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 2/3) {
				self.setCreationView.alpha = 1
				self.setCreationView.transform = .identity
			}
		}, completion: nil)
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		LetterSet.sets(for: positions[collectionView.tag] ?? .all).count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "setCell", for: indexPath) as? LetterSetCollectionViewCell else { return UICollectionViewCell() }
		let set = LetterSet.sets(for: positions[collectionView.tag] ?? .all)[indexPath.row]
		cell.currentlySelected = selectedSets[collectionView.tag] == set
		cell.letterSet = set
		cell.column = collectionView.tag
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let set = LetterSet.sets(for: positions[collectionView.tag] ?? .all)[indexPath.row]
		selectedSets[collectionView.tag] = set
		for cell in collectionView.visibleCells as? [LetterSetCollectionViewCell] ?? [] {
			cell.currentlySelected = cell.letterSet == set
		}
		UISelectionFeedbackGenerator().selectionChanged()
	}
	var selectedSets: [LetterSet] = []
	let positions: [Int: LetterSet.Position] = [0: .beginning, 1: .middle, 2: .end]
    override func viewDidLoad() {
        super.viewDidLoad()
		selectedSets = LetterPack.standardOpen.sets
		for collView in collectionViews {
			collView.collectionViewLayout = generateLayout()
		}
    }
	@IBOutlet var collectionViews: [UICollectionView]!
	func generateLayout() -> UICollectionViewLayout {
		let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [item])
	  let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = 8
	  let layout = UICollectionViewCompositionalLayout(section: section)
	  return layout
	}
	@IBOutlet weak var blur: UIVisualEffectView!
	@IBAction func confirmDeck(_ sender: Any) {
		NotificationCenter.default.post(name: .packChosen, object: LetterPack(name: "Custom Pack", beginning: selectedSets[0], middle: selectedSets[1], end: selectedSets[2]))
		UIView.animate(withDuration: 0.25) { [self] in
			blur.effect = nil
			_ = blur.subviews.map({ $0.alpha = 0 })
		}
	}
	
	@IBAction func editStackBtn(_ sender: UIButton) {
		if let cell = sender.superview?.superview as? LetterSetCollectionViewCell {
			letterSetEditor.baseSet = cell.letterSet
			letterSetEditor.letterSet = cell.letterSet
			_ = letterSetEditor.subviews.compactMap({ $0 as? UICollectionView }).map({ $0.reloadData() })
			letterSetEditorView.transform = CGAffineTransform(translationX: letterSetEditor.bounds.width, y: 0)
			letterSetEditorView.isHidden = false
			UIView.animate(withDuration: 0.25) { [self] in
				letterSetEditorView.transform = .identity
				for coll in setCollectionViews {
					coll.stackViewHidden = (coll.tag) != cell.column
				}
				for item in columnStack.arrangedSubviews {
					print(item.tag, cell.column)
					item.stackViewHidden = (item.tag - 1) != cell.column
				}
				letterSetEditorConstraint.isActive = true
				view.layoutIfNeeded()
			}
			editingColumn = cell.column
		}
	}
	@IBOutlet weak var letterSetEditorView: UIVisualEffectView!
	@IBOutlet weak var letterSetEditor: LetterSetEditor!
	@IBOutlet weak var letterSetEditorConstraint: NSLayoutConstraint!
	@IBOutlet weak var setStack: UIStackView!
	@IBOutlet weak var columnStack: UIStackView!
	var setCollectionViews: [UICollectionView] {
		setStack.arrangedSubviews.compactMap({$0 as? UICollectionView}).sorted(by: { $0.tag < $1.tag })
	}
	var editingColumn = 0
	@IBAction func confirmSetEdits(_ sender: Any) {
		selectedSets[editingColumn] = letterSetEditor.letterSet
		UIView.animate(withDuration: 0.25) { [self] in
			letterSetEditorView.transform = CGAffineTransform(translationX: letterSetEditor.bounds.width, y: 0)
			for coll in setCollectionViews {
				coll.stackViewHidden = false
			}
			for item in columnStack.arrangedSubviews {
				item.stackViewHidden = false
			}
			letterSetEditorConstraint.isActive = false
			view.layoutIfNeeded()
		} completion: { (_) in
			self.letterSetEditorView.isHidden = true
		}

	}
}
class LetterSetCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var editBtn: UIButton!
	@IBOutlet weak var selectionIndicator: UIView!
	var letterSet: LetterSet = .empty {
		willSet {
			label.text = newValue.name
		}
	}
	var column = 1
	var currentlySelected: Bool = false {
		willSet {
			UIView.animate(withDuration: 0.25) { [self] in
				editBtn.alpha = newValue ? 1 : 0
				selectionIndicator.alpha = newValue ? 0.3 : 0
			}
		}
	}
}
class LetterSetEditor: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
	var baseSet: LetterSet = .singleConsonantsEnding
	var letterSet: LetterSet = .singleConsonantsEnding
	var representingLetters: [Letter] {
		(baseSet.letters + letterSet.letters).removingDuplicates()
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		representingLetters.count + 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "letterCell", for: indexPath) as? LetterCell else { return UICollectionViewCell() }
		if indexPath.row >= representingLetters.count {
			cell.plus = true
			return cell
		}
		cell.plus = false
		cell.field.delegate = self
		cell.letter = representingLetters[indexPath.row]
		cell.showSelected = letterSet.letters.contains(cell.letter)
		collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 250, right: 0)
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let cell = collectionView.cellForItem(at: indexPath) as? LetterCell else { return }
		UISelectionFeedbackGenerator().selectionChanged()
		if cell.plus {
			cell.field.isHidden = false
			cell.letterLbl.isHidden = true
			cell.field.becomeFirstResponder()
			return
		}
		cell.showSelected.toggle()
		if !cell.showSelected {
			letterSet.letters.removeAll(where: { $0 == cell.letter })
		} else {
			letterSet.letters.append(cell.letter)
		}
		print(letterSet.letters, baseSet.letters)
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.endEditing(true)
		if let text = textField.text {
			baseSet.letters.append(text)
			letterSet.letters.append(text)
			_ = subviews.compactMap({ $0 as? UICollectionView }).map({ $0.reloadData() })
		}
		return false
	}
}
class LetterCell: UICollectionViewCell {
	@IBOutlet weak var field: UITextField!
	var letter: Letter = "a" {
		willSet {
			letterLbl.text = newValue
			if !field.isFirstResponder {
				field.isHidden = true
				letterLbl.isHidden = false
			}
		}
	}
	@IBOutlet weak var colorView: UIView!
	@IBOutlet weak var selectionImg: UIImageView!
	var showSelected: Bool = false {
		willSet {
			if plus { return }
			UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve]) { [self] in
				colorView.backgroundColor = !newValue ? UIColor.white.withAlphaComponent(0.2) : .systemBlue
				selectionImg.image = UIImage(systemName: newValue ? "checkmark.circle.fill" : "circle")
				layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
				layer.borderWidth = newValue ? 2 : 0
			} completion: { (_) in
			}

		}
	}
	var plus: Bool = false {
		willSet {
			if newValue {
				letterLbl.text = "􀅼"
				colorView.backgroundColor = .clear
				selectionImg.image = nil
				layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
				layer.borderWidth = 2
			} else {
				self.letter = String(letter)
				self.showSelected = Bool(showSelected)
			}
		}
	}
	@IBOutlet weak var letterLbl: UILabel!
	
}
extension Array where Element: Hashable {
	func removingDuplicates() -> [Element] {
		var addedDict = [Element: Bool]()

		return filter {
			addedDict.updateValue(true, forKey: $0) == nil
		}
	}

	mutating func removeDuplicates() {
		self = self.removingDuplicates()
	}
}
