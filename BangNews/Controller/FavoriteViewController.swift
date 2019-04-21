//
//  FavoriteViewController.swift
//  BangNews
//
//  Created by 葉育彰 on 2019/2/23.
//  Copyright © 2019 葉育彰. All rights reserved.
//
//以下是新聞網站的選擇訂閱頁面
import UIKit
import SafariServices
class FavoriteViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SFSafariViewControllerDelegate {
    
    @IBOutlet weak var favoriteTableView: UITableView!
    var mainPageVC:ViewController!    //引入ViewController的類別實體
//    var before_isSubscribedArray:[Bool] = []    //存放舊的訂閱狀態，用來比對離開這個view時的訂閱狀態，如果有改變就讓主頁面table view reloadData()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "訂閱的網站"
            case 1:
                return "收藏的新聞"
            default:
                return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
            case 0:
                return mainPageVC.jsonData.webSites!.count
            case 1:
                return (mainPageVC.jsonData.favoriteNews ?? [News]()).count      //如果jsonData.favoriteNews == nil 就用空新聞陣列代替回傳0
            default:
                return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
        guard let newsCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NewsTableViewCell else{ return cell } //轉型optional binding
        switch indexPath.section {
            case 0:
                //加新聞logo
                if indexPath.row == 0{
                    cell.imageView?.image = UIImage(named: "udn")
                }else if indexPath.row == 1{
                    cell.imageView?.image = UIImage(named: "ltn")
                }
                
                cell.textLabel?.text = mainPageVC.jsonData.webSites![indexPath.row].webSiteName
                //從webSiteArray偵測目前勾選狀態顯示在ＴＡＢＬＥ ＶＩＥＷ
                if mainPageVC.jsonData.webSites![indexPath.row].isSubscribed == true{
                    cell.accessoryType = .checkmark
                }else{
                    cell.accessoryType = .none
                }
//                before_isSubscribedArray.append(mainPageVC.jsonData.webSites![indexPath.row].isSubscribed!)      //存放舊的訂閱狀態，用來比對離開這個view時的訂閱狀態，如果有改變就讓主頁面table view reloadData()
            //print(before_isSubscribedArray)
            case 1:
                if mainPageVC.jsonData.favoriteNews != nil{
                    //處理subTitle出現亂碼網址
                    if mainPageVC.jsonData.favoriteNews![indexPath.row].subTitle!.contains("http"){
                        newsCell.cell_subTitle.text = ""  //設定副標題
                    }else{
                        newsCell.cell_subTitle.text = mainPageVC.jsonData.favoriteNews![indexPath.row].subTitle   //設定副標題
                    }
                    
                    newsCell.cell_title.text = word_x2_to_x1(word_x2: mainPageVC.jsonData.favoriteNews![indexPath.row].title)   //設定標題
                    newsCell.cell_pubDate.text = String((word_x2_to_x1(word_x2: mainPageVC.jsonData.favoriteNews![indexPath.row].pubDate)?.split(separator: "+")[0])!)  //設定發佈時間
                    
                    //將 收藏新聞 圖片存至家目錄+"/Library/Caches/favoriteImages/"
                    let fileManager = FileManager.default       //生成檔案管理員
                    var newsTitle = (mainPageVC.jsonData.favoriteNews![indexPath.row].title) ?? ""   //新聞標題
                    if newsTitle.count < 10{          //為了確保newsTitle，如果newsTitle字數小於10，就在字串後面+11111111
                        newsTitle.append("11111111")
                    }
                    let fileNameEndIndex = newsTitle.index(newsTitle.startIndex, offsetBy: 7)   //取新聞標題的前8個字
                    let fileName = newsTitle[newsTitle.startIndex...fileNameEndIndex]   //擷取newsTitle的前8個字當檔名
                    
                    let path = NSHomeDirectory() + "/Library/Caches/favoriteImages/" + fileName       //編輯路徑與檔名
                    print(path)
                    
                    
                    guard !fileManager.fileExists(atPath: path) else  //如果圖片檔案不存在執行下一段後續動作，如果圖片存在 執行else{}內的動作
                    {
                        do{
                            let imgData = try Data(contentsOf: URL(fileURLWithPath: path))  //讀取圖檔DATA
                            let img = UIImage(data: imgData)   //DATA轉UIImage
                            DispatchQueue.main.async {
                                newsCell.activityIndicator.stopAnimating()     //loading轉圈停止
                                newsCell.imgCover.isHidden = true              //照片遮罩隱藏
                                newsCell.cell_img.image = img          //將圖片放上cell
                                print("使用本地端快取照片")
                            }
                            
                        }catch{
                            print("從/Library/Caches/favoriteImages讀取圖檔DATA失敗：\(error.localizedDescription)")
                            DispatchQueue.main.async {
                                newsCell.activityIndicator.stopAnimating()                           //loading轉圈停止
                                newsCell.imgCover.isHidden = true                                   //照片遮罩隱藏
                                newsCell.cell_img.image = UIImage(named: "no_Image.jpg")            //將預設圖片放上cell
                            }
                        }
                        return newsCell     //guard 中的 else 內從本地端快取照片完 就直接return newsCell，不會執行後續下載動作
                    }
                    
                    //開始下載 收藏新聞 圖片
                    let img_session = URLSession(configuration: .default)  //建構一個URLSession物件
                    if let img_link = mainPageVC.jsonData.favoriteNews![indexPath.row].img_link{  //從要顯示的新聞陣列中，取出 收藏新聞 圖片網址
                        if let imageUrl = URL(string: img_link){          //將網址轉成URL
                            //撰寫下載任務
                            let task = img_session.dataTask(with: imageUrl, /*下載完後要做的事*/ completionHandler: { (data, response, error) in
                                if error != nil{
                                    print("img_session_task_error:\(error?.localizedDescription ?? "")")
                                    DispatchQueue.main.async {
                                        newsCell.activityIndicator.stopAnimating()                           //loading轉圈停止
                                        newsCell.imgCover.isHidden = true                                   //照片遮罩隱藏
                                        newsCell.cell_img.image = UIImage(named: "no_Image.jpg")            //將預設圖片放上cell
                                    }
                                    return
                                }
                                if let loadedData = data{
                                    let loadedImage = UIImage(data: loadedData)     //下載完 收藏新聞 圖片的DATA轉成UIImage
                                    DispatchQueue.main.async {
                                        newsCell.activityIndicator.stopAnimating()     //loading轉圈停止
                                        newsCell.imgCover.isHidden = true              //照片遮罩隱藏
                                        newsCell.cell_img.image = loadedImage          //將圖片放上cell
                                    }
                                    
                                    //將 收藏新聞 圖片存至家目錄+"/Library/Caches/favoriteImages/"
                                    if !fileManager.fileExists(atPath: path)        //判斷如果該路徑檔案不存在，就存檔
                                    {
                                        do{
                                            try loadedData.write(to: URL(fileURLWithPath: path))
                                        }catch{
                                            print(" 收藏新聞 圖片存檔失敗：\(error.localizedDescription)")
                                        }
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        newsCell.activityIndicator.stopAnimating()                           //loading轉圈停止
                                        newsCell.imgCover.isHidden = true                                   //照片遮罩隱藏
                                        newsCell.cell_img.image = UIImage(named: "no_Image.jpg")            //將預設圖片放上cell
                                    }
                                }
                            })
                            //啟動下載任務
                            task.resume()
                            //下載轉圈與照片遮罩顯現
                            newsCell.activityIndicator.startAnimating()
                            newsCell.imgCover.isHidden = false
                        }else{
                            DispatchQueue.main.async {
                                newsCell.activityIndicator.stopAnimating()                           //loading轉圈停止
                                newsCell.imgCover.isHidden = true                                   //照片遮罩隱藏
                                newsCell.cell_img.image = UIImage(named: "no_Image.jpg")            //將預設圖片放上cell
                            }
                        }
                    }else{
                        //沒有網址就放預設圖片
                        DispatchQueue.main.async {
                            newsCell.activityIndicator.stopAnimating()                           //loading轉圈停止
                            newsCell.imgCover.isHidden = true                                   //照片遮罩隱藏
                            newsCell.cell_img.image = UIImage(named: "no_Image.jpg")            //將預設圖片放上cell
                        }
                    }
                    return newsCell
                }
                else
                {
                    break
                }
            default:
                break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section {
        case 0:
            //選擇該列選項，修改webSiteArray的值
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.accessoryType == .checkmark{
                    cell.accessoryType = .none
                    mainPageVC.jsonData.webSites![indexPath.row].isSubscribed = false
                }else{
                    cell.accessoryType = .checkmark
                    mainPageVC.jsonData.webSites![indexPath.row].isSubscribed = true
                }
            }
        case 1:
            tableView.deselectRow(at: indexPath, animated: true)  //取消選取色塊
            showSafari(link: word_x2_to_x1(word_x2: mainPageVC.jsonData.favoriteNews![indexPath.row].link))  //開啟瀏覽器套件
        default:
            break
        }
            //取消選取色塊
            tableView.deselectRow(at: indexPath, animated: true)
        
//            print("AT favorite to use mainpage \(mainPageVC.favoriteDict)//BEFORE")
//            mainPageVC.updateFavoriteDict_by_WebSiteArray()
//            print("AT favorite to use mainpage \(mainPageVC.favoriteDict)//AFFTER")
//            mainPageVC.writeFavoriteDict_To_UserDefaults()
//            print(UserDefaults.standard.object(forKey: "favoriteDict") as! [String:Bool])
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch indexPath.section {
            case 0:
                return [UITableViewRowAction]()
            case 1:
                //左滑刪除功能
                let delete = UITableViewRowAction(style: .destructive, title: "刪除") { (tableViewRowAction, indexPath)
                    in
                    //注意:一定要照此順序,否則會開包到nil
                    
                    //Step1.刪除該則新聞圖片從 家目錄+"/Library/Caches/favoriteImages/"
                    let fileManager = FileManager.default       //生成檔案管理員
                    var newsTitle = (self.mainPageVC.jsonData.favoriteNews![indexPath.row].title) ?? ""   //新聞標題
                    if newsTitle.count < 10{          //為了確保newsTitle，如果newsTitle字數小於10，就在字串後面+11111111
                        newsTitle.append("11111111")
                    }
                    let fileNameEndIndex = newsTitle.index(newsTitle.startIndex, offsetBy: 7)   //取新聞標題的前8個字
                    let fileName = newsTitle[newsTitle.startIndex...fileNameEndIndex]   //擷取newsTitle的前8個字當檔名
                    
                    let path = NSHomeDirectory() + "/Library/Caches/favoriteImages/" + fileName       //編輯路徑與檔名
                    
                    do{
                        try fileManager.removeItem(atPath: path)
                        print("刪除該則 收藏新聞 圖片：\(path)")
                    }catch{
                        print("刪除圖片失敗：\(error.localizedDescription)")
                    }
                    //Step2.刪除資料
                    self.mainPageVC.jsonData.favoriteNews!.remove(at: indexPath.row)
                    //Step3.刪除表格資料
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                return [delete]
            default:
                break
        }
        return nil
    }
    

    
    //每次進到FavoriteViewController都會重新viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        
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
        self.view.layer.insertSublayer(gradientLayer, below: favoriteTableView.layer)
        // Do any additional setup after loading the view.
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
        self.view.layer.insertSublayer(gradientLayer, below:favoriteTableView.layer)
    }
    
//MARK: - 自訂函式 copy from viewController
    func word_x2_to_x1(word_x2 titleX2:String?)->String?{
        //微調tableViewCell顯示內容：title字數兩倍變回一倍，如果本身就不重複則回傳原字串
        var title_first_half:String?    //前半字串
        var title_last_half:String?     //後半字串
        if let titleX2 = titleX2{       //如果輸入的字串有值
            //print(titleX2)
            //生成字串index物件，位於結束位置往負方向 偏移 總文字數量的一半，取得正中間的位置
            let titleEndIndex = titleX2.index(titleX2.endIndex, offsetBy: -titleX2.count/2)
            title_first_half = String(titleX2[..<titleEndIndex])    //生成新字串用舊字串的範圍值，從頭到正中間位置
            title_last_half = String(titleX2[titleEndIndex..<titleX2.endIndex])   //生成新字串用舊字串的範圍值，從正中間位置到結束
            //print(title_first_half!)
            //print(title_last_half!)
            if title_first_half == title_last_half{  //如果前半段等於後半段的文字
                //print("是一個重複的字串")
                return title_first_half   //只回傳前半段
            }else{
                return titleX2   //否則將舊字串回傳
            }
        }
        //如果輸入的字串沒有值，回傳nil
        return nil
    }
    
    
    //輸入一個String?的網址，如果網址有效可推出SafariView並顯示reader
    func showSafari(link:String?){
        if let link_from_tableView = link{      //optional binding
            //print(link_from_tableView)
            let url = URL(string:link_from_tableView)      //生成URL物件
            if let url = url{                   //optional binding
//                UIApplication.shared.open(url, options: [:])
                let config = SFSafariViewController.Configuration()    //生成SFSafariViewController的Configuration設定檔物件
                config.entersReaderIfAvailable = true     //使設定檔物件的 是否進入閱讀模式（如果可以）這個屬性 為真
                //生成SFSafariViewController物件，參數為網址URL與設定檔
                let safariVC = SFSafariViewController(url: url, configuration: config)
                safariVC.dismissButtonStyle = .done                  //設定離開該頁面的按鈕圖示
                safariVC.preferredBarTintColor = UIColor.darkGray      //設定上方bar的顏色
                present(safariVC, animated: true, completion: nil)     //表演出此SafariViewController
            }
        }
    }
    

//    override func viewWillDisappear(_ animated: Bool) {
//        //check 每個選項是否更動，如有更動reload TableView
//        var changed = false
//        for i in 0..<before_isSubscribedArray.count{   //用來比對離開這個view時的訂閱狀態，如果有改變就讓主頁面table view reloadData()
//            if before_isSubscribedArray[i] != mainPageVC.jsonData.webSites![i].isSubscribed{
//                changed = true
//            }
//        }
//        if changed == true{
//            DispatchQueue.main.async {
//                self.mainPageVC.myTableView.reloadData()
//            }
//        }
//    }
    
    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
