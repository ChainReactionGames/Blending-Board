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
	static var event: UIColor {
		pumpkin
	}
	static let pumpkin: UIColor = #colorLiteral(red: 1, green: 0.490264833, blue: 0, alpha: 1)
	static let winter: UIColor = #colorLiteral(red: 0, green: 0.8774341941, blue: 0.720389602, alpha: 1)
    static func make(named name: String, defaultColor: UIColor) -> UIColor {
        if let returningColor = UIColor(named: name) {
            return returningColor
        }
        return defaultColor
    }
	static let tintOptions = [red, yellow, green, blue, purple, pink, gray, event]
	static var chosenColorIndex: Int = Defaults.value(for: "colorIndex", type: Int.self) ?? 3 {
		willSet {
			Defaults.set(newValue, for: "colorIndex")
		}
	}
	static var chosenColor: UIColor {
		tintOptions[chosenColorIndex]
	}
}
