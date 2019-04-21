//
//  BangViewController.swift
//  BangNews
//
//  Created by 葉育彰 on 2019/2/24.
//  Copyright © 2019 葉育彰. All rights reserved.
//

import UIKit

class BangViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var mainPageVC:ViewController!    //引入ViewController的類別實體
//    var bangKeyWordArray:[String] = UserDefaults.standard.stringArray(forKey: "bangKeyWordArray") ?? [String]()
    var before_bangArray:[String] = []    //存放舊的bang關鍵字陣列，用來比對離開這個view時的bang關鍵字陣列，如果有改變就讓主頁面table view reloadData()
    @IBOutlet weak var bangTextField: UITextField!
    @IBOutlet weak var bangTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bangTableView.delegate = self
        self.bangTableView.dataSource = self
        //調整漸層顏色背景
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors =
            [
                UIColor(red: CGFloat(13.0/255), green: CGFloat(174.0/255), blue: CGFloat(169.0/255), alpha: 1.0).cgColor,
                UIColor(red: CGFloat(13.0/255), green: CGFloat(145.0/255), blue: CGFloat(169.0/255), alpha: 1.0).cgColor,
                UIColor(red: CGFloat(13.0/255), green: CGFloat(112.0/255), blue: CGFloat(190.0/255), alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.view.layer.insertSublayer(gradientLayer, below: bangTextField.layer)
        
        before_bangArray = mainPageVC.jsonData.bangKeywords ?? []   //存放舊的bang關鍵字陣列，用來比對離開這個view時的bang關鍵字陣列，如果有改變就讓主頁面table view reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews() 背景漸層顏色layer")
        //背景漸層顏色layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors =
            [
                UIColor(red: CGFloat(13.0/255), green: CGFloat(174.0/255), blue: CGFloat(169.0/255), alpha: 1.0).cgColor,
                UIColor(red: CGFloat(13.0/255), green: CGFloat(145.0/255), blue: CGFloat(169.0/255), alpha: 1.0).cgColor,
                UIColor(red: CGFloat(13.0/255), green: CGFloat(112.0/255), blue: CGFloat(190.0/255), alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.view.layer.insertSublayer(gradientLayer, below: bangTextField.layer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //check 每個選項是否更動，如有更動reload TableView
        var changed = false
        
        if before_bangArray.count != (mainPageVC.jsonData.bangKeywords ?? []).count {
            changed = true
        }else{
            for i in 0..<before_bangArray.count{   //用來比對離開這個view時的bang關鍵字陣列，如果有改變就讓主頁面table view reloadData()
                if before_bangArray[i] != mainPageVC.jsonData.bangKeywords![i]{
                    changed = true
                }
            }
        }
    
        if changed == true{
            DispatchQueue.main.async {
                self.mainPageVC.myTableView.reloadData()
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let bangKeywords = mainPageVC.jsonData.bangKeywords{
            return bangKeywords.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = bangTableView.dequeueReusableCell(withIdentifier: "bangCell", for: indexPath)
        cell.textLabel?.text = mainPageVC.jsonData.bangKeywords![indexPath.row]
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "arial", size: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {  //table view 編輯模式
        if editingStyle == .delete{                                                         //table view 編輯模式是刪除
            print("Delete \(mainPageVC.jsonData.bangKeywords!.remove(at: indexPath.row))")  //移除bangKeywords陣列中的選到元素
            //UserDefaults.standard.set(bangKeyWordArray, forKey: "bangKeyWordArray")
            bangTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {  //回傳false：代表tableview点击选中效果，放开点击后选中效果消失。
        return false
    }
    
//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {  //accessoryButtonTappedForRowWith：按下附件按鈕後的功能
//        
//    }

    @IBAction func btn_add(_ sender: UIButton!) {
        self.bangTextField.resignFirstResponder()    //收起鍵盤
            if let okKeyWord = bangTextField.text{
                if okKeyWord != ""{                         //確認文字輸入框裡面有字
                    mainPageVC.jsonData.bangKeywords!.append(okKeyWord)    //加入bangKeyword
                    //print(mainPageVC.jsonData.bangKeywords!)       //測試：印出來看一下
                    //UserDefaults.standard.set(bangKeyWordArray, forKey: "bangKeyWordArray")
                    self.bangTextField.text = ""
                    self.bangTableView.reloadData()
                    //新增AlertController，告知使用者已經為他隱藏
                    let alert = UIAlertController(title: "已經為您屏蔽掉「\(okKeyWord)」的新聞", message:"感謝您的使用", preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(actionOK)
                    present(alert, animated: true, completion: nil)      //推出AlertController
                }
            }
        
    
    }
    
    @IBAction func closeKeyboardAndAddWord(_ sender: UITextField)
    {
        btn_add(nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
