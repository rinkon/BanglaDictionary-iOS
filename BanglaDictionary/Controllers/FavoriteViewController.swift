//
//  FavoriteViewController.swift
//  BanglaDictionary
//
//  Created by MacBook Pro on 12/5/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var favoriteWordListArray = [String]()
    var favoriteWordTableList = [Int]()
    var favoriteWordIdList = [Int]()
    var containerViewController : ContainerViewController!
    
    @IBOutlet weak var favoriteTableView: UITableView!
    
    override func viewDidLoad() {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        var favoriteArray = UserDefaults.standard.value(forKey: Constants.FAVORITE_ARRAY_KEY) as! [String]
        
        favoriteWordListArray.removeAll()
        favoriteWordTableList.removeAll()
        favoriteWordIdList.removeAll()
        
        for index in 0..<favoriteArray.count {
            var word = ""
            var characterArray = Array(favoriteArray[index].characters)
            if(characterArray[0] == "p"){
                favoriteArray[index].remove(at: favoriteArray[index].startIndex)
                print("bong bong\((favoriteArray[index] as NSString).integerValue)")
                word = DBManager.shared.fetchFavorite(tableName: "primary_word", wordId: (favoriteArray[index] as NSString).integerValue)
                favoriteWordTableList.append(0)
                favoriteWordIdList.append((favoriteArray[index] as NSString).integerValue)
            }
            else if(characterArray[0] == "s"){
                favoriteArray[index].remove(at: favoriteArray[index].startIndex)
                word = DBManager.shared.fetchFavorite(tableName: "secondary_word", wordId: Int(favoriteArray[index])!)
                favoriteWordTableList.append(1)
                favoriteWordIdList.append(Int(favoriteArray[index])!)
            }
            favoriteWordListArray.append(word)
        }
        print(favoriteWordListArray)
        favoriteTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteWordListArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCellReuseId", for: indexPath)
        cell.textLabel?.text = favoriteWordListArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var envelope = [Any]()
        envelope = [favoriteWordTableList[indexPath.row], favoriteWordIdList[indexPath.row]]
        DispatchQueue.main.async {
            self.containerViewController.performSegue(withIdentifier: "ToMeaningViewController", sender: envelope)
        }
    }
}
