//
//  Helpers.swift
//  Quizzly
//

import GameKit

enum DataError: Error {
    case invalidResource
    case conversionFailure
    case notFound
}

class PlistConverter {
    static func array(fromFile name: String, ofType type: String) throws -> [Any] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw DataError.invalidResource
        }
        
        guard let array = NSArray.init(contentsOfFile: path) as? [Any] else {
            throw DataError.conversionFailure
        }
        
        return array
    }
    
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String: AnyObject] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw DataError.invalidResource
        }
        
        guard let dictionary = NSDictionary.init(contentsOfFile: path) as? [String: AnyObject] else {
            throw DataError.conversionFailure
        }
        
        return dictionary
    }
}

class Generator {
    static func randomNumber(upperBound: Int) -> Int {
        return GKRandomSource.sharedRandom().nextInt(upperBound: upperBound)
    }
    
    static func shuffledArray(from array: [Any]) -> [Any] {
        return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: array)
    }
}
