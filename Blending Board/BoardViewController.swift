//
//  ViewController.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/6/20.
//

import UIKit

class BoardViewController: UIViewController {

    @IBOutlet var stacks: [CardStack]!
    var pack = LetterPack.standardOpen
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        stacks[0].setup(pack.beginning)
        stacks[1].setup(pack.middle)
        stacks[2].setup(pack.end)
    }
    @IBAction func changeTint(_ sender: UIButton) {
        view.tintColor = sender.tintColor
    }
    
}

