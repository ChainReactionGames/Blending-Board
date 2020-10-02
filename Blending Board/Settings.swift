//
//  Settings.swift
//  Blending Board
//
//  Created by Gary Gogis on 10/1/20.
//

import UIKit

struct Settings {
	static var darkModeOverride = Defaults.value(for: "darkOverride", type: Int.self) ?? 1 {
		willSet {
			Defaults.set(darkModeOverride, for: "darkOverride")
		}
	}
	static func styleFromNumber(_ int: Int) -> UIUserInterfaceStyle {
		switch int {
		case 0:
			return .light
		case 2:
			return .dark
		default:
			return .unspecified
		}
	}
}
class BrainVC: UIViewController {
	@IBAction func close() {
		dismiss(animated: true, completion: nil)
	}
	@IBAction func brain() {
		if let url = URL(string: "http://www.dyslexicmindset.com") {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
}
