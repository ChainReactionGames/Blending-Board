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
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let set = LetterSet.sets(for: positions[collectionView.tag] ?? .all)[indexPath.row]
		selectedSets[collectionView.tag] = set
		for cell in collectionView.visibleCells as? [LetterSetCollectionViewCell] ?? [] {
			cell.currentlySelected = cell.letterSet == set
		}
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
	var currentlySelected: Bool = false {
		willSet {
			UIView.animate(withDuration: 0.25) {
				self.editBtn.isHidden = !newValue
				self.editBtn.alpha = newValue ? 1 : 0
				self.selectionIndicator.alpha = newValue ? 0.3 : 0
			}
		}
	}
}
