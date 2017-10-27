//
//  GameController.swift
//  BoutTime
//

import UIKit

class GameController: UIViewController {
    
    @IBOutlet weak var eventsView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    let game: Game
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let dictionary = try PlistConverter.dictionary(fromFile: "Events", ofType: "plist")
            let events = try EventUnarchiver.events(from: dictionary)
            game = Game(consistingOf: events)
        } catch let error {
            fatalError("\(error)")
        }
            
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        game.externalAction = updateTimer
        
        displayNewRound()
    }
    
    func displayNewRound() {
        timerLabel.text = "1:00"
        game.play()
        
        toggleGameState(true)
        let factViews = eventsView.subviews
        
        for i in 0..<factViews.count {
            if let currentOrderOfEvents = game.currentOrderOfEvents, let factButton = factViews[i].subviews.first as? UIButton {
                factButton.setTitle(currentOrderOfEvents[i].description, for: .normal)
            }
        }
    }
    
    @IBAction func moveFactUp(_ sender: UIButton?) {
        if let index = eventsView.subviews.index(of: sender!.superview!) {
            let factButton = sender?.superview?.subviews.first as! UIButton
            let factText = factButton.currentTitle
            let aboveButton = eventsView.subviews[index - 1].subviews.first as! UIButton
            
            factButton.setTitle(aboveButton.currentTitle, for: .normal)
            aboveButton.setTitle(factText, for: .normal)
        }
    }
    
    @IBAction func moveFactDown(_ sender: UIButton?) {
        if let index = eventsView.subviews.index(of: sender!.superview!) {
            let factButton = sender?.superview?.subviews.first as! UIButton
            let factText = factButton.currentTitle
            let belowButton = eventsView.subviews[index + 1].subviews.first as! UIButton
            
            factButton.setTitle(belowButton.currentTitle, for: .normal)
            belowButton.setTitle(factText, for: .normal)
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if let event = event {
            if event.subtype == UIEventSubtype.motionShake && game.secondsLeft > 0 {
                showResult()
            }
        }
    }
    
    func getOrderOfEvents() -> [Event] {
        var events: [Event] = []
        
        for factView in eventsView.subviews {
            if let factButton = factView.subviews.first as? UIButton, let event = game.getEvent(withDescription: factButton.currentTitle!) {
                events.append(event)
            }
        }
        
        return events
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let infoController = segue.destination as? InfoController {
            let event = game.getEvent(withDescription: (sender as! UIButton).currentTitle!)
            infoController.url = event?.url
        }
    }
    
    func showResult() {
        toggleGameState(false)
        game.pause()
        
        if game.checkOrder(of: getOrderOfEvents()) {
            game.correctAnswers += 1
            continueButton.setImage(#imageLiteral(resourceName: "next_round_success"), for: .normal)
        } else {
            continueButton.setImage(#imageLiteral(resourceName: "next_round_fail"), for: .normal)
        }
    }
    
    func toggleGameState(_ state: Bool) {
        for factView in eventsView.subviews {
            for button in factView.subviews as! [UIButton] {
                if button.currentTitle != nil {
                    button.isUserInteractionEnabled = !state
                } else {
                    button.isUserInteractionEnabled = state
                }
            }
        }
        
        continueButton.isHidden = state
        continueButton.isUserInteractionEnabled = !state
        timerLabel.isHidden = !state
        
        captionLabel.text = state ? "Shake to complete" : "Tap events to learn more"
    }
    
    func updateTimer() {
        let minutes = Int(game.secondsLeft) / 60
        let seconds = Int(game.secondsLeft) % 60
        
        timerLabel.text = String(format: "%i:%02i", minutes, seconds)
        if game.secondsLeft == 0 { showResult() }
    }
    
    @IBAction func nextRound() {
        if !game.isFinished {
            displayNewRound()
        } else {
            let scoreController = storyboard?.instantiateViewController(withIdentifier: "Score") as! ScoreController
            
            scoreController.correctAnswers = game.correctAnswers
            scoreController.totalRounds = game.eventsShown.count / game.eventsPerRound
            
            present(scoreController, animated: true)
        }
    }
}
