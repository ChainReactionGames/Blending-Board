//
//  LetterCard.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/6/20.
//

import UIKit
struct Colors {
    static let text: UIColor = make(named: "Text", defaultColor: .label)
    static func make(named name: String, defaultColor: UIColor) -> UIColor {
        if let returningColor = UIColor(named: name) {
            return returningColor
        }
        return defaultColor
    }
}
class LetterCard: UIView {
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
    var position: Double = 0 {
        didSet {
            if position < 0 {
                position = 0
            }
//            self.isUserInteractionEnabled = position == 0
        }
    }
    static var maxPosition: Double = 3
    var invisible: Bool {
        position >= LetterCard.maxPosition
    }
    func generateUI() {
        let maxPos = LetterCard.maxPosition
        letterField.textColor = textColor
        tintView.backgroundColor = tintColor
        tintView.isHidden = !letter.isVowel
        let changed = (blur.effect != nil && invisible) || (blur.effect == nil && !invisible)
        if changed {
            if invisible {
                blur.effect = nil
                tintView.alpha = 0
            } else {
                blur.effect = UIBlurEffect(style: .regular)
                tintView.alpha = 0.3
            }
        }
        let alpha = CGFloat((maxPos - position)) / CGFloat(maxPos)
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
        self.letter.isVowel ? tintColor : Colors.text
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
        self.addGestureRecognizer(pan)
        self.isUserInteractionEnabled = true
    }
    @objc func panInSelf(_ pan: UIPanGestureRecognizer) {
        let trans = pan.translation(in: self.superview)
        print(trans)
        switch pan.state {
        case .ended, .cancelled, .failed:
            UIView.animate(withDuration: Double(sqrt(pow(trans.x, 2) + pow(trans.y, 2)) / 250), animations: {
                self.transform = .identity
            }, completion: { _ in
                self.layer.zPosition = 1
            })
        default:
            self.layer.zPosition = 2
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.transform = CGAffineTransform(translationX: trans.x, y: trans.y).rotated(by: pow(abs(trans.x), 1) / 600 * (trans.x < 0 ? -.pi : .pi))
        }
    }
}
class CardStack: UIView {
    @IBOutlet var cards: [LetterCard]!
    func setup() {
        for i in 0 ..< cards.count {
            cards[i].position = Double(i)
        }
    }
}
