//
//  ScoreController.swift
//  BoutTime
//
import UIKit

class ScoreController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var correctAnswers = 0
    var totalRounds = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "\(correctAnswers)/\(totalRounds)"
    }
    
    @IBAction func playAgain() {
        let gameController = storyboard?.instantiateViewController(withIdentifier: "Game") as! GameController
        present(gameController, animated: true)
    }
}
