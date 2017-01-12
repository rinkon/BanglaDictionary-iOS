//
//  ContainerViewController.swift
//  BanglaDictionary
//
//  Created by MacBook Pro on 12/5/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit
import TabPageViewController

class ContainerViewController: UIViewController {
    let tabPageViewController = TabPageViewController.create()
    
    @IBOutlet weak var tabPageContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBarButton()
        self.foldMenuController().rightMenuEnabled = false
        self.foldMenuController().foldEffeectEnabled = false
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        let vc2 = storyBoard.instantiateViewController(withIdentifier: "Favorite") as! FavoriteViewController
        let vc3 = storyBoard.instantiateViewController(withIdentifier: "History") as! HistoryViewController
        let vc4 = storyBoard.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        vc1.containerViewController = self
        vc2.containerViewController = self
        vc3.containerViewController = self
        tabPageViewController.tabItems = [(vc1, "Home"), (vc2, "Favorites"), (vc3, "History"), (vc4, "Settings")]
        tabPageViewController.view.frame = self.tabPageContainerView.frame
        tabPageViewController.option.tabBackgroundColor = UIColor(red: 165.0/255.0, green: 165.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        tabPageViewController.option.currentColor = UIColor.white
        tabPageViewController.option.defaultColor = UIColor.white
        tabPageViewController.option.tabHeight = 32
        self.tabPageContainerView.addSubview(tabPageViewController.view)
        let emptyImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = emptyImage
        self.navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .default)
        
    }
    func addBarButton(){
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "menu_image.png"), for: UIControlState())
        button.addTarget(self, action: #selector(self.leftMenuTapped(_:)), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    func leftMenuTapped(_ sender: AnyObject) {
        self.foldMenuController().leftMenuAction()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ToMeaningViewController"){
            let vc = segue.destination as! MeaningViewController
            let envelope = sender as! [Any]
            vc.wordTable = envelope[0] as! Int
            vc.wordId = envelope[1] as! Int
        }
    }
}
