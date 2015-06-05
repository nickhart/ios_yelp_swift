//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation

class Business: NSObject {
    let name: String?
    let address: String?
    let imageURL: NSURL?
    let categories: String?
    let distance: String?
    let ratingImageURL: NSURL?
    let reviewCount: NSNumber?
    let rating: NSNumber?
    let displayPhone: NSString?
    let crossStreets: NSString?
    let neighborhood: NSString?
    let walkTime: String?
    
    var coordinate: CLLocationCoordinate2D? // @todo: make this a "let" but fix init...
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = NSURL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            var street: String? = ""
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            var neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                neighborhood = neighborhoods![0] as? NSString
                address += neighborhoods![0] as! String
            }
            else {
                neighborhood = nil
            }
            crossStreets = location!["cross_streets"] as? NSString
        }
        else {
            // TODO: clean this up
            crossStreets = nil
            neighborhood = nil
        }
        self.address = address
        
        if let coordinate = dictionary.valueForKeyPath("location.coordinate") as? NSDictionary {
            if let latitude = coordinate["latitude"] as? NSNumber {
                if let longitude = coordinate["longitude"] as? NSNumber {
                    self.coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
                }
            }
        }
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                var categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = ", ".join(categoryNames)
        } else {
            categories = nil
        }
        
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
            let kmh = 5.0
            let kmm = kmh / 60.0
            let metersPerMinute = kmm * 1000.0
            let totalMinutes = Int(ceil(distanceMeters!.doubleValue / metersPerMinute))
            let hours = totalMinutes / 60
            if hours > 0 {
                let remainderMinutes = totalMinutes % 60
                walkTime = String(format: "%d hours, %d minutes", hours, remainderMinutes)
            }
            else {
                walkTime = String(format: "%d minutes", totalMinutes)
            }
        } else {
            distance = nil
            walkTime = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        displayPhone = dictionary["display_phone"] as? NSString
        rating = dictionary["rating"] as? NSNumber
        reviewCount = dictionary["review_count"] as? NSNumber
    }
    
    class func businesses(#array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            var business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(term: String, completion: ([Business]!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, completion: completion)
    }
    
    class func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> Void {
        YelpClient.sharedInstance.searchWithTerm(term, sort: sort, categories: categories, deals: deals, completion: completion)
    }
}
