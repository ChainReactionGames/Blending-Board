//
//  Letter Pack.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/6/20.
//

import Foundation

struct LetterPack: Equatable {
    var name: String?
    var beginning: LetterSet
    var middle: LetterSet
    var end: LetterSet
}
extension LetterPack {
    init(name: String?, _ sets: [LetterSet]) {
        let standardizedArray = sets + Array(repeating: LetterSet.none, count: 3 - sets.count)
        self = LetterPack(name: name, beginning: standardizedArray[0], middle: standardizedArray[1], end: standardizedArray[2])
    }
    
    // MARK: - Default Values
    
    static var standardClosed = LetterPack(name: "Standard (Closed Syllable)", [.singleConsonantsBeginning, .closedSyllable, .singleConsonantsEnding])
    static var standardOpen = LetterPack(name: "Standard (Open Syllable)", [.singleConsonantsBeginning, .openSyllable, .singleConsonantsEnding])
    
    static var allPacks = [standardClosed, standardOpen]
}
