import UIKit

enum Direction {
    case upwards, downwards
}

class GameController: UIViewController, GameDelegate {
    
    @IBOutlet weak var eventStackView: UIStackView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    let game: Game
    var currentArrangement: [Event] {
        var events: [Event] = []
        
        for eventView in eventStackView.subviews {
            let eventButton = eventView.subviews.first as! UIButton
            
            if let event = game.event(withDescription: eventButton.currentTitle!) {
                events.append(event)
            }
        }
        
        return events
    }
    
    var isPlaying: Bool { return game.timer.isValid }
    let soundEffectsPlayer = SoundEffectsPlayer()
    
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
        
        game.delegate = self
        startRound()
    }
    
    @IBAction func moveEventAbove(_ sender: UIButton) {
        let eventView = sender.superview!
        moveEvent(from: eventView, .upwards)
    }
    
    @IBAction func moveEventBelow(_ sender: UIButton) {
        let eventView = sender.superview!
        moveEvent(from: eventView, .downwards)
    }
    
    @IBAction func advance() {
        if game.isFinished {
            displayScore()
        } else {
            startRound()
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if let event = event, event.subtype == UIEvent.EventSubtype.motionShake {
            if isPlaying && game.secondsLeft > 0 {
                assessAnswer()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let infoController = segue.destination as? InfoController  {
            let event = game.event(withDescription: (sender as! UIButton).currentTitle!)
            infoController.eventURL = event?.url
        }
    }
    
    func startRound() {
        game.play()
        toggleState()
        
        timerLabel.text = "1:00"
        
        for i in 0..<eventStackView.subviews.count {
            let eventDescription = game.currentOrder![i].description
            let eventView = eventStackView.subviews[i]
            let eventInfoButton = eventView.subviews.first! as! UIButton
            
            eventInfoButton.setTitle(eventDescription, for: .normal)
        }
    }
    
    func moveEvent(from view: UIView, _ direction: Direction) {
        if let index = eventStackView.subviews.index(of: view) {
            let eventButton = view.subviews.first as! UIButton
            let eventDescription = eventButton.currentTitle
            
            let recipientIndex = direction == .upwards ? index - 1 : index + 1
            let recipientView = eventStackView.subviews[recipientIndex]
            let recipientButton = recipientView.subviews.first! as! UIButton
            
            eventButton.setTitle(recipientButton.currentTitle, for: .normal)
            recipientButton.setTitle(eventDescription, for: .normal)
        }
    }
    
    func assessAnswer() {
        game.pause()
        toggleState()
        
        let status = game.evaluate(currentArrangement)
        soundEffectsPlayer.playSound(status: status)
        
        if status {
            game.correctAnswers += 1
            continueButton.setImage(#imageLiteral(resourceName: "next_round_success"), for: .normal)
        } else {
            continueButton.setImage(#imageLiteral(resourceName: "next_round_fail"), for: .normal)
        }
    }
    
    func displayScore() {
        let scoreController = storyboard?.instantiateViewController(withIdentifier: "Score") as! ScoreController
        
        scoreController.correctAnswers = game.correctAnswers
        scoreController.totalRounds = game.eventsGenerated.count / game.eventsPerRound
        
        present(scoreController, animated: true)
    }
    
    func toggleState() {
        for eventView in eventStackView.subviews {
            for button in eventView.subviews as! [UIButton] {
                switch button.currentTitle {
                case nil:
                    button.isUserInteractionEnabled = isPlaying
                default:
                    button.isUserInteractionEnabled = !isPlaying
                }
            }
        }
        
        continueButton.isHidden = isPlaying
        continueButton.isUserInteractionEnabled = !isPlaying
        timerLabel.isHidden = !isPlaying
        
        captionLabel.text = isPlaying ? "Shake to complete" : "Tap events to learn more"
    }
    
    func timerDidUpdate() {
        let minutes = Int(game.secondsLeft) / 60
        let seconds = Int(game.secondsLeft) % 60
        
        timerLabel.text = String(format: "%i:%02i", minutes, seconds)
        if game.secondsLeft == 0 { assessAnswer() }
    }
    
}
