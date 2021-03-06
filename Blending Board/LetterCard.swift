//
//  LetterCard.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/6/20.
//

import UIKit
class LetterCard: UIView {
	func font() -> UIFont? {
		print(UIFont.familyNames)
		if letterField.font?.familyName != "DidactGothic" {
			return UIFont(name: "DidactGothic-Regular", size: letterField.font?.pointSize ?? 62)
		} else {
			return letterField.font
		}
	}
    override func tintColorDidChange() {
        super.tintColorDidChange()
        UIView.animate(withDuration: 0.25) {
            self.generateUI()
        }
    }
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var letterField: UITextField!
    @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    var intPosition = 0 {
        didSet {
            position = Double(intPosition)
            self.isUserInteractionEnabled = intPosition == 0
        }
    }
    var position: Double = 0 {
        didSet {
            if position < 0 {
                position = 0
            }
        }
    }
    static var maxPosition: Double = 3
    var invisible: Bool {
        position >= LetterCard.maxPosition
    }
    func generateUI(animatingBlur: Bool = true) {
        let maxPos = LetterCard.maxPosition
        letterField.textColor = textColor
		letterField.font = font()
        tintView.backgroundColor = tintColor
        tintView.isHidden = !letter.isVowel
        let changed = (blur.effect != nil && invisible) || (blur.effect == nil && !invisible)
        if changed {
            var animationDuration = 1.0
            if !animatingBlur { animationDuration = 0 }
            UIView.animate(withDuration: animationDuration) {
                if self.invisible {
                    self.blur.effect = nil
                    self.tintView.alpha = 0
                } else {
                    self.blur.effect = UIBlurEffect(style: .regular)
                    self.tintView.alpha = 0.3
                }
            }
        }
        let alpha = max((-1 / CGFloat(maxPos - 2)) * CGFloat(position) + 1, 0)
        backView.alpha = alpha
        letterField.alpha = alpha
        centerYConstraint.constant = CGFloat(-20 * position)
        widthConstraint.constant = CGFloat(-20 * position)
        layoutIfNeeded()
        
    }
    var letter: Letter = "nd" {
        willSet {
            self.letterField.text = newValue
        }
    }
    var textColor: UIColor {
		let returningColor: UIColor = self.letter.isVowel ? tintColor : Colors.text
		if returningColor == UIColor.systemYellow {
			return Colors.text
		}
		return returningColor
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    func setup() {
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panInSelf(_:)))
        pan.cancelsTouchesInView = true
        self.addGestureRecognizer(pan)
        self.isUserInteractionEnabled = true
    }
    var panHandle: ((UIPanGestureRecognizer) -> ())? = nil
    @objc func panInSelf(_ pan: UIPanGestureRecognizer) {
        let trans = pan.translation(in: self.superview)
        print(trans)
        switch pan.state {
        case .ended, .cancelled, .failed:
            break
        default:
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.transform = CGAffineTransform(translationX: trans.x, y: trans.y).rotated(by: pow(abs(trans.x), 1) / 600 * (trans.x < 0 ? -.pi : .pi))
        }
        self.panHandle?(pan)
    }
    var referenceView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    func fall(_ completion: ((Bool) -> ())? ){
        let rot = atan2(Double(transform.b), Double(transform.a))
        let finalTransform = (referenceView.bounds.height / 2) + self.bounds.height
        let percent = transform.ty / finalTransform
        let dur = min(Double((1 - percent) * 1), 1.5)
        print(dur)
        UIView.animate(withDuration: dur, animations:  {
            self.transform = CGAffineTransform(translationX: self.transform.tx, y: finalTransform).rotated(by: CGFloat(rot))
        }, completion: completion)
    }
    func returnSelf() {
        let trans = CGPoint(x: self.transform.tx, y: self.transform.ty)
        UIView.animate(withDuration: Double(sqrt(pow(trans.x, 2) + pow(trans.y, 2)) / 250), animations: {
            self.transform = .identity
        }, completion: { _ in
        })
    }
}
class CardStack: UIView {
    var letterSet: LetterSet = .magicEMiddle
	var letters = [Letter]() {
		didSet {
			let letterContents = letters
			while letters.count < 4 {
				letters.append(contentsOf: letterContents)
			}
		}
	}
    var count: Int {
        min(letters.count, 4)
    }
    @IBOutlet var cards: [LetterCard]!
    func setup(_ set: LetterSet) {
        letterSet = set
        letters = letterSet.letters
        for i in 0 ..< cards.count {
            cards[i].referenceView = self.superview!.superview!
            cards[i].letter = letters[0]
            cards[i].intPosition = i
            cards[i].generateUI()
            cards[i].panHandle = panInCard
            letters.append(letters.remove(at: 0))
        }
        updateOrdering()
		let tap = UITapGestureRecognizer(target: self, action: #selector(fallFrontCardFromTap))
		addGestureRecognizer(tap)
    }
    func updateOrdering() {
        for card in cards {
            card.layer.zPosition = CGFloat(10 - card.intPosition)
        }
    }
	@discardableResult func frontCardShouldFall(cardsToMove: ArraySlice<LetterCard>, forceFall: Bool = false) -> Bool {
		var shouldFall = false
		for card in cardsToMove {
			if forceFall {
				card.position = Double(card.intPosition) - 1
			}
			if card.intPosition != Int(card.position.rounded()) {
				shouldFall = true
				card.intPosition = Int(card.position.rounded())
				UIView.animate(withDuration: 0.5) {
					card.generateUI()
				} completion: { (_) in
					self.updateOrdering()
				}
			} else {
				card.position = Double(card.intPosition)
				UIView.animate(withDuration: 0.5) {
					card.generateUI()
				}
			}
		}
		return shouldFall
	}
    func panInCard(_ pan: UIPanGestureRecognizer) {
		if pan.state == .began {
			superview?.bringSubviewToFront(self)
		}
        let trans = pan.translation(in: self)
        let cardsToMove = cards[1 ..< cards.count]
        switch pan.state {
        case .ended, .cancelled, .failed:
			let shouldFall = frontCardShouldFall(cardsToMove: cardsToMove)
            if shouldFall {
				fallFrontCard()
            } else {
                cards[0].returnSelf()
            }
        default:
            for card in cardsToMove {
                card.position = min(max(Double(card.intPosition) - (Double(trans.y) / 150), Double(card.intPosition) - 1), Double(card.intPosition))
                UIView.animate(withDuration: 0.1) {
                    card.generateUI()
				} completion: { (_) in
					self.updateOrdering()
				}
            }
        }
    }
	@objc func fallFrontCardFromTap() {
		frontCardShouldFall(cardsToMove: cards[1..<cards.count], forceFall: true)
		fallFrontCard()
	}
	func fallFrontCard() {
		let firstCard = cards[0]
		self.isUserInteractionEnabled = false
		firstCard.fall { (_) in
			let card = firstCard
			card.isHidden = true
			card.intPosition = self.count - 1
			card.letter = self.letters.first ?? ""
			self.letters.append(self.letters.remove(at: 0))
			card.transform = .identity
			self.updateOrdering()
			card.generateUI(animatingBlur: false)
			card.isHidden = false
			self.cards.append(self.cards.remove(at: 0))
			print(card.intPosition)
			self.isUserInteractionEnabled = true
		}

	}
}
