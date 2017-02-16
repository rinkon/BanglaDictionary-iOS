//
//  MeaningViewController.swift
//  BanglaDictionary
//
//  Created by Ashik Aowal on 12/26/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit
import Toast_Swift


class MeaningViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var wordTable : Int!
    var wordId : Int!
    var meaning : String!
    var word : String!
    var contentDictionary : Dictionary<String, String>!
    var contentTypeName : [String]!
    var showDismissButton : Bool!
    
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var meaningTable: UITableView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Constants.countForInterstitial += 1
        var valueToStore = ""
        print("wordTable \(wordTable), wordId\(wordId)")
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
        let favoriteArray = UserDefaults.standard.value(forKey: Constants.FAVORITE_ARRAY_KEY) as! [String]
        if(favoriteArray.contains(valueToStore)){
            favoriteButton.title = "Remove"
        }
        else{
            favoriteButton.title = "Save"
        }
        var historyArray = UserDefaults.standard.value(forKey: Constants.HISTORY_ARRAY_KEY) as! [String]
        
        if(!historyArray.contains(valueToStore)){
            historyArray.append(valueToStore)
            if(historyArray.count>20){
                historyArray.removeFirst()
            }
            UserDefaults.standard.set(historyArray, forKey: Constants.HISTORY_ARRAY_KEY)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 61.0/255.0, blue: 76.0/255.0, alpha: 1.0)
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
//        view.tintColor = UIColor(red: 68.0/255.0, green: 80.0/255.0, blue: 93.0/255.0, alpha: 1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.isOpaque = true
        header.backgroundView?.backgroundColor = UIColor(red: 48.0/255.0, green: 61.0/255.0, blue: 76.0/255.0, alpha: 1.0)
//        header.backgroundView?.backgroundColor = UIColor(red: 27.0/255.0, green: 41.0/255.0, blue: 58.0/255.0, alpha: 1.0)
//        header.layer.opacity = 1.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = contentDictionary[contentTypeName[indexPath.section]]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor(red: 13.0/255.0, green: 81.0/255.0, blue: 89.0/255.0, alpha: 1.0)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIPasteboard.general.string = contentDictionary[contentTypeName[indexPath.section]]
        self.view.makeToast("Copied to Clip-board", duration: 0.8, position: .bottom)
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
            self.view.makeToast("Removed from favorites", duration: 0.8, position: .bottom)
        }
        else{
            favoriteButton.title = "Remove"
            favoriteArray.append(valueToStore!)
            self.view.makeToast("Saved to favorites", duration: 0.8, position: .bottom)
        }
        UserDefaults.standard.set(favoriteArray, forKey: Constants.FAVORITE_ARRAY_KEY)
    }
}
