//
//  EventGame.swift
//  BoutTime
//

import Foundation

class EventUnarchiver {
    static func events(from dictionary: [String: AnyObject]) throws -> [Event] {
        var events: [Event] = []
        
        for (key, value) in dictionary {
            if let eventData = value as? [String: Any], let date = eventData["date"] as? Date, let url = eventData["url"] as? String {
                let event = Event(description: key, date: date, informationAt: url)
                events.append(event)
            } else {
                throw DataError.conversionFailure
            }
        }
        
        return events
    }
}

class Event: Equatable {
    let description: String
    let date: Date
    let url: URL
    
    init(description: String, date: Date, informationAt url: String) {
        self.description = description
        self.date = date
        self.url = URL(string: url)!
    }
    
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.url == rhs.url
    }
}

class Game {
    let events: [Event]
    var currentOrderOfEvents: [Event]?
    var correctAnswers = 0
    let eventsPerRound = 4
    var eventsShown: [Event] = []
    
    var timer = Timer()
    var isFinished: Bool { return events.count / eventsPerRound == eventsShown.count / eventsPerRound }
    var secondsLeft: Double
    let secondsPerRound: Double = 60.0
    
    var externalAction: (() -> Void)?
    
    init(consistingOf events: [Event]) {
        self.events = events
        secondsLeft = secondsPerRound
    }
    
    func play() {
        currentOrderOfEvents = generateEvents()
        startTimer()
    }
    
    func pause() {
        timer.invalidate()
    }
    
    func generateEvents() -> [Event] {
        var order: [Event] = []
        var randomIndex: Int
        
        for _ in 1...eventsPerRound {
            repeat {
                randomIndex = Generator.randomNumber(upperBound: events.count)
            } while eventsShown.contains(events[randomIndex])
            
            let event = events[randomIndex]
            order.append(event)
            eventsShown.append(event)
        }
        
        return order
    }
    
    func checkOrder(of events: [Event]) -> Bool {
        return events == events.sorted(by: { $0.date < $1.date })
    }
    
    func startTimer() {
        secondsLeft = secondsPerRound
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {_ in
            if self.secondsLeft > 0 {
                self.secondsLeft -= 1
                if let action = self.externalAction { action() }
            } else {
                self.pause()
            }
        })
    }
    
    func getEvent(withDescription description: String) -> Event? {
        for event in events {
            if description == event.description {
                return event
            }
        }
        
        return nil
    }
}
