//
//  MasterViewController.swift
//  Spotlight
//
//  Created by mac on 27.03.18.
//  Copyright © 2018 Dim Malysh. All rights reserved.
//

import UIKit
import SafariServices
import CoreSpotlight
import MobileCoreServices

class MasterViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    let video: [[String]] = [
        ["1. Работа с сервисом OpenWeatherMap", "Краткое описание сервиса OpenWeatherMap. Работа с NSURLSession. Создание модели данных."],
        ["2. Работа с сервисом OpenWeatherMap", "Улучшение модели."],
        ["3. Frameworks Работа с UIAlertController", "Подключаем сторонние Frameworks. Работаем с UIAlertController"],
        ["4. Работа с Alamofire и SwiftyJson", "Создаем делегат. Работаем с Alamofire и SwiftyJson. "],
        ["5. Улучшение модели данных", "В этом продолжении, мы улучшаем метод по выбору иконок в зависимости от времени суток - ночь/день."],
        ["6. Улучшаем обработчик ошибок. MBProgressHUD", "В этом видеоуроке займемся улучшением обработчика ошибок. Поговорим о MBProgressHUD."],
        ["7. Работа с Core Location", "Здесь познакомимся с вами с Core Location"],
        ["8. Создание интерфейса", "С этого урока начнем создать красивый интерфейс"],
        ["9. Работа с AutoLayout. Создание интерфейса", "В этом видеоуроке поговорим о Autolayout и продолжим создавать интерфейс"],
        ["10. Улучшение интерфейса. Финал", "Здесь мы закончим наше приложение"]
    ]
    
    let urlVideo = [
        "gOLGXaVPBC0",
        "Ao5LM9DLJQU",
        "nCbVkGw7V_k",
        "3pfqjgWidYU",
        "iE3vv6i-ON4",
        "VBGeNw6e0oE",
        "rurlea-2JAk",
        "wxXJA8Q6q-Q",
        "J9kukAwjwDc",
        "rJ0LiGoSmEo"
    ]
    
    var favorites = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let userDefaults = UserDefaults.standard
        if let savedFavorites = userDefaults.object(forKey: "favorites") as? [Int] {
            favorites = savedFavorites
            print(favorites)
        }
        
        //Self sizing cell
        self.tableView.estimatedRowHeight = 80.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0.0
        
        UIView.animate(withDuration: 1.0) { 
            cell.alpha = 1.0
        }
        
        let angle = 90.0 * CGFloat(M_PI / 100.0)
        let rotationTransform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
        cell.layer.transform = rotationTransform
        
        UIView.animate(withDuration: 1.0) { 
            cell.layer.transform = CATransform3DIdentity
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return video.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let videos = video[indexPath.row]
        cell.textLabel?.attributedText = makeAttributedString(title: videos[0], subtitle: videos[1])
        
        cell.accessoryType = favorites.contains(indexPath.row) ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showVideo(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let userDefaults = UserDefaults.standard
        
        let searchAction = UITableViewRowAction(style: .default, title: "Search") { (action, indexPath) in
            let searchMenu = UIAlertController(title: nil, message: "Search using", preferredStyle: .actionSheet)
            
            let addIndexItem = UIAlertAction(title: "Add index item", style: .default, handler: { (action) in
                self.favorites.append(indexPath.row)
                userDefaults.set(self.favorites, forKey: "favorites")
                tableView.reloadRows(at: [indexPath], with: .none)
                
                let videos = self.video[indexPath.row]
                let attributedSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributedSet.title = videos[0]
                attributedSet.contentDescription = videos[1]
                
                let item = CSSearchableItem(uniqueIdentifier: "\(indexPath.row)", domainIdentifier: "com.dimmalysh", attributeSet: attributedSet)
                item.expirationDate = Date.distantFuture
                
                CSSearchableIndex.default().indexSearchableItems([item], completionHandler: { (error) in
                    if let error = error {
                        print("Indexing error: \(error.localizedDescription)")
                    } else {
                        print("Search item successfully indexed!")
                    }
                })
            })
            
            let deleteIndexItem = UIAlertAction(title: "Delete index item", style: .default, handler: { (action) in
                if let index = self.favorites.index(of: indexPath.row) {
                    self.favorites.remove(at: index)
                    userDefaults.set(self.favorites, forKey: "favorites")
                    tableView.reloadRows(at: [indexPath], with: .none)
                    
                    CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(indexPath.row)"], completionHandler: { (error) in
                        if let error = error {
                            print("Indexing error: \(error.localizedDescription)")
                        } else {
                            print("Search item successfully removed!")
                        }
                    })
                }
            })
            
            let cancelItem = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            searchMenu.addAction(addIndexItem)
            searchMenu.addAction(deleteIndexItem)
            searchMenu.addAction(cancelItem)
            
            self.present(searchMenu, animated: true, completion: nil)
        }
        
        searchAction.backgroundColor = UIColor.green
        
        return [searchAction]
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers Methods
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributed = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline),
                               NSForegroundColorAttributeName: UIColor.black]
        let subtitleAttributed = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline),
                                  NSForegroundColorAttributeName: UIColor.lightGray]
        
        let mutableTitleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributed)
        let mutableSubtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributed)
        
        mutableTitleString.append(mutableSubtitleString)
        
        return mutableTitleString
    }
    
    func showVideo(_ index: Int) {
        if let url = URL(string: "https://youtu.be/\(urlRecord(index: index))") {
            let safariViewController = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            safariViewController.delegate = self
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
    func urlRecord(index: Int) -> String {
        return urlVideo[index]
    }
}
