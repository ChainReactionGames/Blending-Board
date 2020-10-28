//
//  Letter Pack Saving.swift
//  Blending Board
//
//  Created by Gary Gogis on 10/4/20.
//

import Foundation

extension LetterPack: Saving {
	static var key: String = "Saved Decks"
	static var information: [LetterPack] {
		get {
			allPacks
		}
		set {
			allPacks = newValue
		}
	}
	
	typealias DataType = [LetterPack]
	
	static var allPacks = defaultPacks {
		didSet {
			save()
		}
	}
	static func getCurrentDeckFromDefaults() -> LetterPack {
		guard let data = Defaults.value(for: "current deck", type: Data.self) else { return standardOpen }
		return (try? JSONDecoder().decode(LetterPack.self, from: data)) ?? standardOpen
	}
	static var currentDeck = getCurrentDeckFromDefaults() {
		didSet {
			Defaults.set(currentDeck.jsonEncoded, for: "current deck")
		}
	}

}
