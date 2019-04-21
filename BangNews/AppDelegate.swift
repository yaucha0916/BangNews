//
//  AppDelegate.swift
//  BangNews
//
//  Created by 葉育彰 on 2019/2/19.
//  Copyright © 2019 葉育彰. All rights reserved.
//  

import UIKit
//import SQLite3      //引入存取SQLite3的C語言函式庫
//import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //宣告資料庫連線指標
    //var db:OpaquePointer?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //FirebaseApp.configure()
    //--------------匯入資料庫至可存取的NSHomeDirectory() + "/Documents/bangdb.sqlite3"，並開啟資料庫連線
        //取得應用程式所屬的檔案管理員
        //let fileManager = FileManager.default
        //取得捆包中，資料庫檔案的完整路徑（此資料庫檔案路徑唯讀）
        //let sourceFile = Bundle.main.path(forResource: "bangdb", ofType: "sqlite3")!
        //print("資料庫捆包路徑：\(sourceFile)")
        //定義資料庫即將存取的目的地（此資料庫檔案路徑可以讀寫！）
        //let destinationFile = NSHomeDirectory() + "/Documents/bangdb.sqlite3"
        //print("資料庫目的地路徑：\(destinationFile)")
        //如果資料庫不存在於目的地路徑
        //if !fileManager.fileExists(atPath: destinationFile){
            //則從捆包中，將資料庫檔案複製到目的地路徑
        //    try! fileManager.copyItem(atPath: sourceFile, toPath: destinationFile)
        //}
        //開啟資料庫連線，並存入db所在的記憶體位址
        //if sqlite3_open(destinationFile, &db) == SQLITE_OK
        //{
        //    print("資料庫連線成功！")
        //}else{
        //    print("資料庫連線失敗！")
        //}
    //------------匯入json檔至可存取的NSHomeDirectory() + "/Documents/bangNewsDataSource.json"
        //取得應用程式所屬的檔案管理員
        let fileManager = FileManager.default
        //找到BUNDLE中，唯讀的json檔路徑
        let json_bundle = Bundle.main.path(forResource: "bangNewsDataSource", ofType: "json")!
        //設定未來要長期存放json檔的路徑
        let json_destinationFile = NSHomeDirectory() + "/Documents/bangNewsDataSource.json"
        print("json目的地路徑：\(json_destinationFile)")
        if !fileManager.fileExists(atPath: json_destinationFile){   //不存在代表安裝完第一次使用此軟體
            //拷貝json檔從bundle到/Documents/
            try! fileManager.copyItem(atPath: json_bundle, toPath: json_destinationFile)
        }
        
    //-----------建立儲存圖片的資料夾  NSHomeDirectory() + "/Library/Caches/images"
        //設定未來要長期存放圖檔的路徑
        let imageDir = NSHomeDirectory() + "/Library/Caches/images"
        if !fileManager.fileExists(atPath: imageDir){   //不存在代表安裝完第一次使用此軟體或者是新聞更新，資料夾已被刪除
            try! fileManager.createDirectory(atPath: imageDir, withIntermediateDirectories: false, attributes: nil)
        }
        
    //-----------建立儲存 收藏新聞 圖片 的資料夾  NSHomeDirectory() + "/Library/Caches/favoriteImages"
        //設定未來要長期存放 收藏新聞 圖檔的路徑
        let favoriteImagesDir = NSHomeDirectory() + "/Library/Caches/favoriteImages"
        if !fileManager.fileExists(atPath: favoriteImagesDir){   //不存在代表安裝完第一次使用此軟體或者是新聞更新，資料夾已被刪除
            try! fileManager.createDirectory(atPath: favoriteImagesDir, withIntermediateDirectories: false, attributes: nil)
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let mainVC = (window?.rootViewController as! UINavigationController).viewControllers[0] as? ViewController{      //在程式結束前，將資料結構存至ＪＳＯＮ檔  todo
            mainVC.save_BangNewsDataSource_json(with: mainVC.jsonData)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    //應用程式即將結束時
    func applicationWillTerminate(_ application: UIApplication) {
        //如果資料庫指針有存在，關閉資料庫連線
        //guard db != nil else {return}
        //sqlite3_close(db!)
        //儲存ＪＳＯＮ檔
        if let mainVC = (window?.rootViewController as! UINavigationController).viewControllers[0] as? ViewController{      //在程式結束前，將資料結構存至ＪＳＯＮ檔  todo
            mainVC.save_BangNewsDataSource_json(with: mainVC.jsonData)
        }
    }
}

