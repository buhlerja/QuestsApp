//
//  objectiveArea.swift
//  Quests
//
//  Created by Jack Buhler on 2024-11-24.
//

import Foundation
import CoreLocation

struct ObjectiveArea: Codable {
    var center: CLLocationCoordinate2D?
    var range: CLLocationDistance
        
    init(center: CLLocationCoordinate2D? = nil, range: CLLocationDistance = 1000) {
        self.center = center
        self.range = range
    }
    
    // Encode method for custom encoding of CLLocationCoordinate2D
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode center as a dictionary of latitude and longitude, if present
        if let center = center {
            try container.encode(center.latitude, forKey: .latitude)
            try container.encode(center.longitude, forKey: .longitude)
        }
        
        // Encode range directly since CLLocationDistance is a typealias for Double
        try container.encode(range, forKey: .range)
    }
    
    // Decode method for custom decoding of CLLocationCoordinate2D
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode latitude and longitude into a CLLocationCoordinate2D
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            self.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.center = nil
        }
        
        // Decode range directly
        self.range = try container.decode(Double.self, forKey: .range)
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case range
    }
}
