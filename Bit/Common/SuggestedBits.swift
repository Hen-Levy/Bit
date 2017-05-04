//
//  SuggestedBits.swift
//  Bit
//
//  Created by Hen Levy on 27/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseStorage

class SuggestedBits {
    
    class func `for`(userUID: String, friendUID: String, completion: @escaping ([String]) -> ()) {
        
//        let filePath = "conversations/SampleConversation.json"
        
        let jsonName = userUID + " " + friendUID
        let filePath = "conversations/\(jsonName).json"
        
        // get conversation between user & friend
        FIRStorage.storage().reference().child(filePath).data(withMaxSize: 10*1024*1024) { (data, error) in
            
            // parse json
            if let strongData = data {
                
                do {
                    let jsonDic = try JSONSerialization.jsonObject(with: strongData, options: []) as? Dictionary<String, Any>
                    
                    // to dictionary
                    guard let strongJsonDic = jsonDic,
//                    let titles = strongJsonDic[userUID] as? [String] else {
                    let titles = strongJsonDic["A"] as? [String] else {
                        return
                    }
                    debugPrint("conversation: \(strongJsonDic)")
                    
                    // calculate LSA and TFIDF to get the terms and it weights
                    let lsa_tfidf_calculator = LSA_TFIDF(titles: titles)
                    let finalTerms = lsa_tfidf_calculator.calculate()
                    
                    // sort terms by weights (most suggested terms is on top)
                    let suggestedTerms = finalTerms.sorted {$0.weight > $1.weight}
                    var suggestedBitsTexts = [String]()
                    for suggestedTerm in suggestedTerms {
                        suggestedBitsTexts.append(suggestedTerm.term)
                    }
                    
                    completion(suggestedBitsTexts)
                }
                catch {
                    debugPrint("failed parsing json")
                }

            }
        }
    }
}

extension String {
    func removingCharacters(inCharacterSet forbiddenCharacters:CharacterSet) -> String
    {
        var filteredString = self
        while true {
            if let forbiddenCharRange = filteredString.rangeOfCharacter(from: forbiddenCharacters)  {
                filteredString.removeSubrange(forbiddenCharRange)
            }
            else {
                break
            }
        }
        
        return filteredString
    }
}

extension Array where Element:Hashable {
    var unique: [Element] {
        var set = Set<Element>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(value) {
                set.insert(value)
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
}
