//
//  FlashCardsViewController.swift
//  BanglaDictionary
//
//  Created by Ashik Aowal on 1/15/17.
//  Copyright © 2017 MacMan. All rights reserved.
//

import UIKit

class FlashCardsViewController: BaseViewController, iCarouselDelegate, iCarouselDataSource {

    
    
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var numbers = [Int]()
    var favoriteWordListArray = [String]()
    var favoriteWordTableList = [Int]()
    var favoriteWordIdList = [Int]()
    var toMeaning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carouselView.type = .coverFlow
        carouselView.isVertical = false
        carouselView.isPagingEnabled = true
        
    }
    override func awakeFromNib() {
        numbers = [2, 4, 5, 4, 3, 0, 1, 9]
        var favoriteArray = UserDefaults.standard.value(forKey: Constants.FAVORITE_ARRAY_KEY) as! [String]
        
        favoriteWordListArray.removeAll()
        favoriteWordTableList.removeAll()
        favoriteWordIdList.removeAll()
        
        for index in 0..<favoriteArray.count {
            var word = ""
            var characterArray = Array(favoriteArray[index].characters)
            if(characterArray[0] == "p"){
                favoriteArray[index].remove(at: favoriteArray[index].startIndex)
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
        
    }
    override func viewWillAppear(_ animated: Bool) {
        carouselView.isHidden = false
        backgroundImageView.isHidden = false
        toMeaning = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 29.0/255.0, green: 101.0/255.0, blue: 111.0/255.0, alpha: 0.0)
    }
    func numberOfItems(in carousel: iCarousel) -> Int {
        return favoriteWordListArray.count
    }
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let carouselViewItem = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        carouselViewItem.backgroundColor = UIColor.black
        carouselViewItem.alpha = 0.5
        let wordLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        wordLabel.text = favoriteWordListArray[index].capitalized
        wordLabel.textAlignment = .center
        wordLabel.textColor = UIColor.white
        wordLabel.layer.shadowColor = UIColor.white.cgColor
        wordLabel.layer.shadowRadius = 3.0
        wordLabel.layer.shadowOpacity = 0.8
        wordLabel.layer.shadowOffset = CGSize.zero
        wordLabel.layer.masksToBounds = false
        wordLabel.font = UIFont.systemFont(ofSize: 30)
        wordLabel.numberOfLines = 0
        wordLabel.backgroundColor = UIColor.clear
        
        let meaningButton = UIButton(frame: CGRect(x: 300-80, y: 200-30, width: 80, height: 30))
        meaningButton.setTitle("Meaning", for: .normal)
        meaningButton.tag = index
        meaningButton.addTarget(self, action: #selector(self.meaningButtonTapped(sender:)), for: .touchUpInside)
        carouselViewItem.addSubview(meaningButton)
        carouselViewItem.addSubview(wordLabel)
        
        carouselViewItem.layer.cornerRadius = 4
        
        return carouselViewItem
    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if(option == iCarouselOption.spacing){
            return value * 1.6
        }
        return value
    }
    override func viewWillDisappear(_ animated: Bool) {
        if(toMeaning == false){
            carouselView.isHidden = true
            backgroundImageView.isHidden = true
            navigationController?.setNavigationBarHidden(true, animated: true)
            navigationController?.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 61.0/255.0, blue: 76.0/255.0, alpha: 0.0)
        }
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func meaningButtonTapped(sender: UIButton) {
        print(sender.tag)
        var envelope = [Any]()
        envelope = [favoriteWordTableList[sender.tag], favoriteWordIdList[sender.tag]]
        toMeaning = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ToMeaningViewControllerFromFlashCards", sender: envelope)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ToMeaningViewControllerFromFlashCards"){
            let vc = segue.destination as! MeaningViewController
            let envelope = sender as! [Any]
            vc.wordTable = envelope[0] as! Int
            vc.wordId = envelope[1] as! Int
            vc.showDismissButton = true
        }
    }
}
