//
//  LSA+TFIDF.swift
//  Bit
//
//  Created by Hen Levy on 27/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import Foundation

class LSA_TFIDF {
    let stopTerms = [" the "," so "," to "," well "," but "," at "," too "]
    let ignoreChars = CharacterSet(charactersIn: "!?.,")
    
    private var titles = [String]()
    private var termsInDocument = [String]()
    private var countMatrix = [[Int]]()
    private var finalTerms = [FinalTerm]()
    
    init(titles: [String]) {
        self.titles = titles
    }
    
    func calculate() -> [FinalTerm] {
        calculateLSA()
        calculateTFIDF()
        return finalTerms
    }
    
    //
    // MARK: LSA
    //
    
    private func calculateLSA() {
        
        for title in titles {
            var newTitle = title.removingCharacters(inCharacterSet: ignoreChars).lowercased()
            
            for stopTerm in stopTerms {
                if newTitle.hasPrefix(stopTerm + " ") {
                    newTitle = newTitle.replacingOccurrences(of: stopTerm, with: " " + stopTerm)
                } else if newTitle.hasSuffix(" " + stopTerm) {
                    newTitle = newTitle.replacingOccurrences(of: stopTerm, with: stopTerm + " ")
                }
                if newTitle.contains(stopTerm) {
                    newTitle = newTitle.replacingOccurrences(of: stopTerm, with: " $remove$ ")
                }
            }
            var termsInNewTitle = newTitle.components(separatedBy: "$remove$ ")
            for (index, term) in termsInNewTitle.enumerated() {
                if term.trimmingCharacters(in: .whitespaces).isEmpty {
                    termsInNewTitle.remove(at: index)
                }
            }
            
            termsInDocument += termsInNewTitle
        }
        
        for (index, term) in termsInDocument.enumerated() {
            if term.hasSuffix(" ") {
                termsInDocument[index] = String(term.characters.dropLast())
            }
        }
        
        for term in termsInDocument {
            print(term)
        }
        print("\n")
        
        // create the count matrix
        
        termsInDocument = termsInDocument.unique
        
        for (termIndex, term) in termsInDocument.enumerated() {
            countMatrix.append([Int]())
            
            for (_, title) in titles.enumerated() {
                let newTitle = title.removingCharacters(inCharacterSet: ignoreChars).lowercased()
                let componentsCount = newTitle.components(separatedBy: term).count
                let occurrencesCount = (componentsCount > 1 ? componentsCount-1 : 0)
                
                countMatrix[termIndex].append(occurrencesCount)
            }
        }
        
        for row in countMatrix {
            print(row)
        }
        print("\n")
    }
    
    //
    // MARK: TF-IDF
    //
    
    // TFIDFi,j = ( Ni,j / N*,j ) * log( D / Di )
    
    private func calculateTFIDF() {
        
        // weights of terms in titles
        for (termIndex, term) in termsInDocument.enumerated() {
            var sum: Double = 0
            for (titleIndex, _) in titles.enumerated() {
                let tfIdf_result = tfIdf(tf: tf(termIndex, titleIndex),
                                         idf: idf(termIndex))
                sum += tfIdf_result
            }
            finalTerms.append(FinalTerm(term: term, weight: sum))
        }
        
        for finalTerm in finalTerms {
            print("\(finalTerm.weight) \(finalTerm.term)")
        }
    }
    
    private func tf(_ termIndex: Int, _ titleIndex: Int) -> Double {
        // the number of times term i appears in title j
        let Nij = Double(countMatrix[termIndex][titleIndex])
        
        // the number of total terms in title j
        var Nj: Double = 0
        for row in countMatrix {
            Nj += Double(row[titleIndex])
        }
        
        return Nij / Nj
    }
    
    
    private func idf(_ termIndex: Int) -> Double {
        // the number of titles
        let D = Double(titles.count)
        
        // the number of titles in which term i appears
        var Di: Double = 0
        
        let row = countMatrix[termIndex]
        for cell in row {
            if cell > 0 {
                Di+=1
            }
        }
        
        return log(D / Di)
    }
    
    private func tfIdf(tf: Double, idf: Double) -> Double {
        return tf * idf
    }
}

class FinalTerm {
    var term: String = ""
    var weight: Double = 0
    init(term: String, weight: Double) {
        self.term = term
        self.weight = weight
    }
}
