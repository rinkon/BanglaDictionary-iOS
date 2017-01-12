//
//  MeaningViewController.swift
//  BanglaDictionary
//
//  Created by Ashik Aowal on 12/26/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit

class MeaningViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var wordTable : Int!
    var wordId : Int!
    var meaning : String!
    var word : String!
    var contentDictionary : Dictionary<String, String>!
    var contentTypeName : [String]!
    
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var meaningTable: UITableView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var valueToStore = ""
        if(wordTable == 0){
            let content = DBManager.shared.fetchFromPrimaryWord(tableName: "primary_word", id: wordId)
            contentDictionary = content.allContent
            contentTypeName = content.singleContent
            valueToStore = "p\(wordId!)"
        }
        else if(wordTable == 1){
            let content = DBManager.shared.fetchFromSecondaryWord(tableName: "secondary_word", id: wordId)
            contentDictionary = content.allContent
            contentTypeName = content.singleContent
            valueToStore = "s\(wordId!)"
        }
        var favoriteArray = UserDefaults.standard.value(forKey: Constants.FAVORITE_ARRAY_KEY) as! [String]
        if(favoriteArray.contains(valueToStore)){
            favoriteButton.title = "Remove"
        }
        else{
            favoriteButton.title = "Save"
        }
        var historyArray = UserDefaults.standard.value(forKey: Constants.HISTORY_ARRAY_KEY) as! [String]
        
        if(!historyArray.contains(valueToStore)){
            historyArray.append(valueToStore)
            UserDefaults.standard.set(historyArray, forKey: Constants.HISTORY_ARRAY_KEY)
        }
    }
    //MARK: TableViewDelegate Methods
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contentTypeName[section].capitalized
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return contentTypeName.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.init(red: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.layer.opacity = 1.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = contentDictionary[contentTypeName[indexPath.section]]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Actions
    @IBAction func favoritePressed(_ sender: Any) {
        var valueToStore : String!
        if(wordTable == 0){
            valueToStore = "p\(wordId!)"
        }
        else{
            valueToStore = "s\(wordId!)"
        }
        
        var favoriteArray = UserDefaults.standard.value(forKey: Constants.FAVORITE_ARRAY_KEY) as! [String]
        if(favoriteArray.contains(valueToStore)){
            favoriteButton.title = "Save"
            favoriteArray.remove(at: favoriteArray.index(of: valueToStore!)!)
        }
        else{
            favoriteButton.title = "Remove"
            favoriteArray.append(valueToStore!)
        }
        UserDefaults.standard.set(favoriteArray, forKey: Constants.FAVORITE_ARRAY_KEY)
        print(favoriteArray)
    }
}