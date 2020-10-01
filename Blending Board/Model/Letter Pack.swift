//
//  Letter Pack.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/6/20.
//

import Foundation

struct LetterPack: Equatable, Codable {
    var name: String?
    var beginning: LetterSet
    var middle: LetterSet
    var end: LetterSet
	
	var sets: [LetterSet] {
		[beginning, middle, end]
	}
}
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
	
	
    init(name: String?, _ sets: [LetterSet]) {
        let standardizedArray = sets + Array(repeating: LetterSet.none, count: 3 - sets.count)
        self = LetterPack(name: name, beginning: standardizedArray[0], middle: standardizedArray[1], end: standardizedArray[2])
    }
    
    // MARK: - Default Values
    
    static var standardClosed = LetterPack(name: "Standard (Closed Syllable)", [.singleConsonantsBeginning, .closedSyllable, .singleConsonantsEnding])
	static var standardOpen = LetterPack(name: "Standard (Open Syllable)", [.singleConsonantsBeginning, .openSyllable, .singleConsonantsEnding])
	static var blendingDemo = LetterPack(name: "Blending Demo", beginning: LetterSet(name: "Bl", position: .beginning, letters: ["bl"]), middle: LetterSet(name: "e", position: .middle, letters: ["E"]), end: LetterSet(name: "Nd", position: .beginning, letters: ["nd"]))

    static let defaultPacks = [standardClosed, standardOpen, blendingDemo]
	static var allPacks = defaultPacks {
		didSet {
			save()
		}
	}

}
