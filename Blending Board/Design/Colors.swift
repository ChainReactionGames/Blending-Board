//
//  Colors.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/13/20.
//

import UIKit

struct Colors {
    static let text: UIColor = make(named: "Text", defaultColor: .label)
    static let red: UIColor = .systemRed
    static let yellow: UIColor = .systemYellow
    static let green: UIColor = .systemGreen
    static let blue: UIColor = .systemBlue
    static let purple: UIColor = .systemPurple
    static let pink: UIColor = .systemPink
    static let gray: UIColor = .systemGray
    static func make(named name: String, defaultColor: UIColor) -> UIColor {
        if let returningColor = UIColor(named: name) {
            return returningColor
        }
        return defaultColor
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
            default:
                return "defaultBackground"
            }
        }()
        UIView.transition(with: self, duration: 0.2, options: [.transitionCrossDissolve], animations: {
            self.image = UIImage(named: imgName)
        }, completion: nil)
    }
}
