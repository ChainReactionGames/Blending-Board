//
//  ViewController.swift
//  Blending Board
//
//  Created by Brayden Gogis on 7/6/20.
//

import UIKit

class BoardViewController: UIViewController {

    @IBOutlet var stacks: [CardStack]!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for stack in stacks {
            stack.setup()
        }
    }

}

