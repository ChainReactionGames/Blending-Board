//
//  LetterCard.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/6/20.
//

import UIKit

class LetterCard: UIView {
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var letterField: UITextField!
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
    }
    @objc func panInSelf(_ pan: UIPanGestureRecognizer) {
        let trans = pan.translation(in: self.superview)
        switch pan.state {
        case .ended, .cancelled, .failed:
            UIView.animate(withDuration: Double(sqrt(pow(trans.x, 2) + pow(trans.y, 2)) / 250), animations: {
                self.transform = .identity
            }, completion: { _ in
                self.layer.zPosition = 1
            })
        default:
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.transform = CGAffineTransform(translationX: trans.x, y: trans.y).rotated(by: pow(abs(trans.x), 1) / 600 * (trans.x < 0 ? -.pi : .pi))
        }
    }
}
