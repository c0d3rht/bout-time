import Foundation

enum DataError: Error {
    case invalidResource
    case conversionFailure
    case notFound
}

struct PlistConverter {
    static func array(fromFile name: String, ofType type: String) throws -> [Any] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw DataError.invalidResource
        }
        
        guard let array = NSArray.init(contentsOfFile: path) as? [Any] else {
            throw DataError.conversionFailure
        }
        
        return array
    }
    
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String : AnyObject] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw DataError.invalidResource
        }
        
        guard let dictionary = NSDictionary.init(contentsOfFile: path) as? [String : AnyObject] else {
            throw DataError.conversionFailure
        }
        
        return dictionary
    }
    
}

struct EventUnarchiver {
    
    static func events(from dictionary: [String : AnyObject]) throws -> [Event] {
        var events: [Event] = []
        
        for (key, value) in dictionary {
            if let eventData = value as? [String : Any], let date = eventData["date"] as? Date, let url = eventData["url"] as? String {
                let event = Event(description: key, date: date, informationAt: url)
                events.append(event)
            } else {
                throw DataError.conversionFailure
            }
        }
        
        return events
    }
    
}
