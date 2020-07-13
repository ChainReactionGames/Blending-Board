//
//  Letter Set.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/6/20.
//

import Foundation
struct LetterSet {
    struct Position: OptionSet {
        let rawValue: Int
        static let beginning = Position(rawValue: 1 << 0)
        static let middle = Position(rawValue: 1 << 1)
        static let end = Position(rawValue: 1 << 2)
        static let sides: Position = [.beginning, .end]
        static let all: Position = [.beginning, .middle, .end]
    }
    var name: String?
    var position: Position
    var letters: [Letter]
}


// MARK: - Default Values

extension LetterSet {
    
    // MARK: Consonants
    static var singleConsonants = LetterSet(name: "Single Consonants", position: .sides, letters: ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p ", "qu", "r", "s", "t", "v", "w", "x", "y", "z"])
    static var hBrothers = LetterSet(name: "H Brothers", position: .sides, letters: ["ch", "ph", "sh", "th", "wh"])
    static var beginningBlends = LetterSet(name: "Beginning Blends", position: .beginning, letters: ["bl", "br", "cl", "cr", "dr", "fl", "fr", "gl", "gr", "pl", "pr", "sc", "scr", "shr", "sk", "sl", "sm", "sn", "sp", "spl", "spr", "squ", "st", "str", "sw", "thr", "tr", "tw"])
    static var shortVowelPointers = LetterSet(name: "Short Vowel Pointers", position: .beginning, letters: ["ck", "dge", "tch", "ff", "ll", "ss", "zz"])
    static var endingBlends = LetterSet(name: "Ending Blends", position: .end, letters: ["sk", "sp", "st", "ct", "ft", "lk", "lt", "mp", "nch", "nd", "nt", "pt"])
    static var magicEEnding = LetterSet(name: "Magic E", position: .end, letters: ["be", "ce", "de", "fe", "ge", "ke", "le", "me", "ne", "pe", "se", "te"])

    
    // MARK: Syllables
    static var closedSyllable = LetterSet(name: "Closed Syllable", position: .middle, letters: ["a", "e", "i", "o", "u"])
    static var openSyllable = LetterSet(name: "Open Syllable", position: .middle, letters: ["a", "e", "i", "o", "u", "y"])
    static var magicEMiddle = LetterSet(name: "Magic E", position: .middle, letters: ["a", "e", "i", "o", "u", "y"])
    static var controlledR = LetterSet(name: "Controlled R", position: .middle, letters: ["ar", "er", "ir", "or", "ur"])
    static var shortVowelExceptions = LetterSet(name: "Short Vowel Exceptions", position: .middle, letters: ["ang", "ank", "ild", "ind", "ing", "ink", "old", "oll", "olt", "ong", "onk", "ost", "ung", "unk"])
    static var vowelTeamBasic = LetterSet(name: "Vowel Team Basic", position: .middle, letters: ["ai", "ay", "ea", "ee", "igh", "oa", "oy"])
    static var vowelTeamIntermediate = LetterSet(name: "Vowel Team Intermediate", position: .middle, letters: ["aw", "eigh", "ew", "ey", "ie", "oe", "oi", "oo", "ou", "ow"])
    static var vowelTeamAdvanced = LetterSet(name: "Vowel Team Advanced", position: .middle, letters: ["aw", "eigh", "ew", "ey", "ie", "oe", "oi", "oo", "ou", "ow"])
    static var vowelA = LetterSet(name: "Vowel A", position: .middle, letters: ["al", "all", "wa"])
    
    static var allSets = [singleConsonants, hBrothers, beginningBlends, shortVowelPointers, endingBlends, magicEEnding, closedSyllable, openSyllable, magicEMiddle, controlledR, shortVowelExceptions, vowelTeamBasic, vowelTeamIntermediate, vowelTeamAdvanced, vowelA]

    static var none = LetterSet(position: .all, letters: [])
}
typealias Letter = String
extension Letter {
    static var vowelList = ["a","e","i","o","u"]
    var isVowel: Bool {
        Letter.vowelList.contains(self.lowercased())
    }
    func standardized() -> String {
        self.lowercased()
    }
}
