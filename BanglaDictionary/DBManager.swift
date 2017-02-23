//
//  DBManager.swift
//  BanglaDictionary
//
//  Created by Ashik Aowal on 12/21/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit
import SwiftyJSON

class DBManager: NSObject {
    static let shared : DBManager = DBManager()
    let pathToDatabase : String!
    let database : FMDatabase!
    
    override init(){
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        pathToDatabase = URL(fileURLWithPath: documentsDirectoryPath).appendingPathComponent("bangla.sqlite").path
//        pathToDatabase = Bundle.main.path(forResource: "bangla", ofType: "sqlite")
        database = FMDatabase(path: pathToDatabase)
    }
    func printPath(){
//        print("So the database path is: \(pathToDatabase!)")
    }
    func fetchSuggestionForPrimaryWord(prefix : String) -> (suggestionList : [String], suggestionIdList : [Int]) {
        var suggestionList = [String]()
        var suggestionIdList = [Int]()
        if(database.open()){
            let query = "SELECT _from, _id FROM primary_word WHERE _from like '\(prefix.lowercased())%' limit 15"
            do{
                let resultSet : FMResultSet = try database.executeQuery(query, values: nil)
                while (resultSet.next()) {
                    suggestionList.append(resultSet.string(forColumn: "_from"))
                    suggestionIdList.append(Int(resultSet.int(forColumn: "_id")))
                }
            }catch{
//                print("Couldn't open database")
            }
        }
        return (suggestionList, suggestionIdList)
    }
    func fetchSuggestionForSecondaryWord(prefix : String) -> (suggestionList : [String], suggestionIdList : [Int]) {
        var suggestionList = [String]()
        var suggestionIdList = [Int]()
        
        if(database.open()){
            let query = "SELECT _from, _id FROM secondary_word WHERE _from like '\(prefix.lowercased())%' limit 10"
            do{
                let resultSet : FMResultSet = try database.executeQuery(query, values: nil)
                while (resultSet.next()) {
                    suggestionList.append(resultSet.string(forColumn: "_from"))
                    suggestionIdList.append(Int(resultSet.int(forColumn: "_id")))
                }
            }catch{
//                print("Couldn't open database")
            }
        }
        return (suggestionList, suggestionIdList)
    }
    
    func fetchFromPrimaryWord(tableName: String, id : Int) ->( allContent: [String : String], singleContent: [String])  {
        var returnDictionary = [String : String]()
        var returnArray = [String]()
        let query = "select * from \(tableName) where _id = \(id)"
        var word : String!
        if(database.open()){
            do{
                let resultSet : FMResultSet = try database.executeQuery(query, values: nil)
                while (resultSet.next()) {
                    
                    word = resultSet.string(forColumn: "_from")
                    returnDictionary[word] = resultSet.string(forColumn: "_to")
                    returnArray.append(word)
                    
                    if(resultSet.string(forColumn: "pronunciation") != nil){
                        let pronunciation = resultSet.string(forColumn: "pronunciation")
                        returnDictionary[word]!.append("\n\(pronunciation!)")
                    }
                    if(resultSet.string(forColumn: "example") != nil){
                        let example = resultSet.string(forColumn: "example")
                        returnDictionary["example"] = example
                        returnArray.append("example")
                    }
                    if(resultSet.string(forColumn: "definition") != nil){
                        if let data = resultSet.string(forColumn: "definition").data(using: String.Encoding.utf8){
                            do{
                                if let stringArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String]{
                                    returnDictionary["definition"] = ""
                                    let str = "❑"
                                    
                                    for index in 0..<stringArray.count{
                                        if(index == stringArray.count-1){
                                            returnDictionary["definition"]?.append("\(str) \(stringArray[index])")
                                        }
                                        else{
                                            returnDictionary["definition"]?.append("\(str) \(stringArray[index])\n\n")
                                        }
                                    }
                                    returnArray.append("definition")
                                }
                                
                            }catch{
//                                print("Error while parsing definition")
                            }
                        }
                    }
                    if(resultSet.string(forColumn: "extra") != nil){
                        if let data = resultSet.string(forColumn: "extra").data(using: String.Encoding.utf8){
                            do{
                                if let intArrayOfArrays = try JSONSerialization.jsonObject(with: data, options: []) as? [[Int]]{
                                    for singleIntArray in intArrayOfArrays {
                                        var wordTypeString : String!
                                        var otherTypeOfWords : String!
                                        for index in 0..<singleIntArray.count{
                                            if(index == 0){
                                                wordTypeString = fetchWordTypeName(typeId: singleIntArray[index])
                                                returnDictionary[wordTypeString] = ""
                                                returnArray.append(wordTypeString)
                                            }
                                            else if(index == singleIntArray.count - 1){
                                                otherTypeOfWords = fetchOtherTypeOfWords(wordId: singleIntArray[index])
                                                returnDictionary[wordTypeString]?.append(otherTypeOfWords!)
                                            }
                                            else{
                                                otherTypeOfWords = fetchOtherTypeOfWords(wordId: singleIntArray[index])
                                                returnDictionary[wordTypeString]?.append("\(otherTypeOfWords!)\n\n")
                                            }
                                        }
                                    }
                                }
                            }catch{
//                                print("Error while parsing extra")
                            }
                        }
                    }
                }
            }catch{
//                print("Didn't find meaning")
            }
        }
        return (returnDictionary, returnArray)
    }
    func fetchWordTypeName(typeId : Int) -> String {
        let query = "select word_type from primary_word_type where _id = \(typeId)"
        var wordTypeString : String = ""
        if(database.open()){
            do{
                let resultSet = try database.executeQuery(query, values: nil)
                while(resultSet.next()) {
                    if(resultSet.string(forColumn: "word_type") != nil){
                        wordTypeString = resultSet.string(forColumn: "word_type")
                    }
                }
            }catch{
//                print("Error while fetching type from primary_word_type")
            }
        }
        return wordTypeString
    }
    func fetchOtherTypeOfWords(wordId : Int) -> String {
        let query = "select too, primary_similar from primary_word_additional where _id = \(wordId)"
        var returnString = ""
        if(database.open()){
            do{
                let resultSet = try database.executeQuery(query, values: nil)
                while(resultSet.next()){
                    if(resultSet.string(forColumn: "too") != nil){
                        returnString = resultSet.string(forColumn: "too")
                    }
                    if(resultSet.string(forColumn: "primary_similar") != nil){
                        let otherWordsInOne = fetchOtherTypeOfWordsNextStep(stringFromQuery: resultSet.string(forColumn: "primary_similar"))
                        returnString.append("\n\(otherWordsInOne)")
                    }
                }
            }catch{
//                print("Error while fetching otherWords")
            }
        }
        return returnString
    }
    func fetchOtherTypeOfWordsNextStep(stringFromQuery : String) -> String {
        var returnString = ""
        
        if let data = stringFromQuery.data(using: String.Encoding.utf8){
            do{
                let intArray = try JSONSerialization.jsonObject(with: data, options: []) as! [Int]
                for index in 0..<intArray.count {
                    if(index == intArray.count - 1){
                        returnString.append(fetchOtherWordsFromPrimaryWords(wordId : intArray[index]))
                    }
                    else{
                        returnString.append("\(fetchOtherWordsFromPrimaryWords(wordId : intArray[index])), ")
                    }
                }
            }catch{
            }
        }
        return returnString
    }
    func fetchOtherWordsFromPrimaryWords(wordId : Int) -> String {
        var returnString = ""
        let query = "select _from from primary_word where _id = \(wordId)"
        
        if(database.open()){
            do {
                let resultSet = try database.executeQuery(query, values: nil)
                while (resultSet.next()) {
                    returnString.append(resultSet.string(forColumn: "_from"))
                }
            } catch {
                
            }
        }
        return returnString
    }
    
    func fetchFromSecondaryWord(tableName : String, id : Int) -> ( allContent: [String : String], singleContent: [String]) {
        var returnDictionary = [String : String]()
        var returnArray = [String]()
        let query = "select * from secondary_word where _id = \(id)"
        var word = ""
        if(database.open()){
            do{
                let resultSet = try database.executeQuery(query, values: nil)
                while (resultSet.next()) {
                    word = resultSet.string(forColumn: "_from")
                    returnDictionary[word] = resultSet.string(forColumn: "_to")
                    returnArray.append(word)
                    
                    if(resultSet.string(forColumn: "pronunciation") != nil){
                        let pronunciation = resultSet.string(forColumn: "pronunciation")
                        returnDictionary[word]!.append("\n\(pronunciation!)")
                    }
                    if(resultSet.string(forColumn: "_to_list") != nil){
                        if let data = resultSet.string(forColumn: "_to_list").data(using: String.Encoding.utf8){
                            do{
                                if let idArrayOfPrimaryWord = try JSONSerialization.jsonObject(with: data, options: []) as? [Int]{
                                    var similarWordsString = ""
                                    
                                    for index in 0..<idArrayOfPrimaryWord.count{
                                        let tempString = fetchEnglishWordFromPrimary(wordId: idArrayOfPrimaryWord[index])

                                        if(index == idArrayOfPrimaryWord.count - 1){
                                            similarWordsString.append(tempString)
                                        }
                                        else{
                                            similarWordsString.append("\(tempString), ")
                                        }
                                    }
                                    returnDictionary["Similar Words"] = similarWordsString
                                    returnArray.append("Similar Words")
                                }
                            }catch{
                            
                            }
                        }
                    }
                }
            }catch{
//                print("Error while fetching from secondary_word")
            }
        }
        return (returnDictionary, returnArray)
    }
    func fetchEnglishWordFromPrimary(wordId : Int) -> String{
        let query = "select _from from primary_word where _id = \(wordId)"
        var returnString = ""
        
        if(database.open()){
            do{
                let resultSet = try database.executeQuery(query, values: nil)
                while(resultSet.next()){
                    returnString = resultSet.string(forColumn: "_from")
                }
            }catch{
//                print("error while fetch only english word from primary_word")
            }
        }
        return returnString
    }
    func fetchFavorite(tableName : String, wordId: Int) -> String {
        let query = "select _from from \(tableName) where _id = \(wordId)"
        var returnString = ""
        if(database.open()){
            do{
                let resultSet = try database.executeQuery(query, values: nil)
                while(resultSet.next()){
                    returnString = resultSet.string(forColumn: "_from")
                }
            }catch{
//                print("Error while fetching favorite")
            }
        }
        
        return returnString
    }
}




























