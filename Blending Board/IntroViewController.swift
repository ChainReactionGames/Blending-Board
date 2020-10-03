//
//  IntroViewController.swift
//  Blending Board
//
//  Created by Gary Gogis on 9/14/20.
//

import UIKit
extension UIVisualEffectView {
	func loseContents() {
		UIView.animate(withDuration: 0.25) {
			self.contentView.alpha = 0
		}
	}
	func gainContents() {
		UIView.animate(withDuration: 0.25) {
			self.contentView.alpha = 1
		}
	}
}
class IntroViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	
	@IBAction func goHome(_ sender: Any) {
		home()
	}
	func home() {
		UIView.animate(withDuration: 0.25) { [self] in
			blur.effect = UIBlurEffect(style: .dark)
			blur.gainContents()
			setCreationView.alpha = 0
			myDecksView.alpha = 0
			deckSavingView.alpha = 0
			mainView.alpha = 0
			settingsView.alpha = 0
		} completion: { (_) in
			UIView.animate(withDuration: 0.6) { [self] in
				mainView.alpha = 1
				mainView.transform = .identity
			}
		}

	}
	@IBOutlet weak var mainView: UIView!
	@IBOutlet weak var setCreationView: UIView!
	@IBOutlet weak var myDecksView: MyDecksView!
	@IBAction func myDecks(_ sender: Any) {
		let width = self.view.bounds.width
		self.myDecksView.transform = CGAffineTransform(translationX: width, y: 0)
		myDecksView.subviews.compactMap({ $0 as? UICollectionView }).first?.reloadData()
		UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.calculationModeCubic], animations: {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 2/3) {
				self.mainView.transform = CGAffineTransform(translationX: -width, y: 0)
			}
			UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3) {
				self.mainView.alpha = 0
			}
			UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 2/3) {
				self.myDecksView.alpha = 1
				self.myDecksView.transform = .identity
			}
		}, completion: nil)
		myDecksView.blur = blur
	}
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
		let currentlySelected = selectedSets[collectionView.tag] == set
		cell.currentlySelected = currentlySelected
		cell.adding = (!currentlySelected && !letterSetEditorView.isHidden)
		cell.letterSet = set
		cell.column = collectionView.tag
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let set = LetterSet.sets(for: positions[collectionView.tag] ?? .all)[indexPath.row]
		if !letterSetEditorView.isHidden {
			letterSetEditor.baseSet.letters += set.letters
			letterSetEditor.letterSet.letters += set.letters
			_ = letterSetEditor.subviews.compactMap({ $0 as? UICollectionView }).map({ $0.reloadData() })
			Haptic.feedback(.select)
			return
		}
		selectedSets[collectionView.tag] = set
		for cell in collectionView.visibleCells as? [LetterSetCollectionViewCell] ?? [] {
			let currentlySelected = cell.letterSet == set
			cell.currentlySelected = currentlySelected
			cell.adding = (!currentlySelected && !letterSetEditorView.isHidden)
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
		NotificationCenter.default.addObserver(self, selector: #selector(editStackBtnPressed(_:)), name: .init("Edit Letter Set"), object: nil)

    }
	override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)
		darkModeSelector.selectedSegmentIndex = Settings.darkModeOverride
		darkModeChange(darkModeSelector)
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
	@IBOutlet weak var deckSavingView: UIView!
	@IBAction func finishDeck(_ sender: Any) {
		UIView.animate(withDuration: 0.25) {
			self.setCreationView.alpha = 0
			self.setCreationView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
		} completion: { (_) in
			self.deckSavingView.transform = CGAffineTransform(translationX: 1.2, y: 1.2)
			UIView.animate(withDuration: 0.25) {
				self.deckSavingView.alpha = 1
				self.deckSavingView.transform = .identity
			}
		}

	}
	@IBOutlet weak var deckNameField: UITextField!
	@IBAction func autoStart(_ sender: UIButton) {
		selectedSets = LetterPack.currentDeck.sets
		confirmDeck(sender)
	}
	@IBAction func confirmDeck(_ sender: UIButton) {
		var pack = LetterPack(name: nil, selectedSets)
		func deny() -> Bool {
			if sender.tag != 1 { return false }
			if let name = deckNameField.text, name.replacingOccurrences(of: " ", with: "") != "" {
				pack.name = name
				LetterPack.allPacks.insert(pack, at: 0)
				return false
			}
			return true
		}
		if deny() {
			Haptic.feedback(.failure)
			deckNameField.jiggle()
			return
		}
		Haptic.feedback(.success)
		deckNameField.endEditing(true)
		NotificationCenter.default.post(name: .packChosen, object: pack)
		UIView.animate(withDuration: 0.25) { [self] in
			blur.effect = nil
			blur.loseContents()
		}
	}
	@objc func editStackBtnPressed(_ notification: Notification) {
		guard let cell = notification.object as? LetterSetCollectionViewCell else { return }
		letterSetEditor.baseSet = cell.letterSet
		letterSetEditor.letterSet = cell.letterSet
		_ = letterSetEditor.subviews.compactMap({ $0 as? UICollectionView }).map({ $0.reloadData() })
		letterSetEditorView.transform = CGAffineTransform(translationX: letterSetEditor.bounds.width, y: 0)
		letterSetEditorView.isHidden = false
		for visibleCell in collectionViews[cell.column].visibleCells as? [LetterSetCollectionViewCell] ?? [] {
			let currentlySelected = visibleCell.letterSet == cell.letterSet
			visibleCell.currentlySelected = currentlySelected
			visibleCell.adding = (!currentlySelected && !letterSetEditorView.isHidden)
		}

		UIView.animate(withDuration: 0.25) { [self] in
			letterSetEditorView.transform = .identity
			if setCollectionViews.isEmpty { return }
			letterSetEditorConstraint.isActive = true
			view.layoutIfNeeded()
		}
		for coll in setCollectionViews {
			coll.stackViewHidden = (coll.tag) != cell.column
		}
		for item in columnStack.arrangedSubviews {
			print(item.tag, cell.column)
			item.stackViewHidden = (item.tag - 1) != cell.column
		}
		editingColumn = cell.column
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
		if let field = letterSetEditor.currentField {
			_ = letterSetEditor.textFieldShouldReturn(field)
			if let text = field.text, text.replacingOccurrences(of: " ", with: "") != "" {
				letterSetEditor.letterSet.letters.append(text)
			}
		}

		selectedSets[editingColumn] = letterSetEditor.letterSet
		UIView.animate(withDuration: 0.25) { [self] in
			letterSetEditorView.transform = CGAffineTransform(translationX: letterSetEditor.bounds.width, y: 0)
			for coll in setCollectionViews {
				coll.stackViewHidden = false
				for cell in coll.visibleCells.compactMap({$0 as? LetterSetCollectionViewCell }) {
					cell.adding = false
				}
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
	
	
	
	@IBAction func openSettings(_ sender: Any) {
		UIView.animate(withDuration: 0.25) {
			self.mainView.alpha = 0
		} completion: { (_) in
			self.settingsView.transform = CGAffineTransform(translationX: 0, y: self.settingsView.bounds.height / 2)
			UIView.animate(withDuration: 0.25) {
				self.settingsView.alpha = 1
				self.settingsView.transform = .identity
			}
		}

	}
	@IBOutlet weak var settingsView: UIView!
	@IBOutlet weak var darkModeSelector: UISegmentedControl!
	@IBAction func darkModeChange(_ sender: UISegmentedControl) {
		Settings.darkModeOverride = sender.selectedSegmentIndex
		parent?.overrideUserInterfaceStyle = Settings.styleFromNumber(sender.selectedSegmentIndex)
	}
	@IBAction func changeTint(_ sender: UIButton) {
		(parent as? BoardViewController)?.changeTint(sender)
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
	var adding: Bool = false {
		willSet {
			editBtn.setImage(UIImage(systemName: newValue ? "plus" : "pencil"), for: .normal)
			editBtn.isUserInteractionEnabled = !newValue
			UIView.animate(withDuration: 0.25) {
				self.editBtn.alpha = newValue || self.currentlySelected ? 1 : 0
			}
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
	@IBAction func editLetterSet(_ sender: Any) {
		NotificationCenter.default.post(name: .init("Edit Letter Set"), object: self)
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
	var currentField: UITextField?
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let cell = collectionView.cellForItem(at: indexPath) as? LetterCell else { return }
		UISelectionFeedbackGenerator().selectionChanged()
		if cell.plus {
			currentField = cell.field
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
	override func layoutSubviews() {
		super.layoutSubviews()
		(subviews.compactMap({$0 as? UICollectionView}).first)?.collectionViewLayout = generateLayout()
	}
	func generateLayout() -> UICollectionViewLayout {
		let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(74), heightDimension: .absolute(74)))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80)), subitems: [item])
		group.interItemSpacing = .fixed(16)
	  let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = 16
	  let layout = UICollectionViewCompositionalLayout(section: section)
	  return layout
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
				colorView.backgroundColor = !newValue ? UIColor.white.withAlphaComponent(0.2) : tintColor
				selectionImg.image = UIImage(systemName: newValue ? "checkmark.circle.fill" : "circle")
				layer.borderColor = tintColor.withAlphaComponent(0.5).cgColor
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
class MyDecksView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
	var blur: UIVisualEffectView?
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		LetterPack.allPacks.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deckCell", for: indexPath) as? DeckCell else { return UICollectionViewCell() }
		cell.deck = LetterPack.allPacks[indexPath.row]
		return cell
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		(subviews.compactMap({$0 as? UICollectionView}).first)?.collectionViewLayout = generateLayout()
		(subviews.compactMap({$0 as? UICollectionView}).first)?.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

	}
	func generateLayout() -> UICollectionViewLayout {
		let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/3.2), heightDimension: .estimated(50)))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), subitems: [item])
		group.interItemSpacing = .fixed(16)
	  let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = 16
	  let layout = UICollectionViewCompositionalLayout(section: section)
	  return layout
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let cell = collectionView.cellForItem(at: indexPath) as? DeckCell else { return }
		Haptic.feedback(.success)
		NotificationCenter.default.post(name: .packChosen, object: cell.deck)
		UIView.animate(withDuration: 0.25) { [self] in
			blur?.effect = nil
			blur?.loseContents()
		}
	}

}
class DeckCell: UICollectionViewCell {
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var editBtn: UIButton!
	@IBOutlet weak var selectionIndicator: UIView?
	var deck: LetterPack = .standardClosed {
		willSet {
			label.text = newValue.name
		}
	}
//	var currentlySelected: Bool = false {
//		willSet {
//			UIView.animate(withDuration: 0.25) { [self] in
//				editBtn.alpha = newValue ? 1 : 0
//				selectionIndicator?.alpha = newValue ? 0.3 : 0
//			}
//		}
//	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	func setup() {
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
		leftSwipe.direction = .left
		self.addGestureRecognizer(leftSwipe)
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
		leftSwipe.direction = .right
		self.addGestureRecognizer(rightSwipe)
	}
	@IBOutlet weak var trashView: UIVisualEffectView!
	@objc func swiped() {
		UIView.animate(withDuration: 0.25){
			self.trashView.isHidden.toggle()
		}
	}
	@IBAction func editLetterSet(_ sender: Any) {
	}
	@IBAction func trash(_ sender: Any) {
		LetterPack.allPacks.removeAll(where: {$0 == self.deck})
		(self.superview as? UICollectionView)?.reloadData()
	}
}
