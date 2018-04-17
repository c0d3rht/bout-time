import Foundation
import GameKit

extension GKRandomSource {
    static func randomNumber(upperBound: Int) -> Int {
        return GKRandomSource.sharedRandom().nextInt(upperBound: upperBound)
    }
    
    static func shuffledArray(from array: [Any]) -> [Any] {
        return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: array)
    }
}

class Event: Equatable {
    let description: String
    let date: Date
    let url: URL?
    
    init(description: String, date: Date, informationAt pathString: String) {
        self.description = description
        self.date = date
        self.url = URL(string: pathString)
    }
    
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.description == rhs.description
    }
    
}

protocol GameDelegate: class {
    var isPlaying: Bool { get }
    
    func timerDidUpdate()
}

class Game {
    let events: [Event]
    let eventsPerRound = 4
    var eventsGenerated: [Event] = []
    
    var currentOrder: [Event]?
    var correctAnswers = 0
    
    var timer = Timer()
    var secondsLeft: Double
    let secondsPerRound = 60.0
    
    var isFinished: Bool {
        return eventsGenerated.count / eventsPerRound == events.count / eventsPerRound 
    }
    
    weak var delegate: GameDelegate?
    
    init(consistingOf events: [Event]) {
        self.events = events
        secondsLeft = secondsPerRound
    }
    
    func generateEvents() -> [Event] {
        var order: [Event] = []
        var randomIndex: Int
        
        for _ in 1...eventsPerRound {
            repeat {
                randomIndex = GKRandomSource.randomNumber(upperBound: events.count)
            } while eventsGenerated.contains(events[randomIndex])
            
            let event = events[randomIndex]
            
            order.append(event)
            eventsGenerated.append(event)
        }
        
        return order
    }
    
    func event(withDescription description: String) -> Event? {
        for event in events {
            if description == event.description {
                return event
            }
        }
        
        return nil
    }
    
    func evaluate(_ order: [Event]) -> Bool {
        return order == order.sorted(by: { $0.date < $1.date })
    }
    
    func startTimer() {
        secondsLeft = secondsPerRound
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
            if self.secondsLeft > 0 {
                self.secondsLeft -= 1
                self.delegate?.timerDidUpdate()
            } else {
                self.pause()
            }
        }
    }
    
    func play() {
        currentOrder = generateEvents()
        startTimer()
    }
    
    func pause() {
        timer.invalidate()
    }
    
}
