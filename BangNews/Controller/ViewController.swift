//
//  ViewController.swift
//  BangNews
//
//  Created by 葉育彰 on 2019/2/19.
//  Copyright © 2019 葉育彰. All rights reserved.
//


//MARK: - 全域宣告
import UIKit
import SafariServices
//import Firebase


class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,SFSafariViewControllerDelegate,MyTabBarDelegate
{
    
//MARK: - 資料結構成員
//    var ref: DatabaseReference!
    var jsonData = AllData()
//    var webSiteArray = [WebSite]()
//    var newsCategoryArray = [NewsCategory]()
    var newsToShowArray = [News]()
//    var favoriteDict = [String:Bool]()
    var categoryArray:[String]!   //存放按鈕標題的文字陣列
    //var myTabBar:MyTabBar?
    var selected_news_type:Int = 0       //紀錄選擇的新聞目前選擇的新聞類別
    var default_img_num:Int = 0          //預設新聞圖片輪轉數字
    var session = URLSession(configuration: .default)    //建立一個預設的URLSession物件，用來跟伺服器交換資料的物件
    @IBOutlet var barBtnItems: [UIBarButtonItem]!        //左上與右上按鈕
    @IBOutlet weak var btn_bang: UIBarButtonItem!           //右上按鈕
    @IBOutlet weak var btn_favorite: UIBarButtonItem!       //左上按鈕
    @IBOutlet weak var current_news_type_btn: MyTabBar!     //新聞種類可滑動按鍵bar
    @IBOutlet weak var introView: UIView!                   //歡迎畫面
    @IBOutlet weak var leftSwipeOutlet: UISwipeGestureRecognizer!
    @IBOutlet weak var rightSwipeOutlet: UISwipeGestureRecognizer!
    
    
//MARK: - view的生命週期函數
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewDidLoad()")
        jsonData = load_BangNewsDataSource_json()       //讀取ＪＳＯＮ資料
        parseDescriptionToSubTitleAndImg_link()         //分析完每則新聞的Description，填入SubTitle和Img_link
        // Do any additional setup after loading the view, typically from a nib.
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.current_news_type_btn.delegate = self
        
        myTableView.refreshControl = UIRefreshControl()        //生成一個表格更新控制器UIRefreshControl()  存入 myTableView.refreshControl屬性
        myTableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)   //手動設定 Target Action
        
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
        self.view.layer.insertSublayer(gradientLayer, below: myTableView.layer)
        
        if jsonData.webSites![0].newsCategoryArray![0].newsArray!.count == 0
        {
            //沒有新聞代表安裝完第一次使用此軟體，顯示歡迎畫面
            introView.isHidden = false      //不隱藏歡迎畫面
            btn_bang.isEnabled = false      //使按鍵不能按
            btn_favorite.isEnabled = false  //使按鍵不能按
            //使左右不能滑
            leftSwipeOutlet.isEnabled = false
            rightSwipeOutlet.isEnabled = false
            //下滑指示箭頭動畫
            self.introView.viewWithTag(123)?.frame.origin.y = 90
            UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.repeat, animations: {
                self.introView.viewWithTag(123)?.frame.origin.y = 120
            })
        }
        
        categoryArray = ["頭條","科技","財經","運動","國際","政治","娛樂","社會","生活"]
        
        //---------------------串接firebase----------------
        //比對本地版本號與firebase版本號
//        ref = Database.database().reference()   //上網取得database的根目錄的reference
//        let version_path = ref.child("bangNewsData/version")  //找到版本分支網址
//        print(version_path)
//        var version:Float?      //宣告版本號
//        version_path.observeSingleEvent(of: .value) {    //只有打開APP時觀察一次
//            (snapshot) in
//            version = Float(truncating: (snapshot.value as? NSNumber) ?? 0)   //將查到的value轉成NSNumber，再轉成Float，沒轉成功填入0
//            print("firebase data version is \(version ?? 0)")
//            if version == 0.0 {
//                print("沒有從firebase取得版本號")
//            }else{
//                if version == self.jsonData.version{
//                    print("本地版本號與firebase版本號相符，無須從線上拉資料下來")
//                }else{
//                    //以線上版本為主，抓取線上資料存入jsonData
//                    print("本地版本號與firebase版本號不符，抓取線上資料存入jsonData")
//                    let wantKeywords_path = self.ref.child("bangNewsData/wantKeywords")  //找到版本分支網址
//                    let tabBarTitles_path = self.ref.child("bangNewsData/tabBarTitles")  //找到版本分支網址
//                    let bangKeywords_path = self.ref.child("bangNewsData/bangKeywords")  //找到版本分支網址
//
//                    wantKeywords_path.observeSingleEvent(of: .value, with: { (snapshot) in
//                        self.jsonData.wantKeywords = (snapshot.value as? [String]) ?? []
//                        print("updated wantKeywords:\(self.jsonData.wantKeywords ?? ["null"])")
//                    })
//
//                    tabBarTitles_path.observeSingleEvent(of: .value, with: { (snapshot) in
//                        self.jsonData.tabBarTitles = (snapshot.value as? [String]) ?? []
//                        print("updated tabBarTitles:\(self.jsonData.tabBarTitles ?? ["null"])")
//                    })
//
//                    bangKeywords_path.observeSingleEvent(of: .value, with: { (snapshot) in
//                        self.jsonData.bangKeywords = (snapshot.value as? [String]) ?? []
//                        print("updated bangKeywords:\(self.jsonData.bangKeywords ?? ["null"])")
//                    })
//
//                }
//            }
//        }
        //-------------------------------------------------------------------------------------------------------
        
        //初始化UILongPressGestureRecognizer填入target-action，去寫longPressed函式
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        //在myTableView加入觸控事件
        myTableView.addGestureRecognizer(longPressRecognizer)
        //self.current_news_type_btn.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 42.0)
        //print(current_news_type_btn.frame)
        
        //readFavoriteDict_From_UserDefaults()
        //updateWebSiteArray_by_favoriteDict()

        //reloadWebSiteArrayToMyTableView(news_type_rowValue: selected_news_type)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        myTableView.refreshControl?.attributedTitle = NSAttributedString(string: "更新中...")      //表格更新控制器UIRefreshControl加上文字
        DispatchQueue.main.async {
            self.myTableView.reloadData()
            if self.current_news_type_btn.scrollView.frame.width > self.current_news_type_btn.scrollView.contentSize.width{  //如果是大螢幕寬度大於450
                self.current_news_type_btn.scrollView.isScrollEnabled = false  //讓他不能捲動
                UIView.animate(withDuration: 0.5, animations: {
                    self.current_news_type_btn.scrollView.contentOffset = CGPoint(x: -(self.current_news_type_btn.scrollView.frame.width - self.current_news_type_btn.scrollView.contentSize.width)/2, y: 0)  //將scrollView的內容移到正中間
                })
            }
        }
        //readFavoriteDict_From_UserDefaults()
        //updateWebSiteArray_by_favoriteDict()
    }
    
    //畫面已經出現後
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        btn_bang.image = UIImage(named: "bang_normal")  //改變按鍵圖案讓按鍵有動畫效果
        btn_favorite.image = UIImage(named: "favorite_normal")  //改變按鍵圖案讓按鍵有動畫效果
        //修復程式剛開啟，出現重複新聞
        //        if neverViewDidLoad
        //        {
        //            reloadWebSiteArrayToMyTableView(news_type_rowValue: current_news_type_btn.selectedSegmentIndex)
        //            DispatchQueue.main.async
        //                {
        //                    self.myTableView.reloadData()
        //                    print("myTableView.reloadData()")
        //            }
        //        }
    }
    
    //暫時使用此函式
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotate(from: fromInterfaceOrientation)
        //tabbar移到中間
        if self.current_news_type_btn.scrollView.frame.width > self.current_news_type_btn.scrollView.contentSize.width{  //如果是大螢幕寬度大於450
            self.current_news_type_btn.scrollView.isScrollEnabled = false  //讓他不能捲動
            UIView.animate(withDuration: 0.5, animations: {
                self.current_news_type_btn.scrollView.contentOffset = CGPoint(x: -(self.current_news_type_btn.scrollView.frame.width - self.current_news_type_btn.scrollView.contentSize.width)/2, y: 0)  //將scrollView的內容移到正中間
            })
        }
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
        self.view.layer.insertSublayer(gradientLayer, below: myTableView.layer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {         //use segue go to another view
        super.prepare(for: segue, sender: sender)
        for btn in barBtnItems{
            btn.isEnabled = false  //按鍵按下準備由segue轉換場景，將按鍵暫時disable，預防按鍵連點造成多次載入頁面
        }
        //將self傳到FavoriteViewController.mainPageVC
        if segue.identifier == "go_to_favorite"{
            btn_favorite.image = UIImage(named: "favorite_selected")   //改變按鍵圖案讓按鍵有動畫效果
            //將ViewController本身傳到目的地的ViewController
            let favoriteVC = segue.destination as! FavoriteViewController
            favoriteVC.mainPageVC = self
        }
        //將self傳到BangViewController.mainPageVC
        if segue.identifier == "go_to_bang"{
            btn_bang.image = UIImage(named: "bang_selected")   //改變按鍵圖案讓按鍵有動畫效果
            //將ViewController本身傳到目的地的ViewController
            let bangVC = segue.destination as! BangViewController
            bangVC.mainPageVC = self
        }
        for btn in barBtnItems{
            btn.isEnabled = true  //將按鍵改回可以按，測試完成可預防按鍵連點造成多次載入頁面
        }
    }
    

    
//MARK: - UITableViewDataSource,UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        newsToShowArray = [News]()        //先把newsToShowArray清空，才能裝入新的陣列
        for website in jsonData.webSites!{      //遍歷各個新聞網址
            if website.isSubscribed == true{
                let category = website.newsCategoryArray![selected_news_type]   //找到目前使用者挑選的新聞種類
                if category.xmlAddress != nil{        //如果這個網站有這個類別的新聞xmlAddress網址
                    bang(newsArray: website.newsCategoryArray![selected_news_type].newsArray)   //輸入完整新聞陣列，做過過濾後存入Global的newsToShowArray
                }
            }
        }
        print("reloadTableView共有\(newsToShowArray.count)則新聞")
        return newsToShowArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NewsTableViewCell else{ return UITableViewCell() } //轉型optional binding
        //處理subTitle出現亂碼網址
        if newsToShowArray[indexPath.row].subTitle!.contains("http"){
            cell.cell_subTitle.text = ""  //設定副標題
        }else{
            cell.cell_subTitle.text = newsToShowArray[indexPath.row].subTitle   //設定副標題
        }
        //微調tableViewCell顯示內容：title字數兩倍變回一倍
        cell.cell_title.text = word_x2_to_x1(word_x2: newsToShowArray[indexPath.row].title)   //設定標題
        cell.cell_pubDate.text = String((word_x2_to_x1(word_x2: newsToShowArray[indexPath.row].pubDate)?.split(separator: "+")[0])!)  //設定發佈時間
        
        
        
        //將圖片存至家目錄+"/Library/Caches/images/"
        let fileManager = FileManager.default       //生成檔案管理員
        var newsTitle = self.newsToShowArray[indexPath.row].title ?? ""   //新聞標題
        if newsTitle.count < 10{          //為了確保newsTitle，如果newsTitle字數小於10，就在字串後面+11111111
            newsTitle.append("11111111")
        }
        let fileNameEndIndex = newsTitle.index(newsTitle.startIndex, offsetBy: 7)   //取新聞標題的前8個字
        let fileName = newsTitle[newsTitle.startIndex...fileNameEndIndex]   //擷取newsTitle的前8個字當檔名

        let path = NSHomeDirectory() + "/Library/Caches/images/" + fileName       //編輯路徑與檔名
        //print(path)
        
        //-----------建立儲存圖片的資料夾  NSHomeDirectory() + "/Library/Caches/images"
        //設定未來要長期存放圖檔的路徑
        let imageDir = NSHomeDirectory() + "/Library/Caches/images"
        if !fileManager.fileExists(atPath: imageDir){   //不存在代表安裝完第一次使用此軟體或者是新聞更新，資料夾已被刪除
            try! fileManager.createDirectory(atPath: imageDir, withIntermediateDirectories: false, attributes: nil)
        }
        
        guard !fileManager.fileExists(atPath: path) else  //如果圖片檔案不存在執行下面後續動作，否則執行else{}內的動作
        {
            do{
                let imgData = try Data(contentsOf: URL(fileURLWithPath: path))  //讀取圖檔DATA
                let img = UIImage(data: imgData)   //DATA轉UIImage
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()     //loading轉圈停止
                    cell.imgCover.isHidden = true              //照片遮罩隱藏
                    cell.cell_img.image = img          //將圖片放上cell
                    //print("使用本地端快取照片")
                }
                
            }catch{
                print("從/Library/Caches/images抓圖檔失敗：\(error.localizedDescription)")
            }
            return cell
        }
        
        //開始下載圖片
        let img_session = URLSession(configuration: .default)  //建構一個URLSession物件
        if let img_link = newsToShowArray[indexPath.row].img_link{  //從要顯示的新聞陣列中，取出圖片網址
            if let imageUrl = URL(string: img_link){          //將網址轉成URL
                //撰寫下載任務
                let task = img_session.dataTask(with: imageUrl, /*下載完後要做的事*/ completionHandler: { (data, response, error) in
                    if error != nil{
                        print("img_session_task_error:\(error?.localizedDescription ?? "")")
                        return
                    }
                    if let loadedData = data{
                        let loadedImage = UIImage(data: loadedData)     //下載完圖片的DATA轉成UIImage
                        DispatchQueue.main.async {
                            cell.activityIndicator.stopAnimating()     //loading轉圈停止
                            cell.imgCover.isHidden = true              //照片遮罩隱藏
                            cell.cell_img.image = loadedImage          //將圖片放上cell
                        }
                        
                        //將圖片存至家目錄+"/Library/Caches/images/"
                        if !fileManager.fileExists(atPath: path)        //判斷如果該路徑檔案不存在，就存檔
                        {
                            do{
                                try loadedData.write(to: URL(fileURLWithPath: path))
                            }catch{
                                print("圖片存檔失敗：\(error.localizedDescription)")
                            }
                        }
                        
                        
                    }
                })
                //啟動下載任務
                task.resume()
                //下載轉圈與照片遮罩顯現
                cell.activityIndicator.startAnimating()
                cell.imgCover.isHidden = false
            }
        }else{
            //沒有網址就放預設圖片
            cell.cell_img.image = UIImage(named: "no_Image.jpg")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)  //取消選取色塊
        showSafari(link: word_x2_to_x1(word_x2: newsToShowArray[indexPath.row].link))  //開啟瀏覽器套件
    }
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    


//MARK: - Target-Action函式

    //下拉更新，從RSS下載新的新聞內容
    @objc func handleRefresh(){
        //-----------刪除圖片的資料夾  NSHomeDirectory() + "/Library/Caches/images"
        let fileManager = FileManager.default
        let imageDir = NSHomeDirectory() + "/Library/Caches/images"
        if fileManager.fileExists(atPath: imageDir){
            try! fileManager.removeItem(atPath: imageDir)
        }
        //下載新的新聞從RSS
        downloadXML()
    }
    
    //歡迎畫面按下我知道了
    @IBAction func closeIntroView(_ sender: UIButton)
    {
        introView.isHidden = true    //隱藏歡迎畫面
        btn_bang.isEnabled = true    //使按鍵可以按
        btn_favorite.isEnabled = true  //使按鍵可以按
        //使左右可以滑
        leftSwipeOutlet.isEnabled = true
        rightSwipeOutlet.isEnabled = true
    }

    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer)    //向右滑動
    {
        if selected_news_type > 0        //目前選到的新聞種類大於0
        {
            selected_news_type -= 1      //新聞種類Int-1
            myTableView.reloadData()
        }
        current_news_type_btn.animate_move_under_bar(index: selected_news_type)     //移動白色指示bar
        //print(categoryArray[selected_news_type])
        
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer)    //向左滑動
    {
        if selected_news_type < categoryArray.count - 1        //目前選到的新聞種類小於最大值
        {
            selected_news_type += 1      //新聞種類Int+1
            myTableView.reloadData()
        }
        current_news_type_btn.animate_move_under_bar(index: selected_news_type)     //移動白色指示bar
        //print(categoryArray[selected_news_type])
    }
    
    //長按NewsTableViewCell，跳出AlertController，詢問是否收藏此新聞
    @objc func longPressed(_ sender:UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizer.State.began {     //長按狀態為 開始
            let touchPoint = sender.location(in: self.myTableView)               //長按位置in myTableView的哪個座標回傳CGPoint
            if let indexPath = myTableView.indexPathForRow(at: touchPoint) {
                //myTableView的indexPathForRow(at: touchPoint)方法填入CGPoint，有可能得到indexPath，也有可能只點到header,footer回回傳nil，所以要做optional binding
                print("Long pressed row: \(indexPath.row)")
                if let favoriteNews = jsonData.favoriteNews{
//                    if favoriteNews.count >= 20{
//                        //新增AlertController，如果收藏的新聞大於20則，跳出警告視窗
//                        let alert = UIAlertController(title: "免費版本最多只能收藏20則新聞", message:"感謝您的支持", preferredStyle: .alert)
//                        let actionOK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                        alert.addAction(actionOK)
//                        present(alert, animated: true, completion: nil)      //推出AlertController
//                    }else{
                        var compare:Bool = false               //確認下方迴圈跑完是否有比對到相同的新聞標題
                        for allreadySaveNews in favoriteNews{
                            if allreadySaveNews.title == newsToShowArray[indexPath.row].title{
                                compare = true     //如果有相符改成ture
                            }
                        }
                        if compare{ //如果有相符
                            //新增AlertController，如果按下OK，執行收藏閉包
                            let alert = UIAlertController(title: "您已收藏過此新聞囉!", message: nil, preferredStyle: .alert)
                            let actionOK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alert.addAction(actionOK)
                            present(alert, animated: true, completion: nil)      //推出AlertController
                        }else{ //如果沒有相符
                            addToFavorites(indexPath: indexPath)
                        }
                    //}
                }else{  //jsonData.favoriteNews如果為空值nil
                    addToFavorites(indexPath: indexPath)
                }
            }
        }
    }
    
    //MARK: - 自定義函式
    
    
    //MARK: MyTabBarDelegate
    //MyTabBar會自己呼叫此函式，傳入第幾個按鍵被按下
    func btnDidClick(_ sender: MyTabBar, whichBtn: Int) {
        selected_news_type = whichBtn    //存入selected_news_type選中的新聞類別
        myTableView.reloadData()         //重新載入表格
    }
    //MyTabBar在生成bar上的button時會自己呼叫此函式，此函式會回傳新聞種類字串陣列，所以此函式可以設定bar上的button的數量與名稱
    func myTabBar_titles(_ myTabBar: MyTabBar) -> [String] {
        return categoryArray
    }
    
    
    //MARK:  XML分析
    //將xml網址輸入，自動將擷取到的新聞加入相對應的新聞陣列
    func downloadXML(){
        for i in 0..<jsonData.webSites!.count{
            for j in 0..<jsonData.webSites![i].newsCategoryArray!.count{
                if let okXmlAddress = jsonData.webSites![i].newsCategoryArray![j].xmlAddress{   //如果xmlAddress有值繼續執行下面程式碼
                    //網址轉URL
                    if let url = URL(string: okXmlAddress){     //將網址轉成ＵＲＬ
                        let task = session.dataTask(with: url) { (data, response, error) in    //使用session物件建立URLSessionDataTask物件，並在閉包內做要做的事，屬於非阻塞式下載資料
                            if let error = error{                        //如有拋出錯誤推出錯誤視窗
                                DispatchQueue.main.async {
                                    self.popAlert(with: error.localizedDescription)
                                }
                                print(error.localizedDescription)
                                return       //發生錯誤直接跳出函式
                            }else{
                                if let okData = data{
                                    //print( NSString(data: okData, encoding: String.Encoding.utf8.rawValue))
                                    let parser = XMLParser(data: okData)                        //實體化一個XMLParser(data: okData)物件，放入要分析的okData
                                    let rssParserDelegate = RSSParserDelegate()                 //生成服從XMLParserDelegate協定的實體
                                    parser.delegate = rssParserDelegate                         //存入parser的delegate屬性
                                    if parser.parse() == true{      //開始進行分析，如果分析成功回傳ＴＲＵＥ
                                            self.jsonData.webSites![i].newsCategoryArray![j].newsArray = rssParserDelegate.getResult()       //將分析出來的新聞陣列存入該新聞類別
                                    }else{
                                        print("parse fail")     //分析失敗
                                    }
                                }
                            }
                            self.parseDescriptionToSubTitleAndImg_link()       //分析完每則新聞的Description，填入SubTitle和Img_link

                            DispatchQueue.main.async {      //資料下載結束前，在主柱列執行重新載入列表與停止更新轉圈
                                if j == self.selected_news_type{      //只有在目前選到的新聞種類時才更新列表，這樣才不會更新很多次
                                    //要表格重新載入
                                    self.myTableView.reloadData()
                                    //結束後停止下拉動畫,恢復表格位置
                                    self.myTableView.refreshControl?.endRefreshing()
                                    self.save_BangNewsDataSource_json(with: self.jsonData)  //載完新聞回存至json檔
                                }
                            }
                        }
                        task.resume() //任務開始
                    }
                }
            }
        }
    }
    
    func bang(newsArray:[News]?){     //傳入一個新聞陣列，將ＢＡＮＧ掉關鍵字的新聞陣列加入global變數newsToShowArray,輸入的陣列可能為nil所以要先optional binding
        var bangIndexs:[Int] = []        //做一個空的數字陣列來裝未來要刪的ＩＮＤＥＸ值
        if let bangKeywords = jsonData.bangKeywords,var newsArray_inScope = newsArray{  //optional binding
            for i in 0..<newsArray_inScope.count{
                for bang in  bangKeywords{
                    if ((newsArray_inScope[i].title?.contains(bang)) ?? true) || ((newsArray_inScope[i].subTitle?.contains(bang)) ?? true){      //如果新聞標題包含ＢＡＮＧ的字，回傳ＴＲＵＥ
                        bangIndexs.append(i)        //如果contains(bang)回傳ＴＲＵＥ就把該則新聞的ＩＮＤＥＸ加入bangIndexs
                    }
                }
            }
            bangIndexs.sort{$0>$1}          //將ＩＮＴ陣列有大到小排列，這樣等等再刪除時，才不會刪到不該刪的
            for i in 0..<bangIndexs.count{
                print("被刪除的新聞主題:" + (newsArray_inScope.remove(at: bangIndexs[i]).title ?? ""))    //逐個刪除newsArray的項目，remove（）會回傳已刪除的元素，利用此元素印出刪掉的新聞標題
            }
            newsToShowArray.append(contentsOf: newsArray_inScope)   //將ＢＡＮＧ掉關鍵字的新聞陣列加入global變數newsToShowArray
        }
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
    
    //彈出一個ＥＲＲＯＲ視窗，可輸入自訂錯誤訊息當作參數
    func popAlert(with errorCode:String){
        let alert = UIAlertController(title: "Error", message: errorCode, preferredStyle: .alert)  //生成UIAlertController物件
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)  //生成UIAlertAction物件
        alert.addAction(action)         //將action加入alertController的按鍵選項中
        present(alert, animated: true, completion: nil)    //表演出此AlertController
    }
    
    
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
    

    func parseDescriptionToSubTitleAndImg_link()     //0322修改完畢
    {   //把每則新聞拿出來遍歷一次，Description
        for a in 0..<jsonData.webSites!.count
        {
            for b in 0..<jsonData.webSites![a].newsCategoryArray!.count
            {
                for i in 0..<jsonData.webSites![a].newsCategoryArray![b].newsArray!.count
                {
                    if let description = word_x2_to_x1(word_x2: jsonData.webSites![a].newsCategoryArray![b].newsArray![i].description)     //拿出每則新聞的description，如有重複的字先對切
                    {
                        //print(description)
                        if description.hasPrefix("<p><img src=")
                        {   //如果字首是"<p><img src="，開始分析
                            
                            //正則表達式分析img_link
                            do{
                                //先建立NSRegularExpression()正則表達式物件，填入要找的正則，並設定不區分大小寫
                                let regex = try NSRegularExpression(pattern: "(?<=u=)(https?:\\/\\/.*?\\.(png|jpg))", options: .caseInsensitive)
                                //用NSRegularExpression的matches方法，在description中找尋是否有符合圖片網址的字串，range填入搜尋範圍：全部
                                let res = regex.matches(in: description, options: .init(rawValue: 0), range: NSMakeRange(0, description.count))
                                //搜尋結果可能不只一個
                                if res.count > 0
                                {
                                    //將字串轉型為NSString，用NSString的substring方法，填入參數res[0].range為第一個找到的匹配對象的範圍，圖片網址存入img_link
                                    let img_link = (description as NSString).substring(with: res[0].range)
                                    //print(img_link)
                                    //將分析出來的網址存入APP資料結構中
                                    jsonData.webSites![a].newsCategoryArray![b].newsArray![i].img_link = img_link
                                    
                                }
                            }catch{
                                print("img_link正則表達式pattern生成失敗")
                            }
                            
                            //分析副標題
                            //以</p><p>符號當作區隔切開整段文字，回傳一個字串陣列
                            var part_Strings = description.components(separatedBy: "</p><p>")
                            //刪除字串陣列的第一個元素，網址的部分
                            part_Strings.removeFirst()
                            //宣告變數subTitle來裝副標題結果
                            var subTitle:String = ""
                            //遍歷每一段字串陣列
                            for i in 0 ..< part_Strings.count{
                                //如果那一段的最後一個字元是>
                                if part_Strings[i].last == ">"{
                                    //則刪除part_Strings[i]的最後四個字
                                    for _ in 1...4{
                                        part_Strings[i].removeLast()
                                    }
                                }
                                //將符合條件且修剪過的部分字串加入subTitle尾端
                                subTitle.append(part_Strings[i])
                            }
                            jsonData.webSites![a].newsCategoryArray![b].newsArray![i].subTitle = subTitle
                            //將分析出來的subtitle存入APP資料結構中
                        }
                        else  //如果開頭不是"<p><img src="，代表沒有附圖
                        {
                            //就將未經分析的description存入APP資料結構subTitle中
                            jsonData.webSites![a].newsCategoryArray![b].newsArray![i].subTitle = description
                        }
                    }
                }
            }
        }
    }
    
    func addToFavorites(indexPath:IndexPath){
        //新增AlertController，如果按下OK，執行收藏閉包
        let alert = UIAlertController(title: "您要收藏此則新聞嗎？", message: "點選左上愛心圖案可以找到收藏的新聞", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) {
            (alertAction)
            in
            print("加入收藏")
            //如果jsonData的結構成員favoriteNews:[News]! 還沒有存入任何新聞
            if self.jsonData.favoriteNews == nil{
                self.jsonData.favoriteNews = [self.newsToShowArray[indexPath.row]]   //存入只有一則新聞的收藏新聞陣列
            }else{
                self.jsonData.favoriteNews?.append(self.newsToShowArray[indexPath.row])    //append新聞到收藏新聞陣列
            }
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        alert.addAction(actionOK)
        present(alert, animated: true, completion: nil)      //推出AlertController
    }
    
    
    //MARK: - BangNewsDataSource_json
    func load_BangNewsDataSource_json()->AllData
    {
        //從APP sandbox 家目錄 load data 的基本做法
        let fileManager = FileManager.default      //生成檔案管理員
        let jsonPath = NSHomeDirectory() + "/Documents/bangNewsDataSource.json"   //編輯欲打開路徑與檔名
        if fileManager.fileExists(atPath: jsonPath){    //確認檔案是否存在
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath:jsonPath))      //用URL取得檔案的二進位碼DATA
                var jsonData = try JSONDecoder().decode(AllData.self, from: data)   //就data解碼成AllData.self這個類別的結構資料
                print("資料從JSON讀出")
                //json讀出來的新聞陣列如果為nil,就把他改成空陣列,避免啟動APP時開包失敗當機
                for i in 0..<jsonData.webSites!.count{
                    for j in 0..<jsonData.webSites![i].newsCategoryArray!.count{
                        if jsonData.webSites![i].newsCategoryArray![j].newsArray == nil{
                            jsonData.webSites![i].newsCategoryArray![j].newsArray = []
                        }
                    }
                }
                return jsonData  //return result
            }catch{
                print(error.localizedDescription)
            }
        }
        print("load_BangNewsDataSource_json fail")
        return AllData()    //失敗回傳空AllData
    }
    
    func save_BangNewsDataSource_json(with allData:AllData){
        //從APP sandbox 家目錄 load data 的基本做法
        let fileManager = FileManager.default      //生成檔案管理員
        let jsonPath = NSHomeDirectory() + "/Documents/bangNewsDataSource.json"   //編輯欲打開路徑與檔名
        var encoded:Data!         //宣告 編碼過 的 DATA物件
        do{
            encoded = try JSONEncoder().encode(allData)       //嘗試將allData編碼成DATA存入encoded
            if fileManager.fileExists(atPath: jsonPath){      //確認檔案是否存在
                do {
                    let fileURL = URL(fileURLWithPath: jsonPath)        //路徑轉URL
                    try encoded!.write(to: fileURL, options: .atomic)   //DATA物件有一個寫入方法，提供路徑與選項參數，就可以複寫至該檔案
                    print("資料寫入JSON")
                } catch { print(error.localizedDescription) }
                
            }
        }catch{
            print(error.localizedDescription)
        }
        //print(String(data: encoded!, encoding: .utf8)!)
    }
}

    
    
    
//清空newsArray，遍歷過整個webSiteArray，把有訂閱的以及目前所選的新聞類別秀出來
//    func reloadWebSiteArrayToMyTableView(news_type_rowValue:Int){
//        if let webSites = jsonData.webSites{
//        for i in 0 ..< webSites.count
//        {
//            if self.jsonData.webSites![i].isSubscribed == true{
//                var 此網站有沒有此新聞類別:Bool = false
//                for newsCategory in self.jsonData.webSites![i].newsCategoryArray!{
//                    if newsCategory.category! == news_type_rowValue{
//                        if let okXML = newsCategory.xmlAddress{
//                            downloadXML(xmlAddress: okXML,whichWebsite: i)
//                            此網站有沒有此新聞類別 = true
//                        }else{
//                            此網站有沒有此新聞類別 = false
//                        }
//                    }
//                }
//                if 此網站有沒有此新聞類別 == false{
//                    DispatchQueue.main.async
//                        {
//                            self.myTableView.reloadData()
//                            print("myTableView.reloadData()")
//                    }
//                }
//            }
//        }
//        }
//    }
 
//    func updateWebSiteArray_by_favoriteDict() {
//        for i in 0..<self.jsonData.webSites!.count{
//            if let aa = favoriteDict[self.jsonData.webSites![i].webSiteName!]{
//                print("updateWebSiteArray_by_favoriteDict  update OK! \(self.jsonData.webSites![i].webSiteName! ) -> \(aa)")
//                self.jsonData.webSites![i].isSubscribed = aa
//            }else{
//                print("updateWebSiteArray_by_favoriteDict  update fail at \(self.jsonData.webSites![i].webSiteName!)")
//            }
//        }
//    }
    
//    func updateFavoriteDict_by_WebSiteArray(){
//        for webSite in self.jsonData.webSites!{
//            favoriteDict[webSite.webSiteName!] = webSite.isSubscribed
//            print("updateFavoriteDict_by_WebSiteArray \(webSite.isSubscribed!) ---> \(favoriteDict)")
//        }
//    }
//
//    func writeFavoriteDict_To_UserDefaults(){
//        UserDefaults.standard.set(favoriteDict, forKey: "favoriteDict")
//        print("寫入\(favoriteDict)到記憶體")
//
//    }
    
    
//    func readFavoriteDict_From_UserDefaults(){
//
//        if let tmp = UserDefaults.standard.object(forKey: "favoriteDict") as? [String:Bool]{
//            //確定字典內有東西才存入
//            if tmp.isEmpty{
//                print("UserDefaults存的字典沒有東西")
//            }else{
//                favoriteDict = tmp
//                print("從UserDefaults讀出存到FavoriteDict\(tmp),,,\(favoriteDict)")
//            }
//        }
//    }



//    func getPlist(withName filename: String)->NSMutableDictionary?
//    {
//        if  let path = Bundle.main.path(forResource: filename, ofType: "plist")
//            //,let xml = FileManager.default.contents(atPath: path)
//        {
//            if FileManager.default.fileExists(atPath: path){
//                print("file exist")
//                if let rootDict = NSMutableDictionary(contentsOfFile: path){
//                    return rootDict
//                  for (_,element) in rootDict.enumerated()
//                    {
//                        print(element.key)
//                        print(element.value as! Bool)
//                    }
//                }
//            }
//        }
//        return nil
//    }
    
    
//    func setPlist(withName filename: String,inputKey:String,inputValue:Int){
//
//
//        if  let path = Bundle.main.path(forResource: filename, ofType: "plist")
//            //,let xml = FileManager.default.contents(atPath: path)
//        {
//                if FileManager.default.fileExists(atPath: path) {
//                    print("set file exsist")
//                    let rootDict = NSMutableDictionary(contentsOfFile: path)!
//                    print(rootDict)
//                    rootDict.setValue(inputValue, forKey: inputKey)
//                    print(rootDict.write(toFile: path, atomically: true))
//                }
//        }
//                do
//                {
//                    if FileManager.default.fileExists(atPath: plistPath) {
//                        let nationAndCapitalCitys = NSMutableDictionary(contentsOfFile: plistPath)!
//                        nationAndCapitalCitys.setValue(capitalTextField.text!, forKey: nationTextField.text!)
//                        nationAndCapitalCitys.write(toFile: plistPath, atomically: true)
//                    }
//                    //輸入資料
//                    let newItem = favoriteWebSitePList(isSubscribed: ["台視" : false])
//                    let encoder = PropertyListEncoder()
//                    encoder.outputFormat = .xml
//                    let data = try encoder.encode(newItem)
//                    try data.write(to: URL(string: path)!)
//                }catch{
//                    print("decode error:\(error)")
//                }
//            }
//        }
//

//
//        let encoder = PropertyListEncoder()
//        encoder.outputFormat = .xml
//
//        let path = Bundle.main.path(forResource: filename, ofType: "plist")
//        let url = URL(string: path!)!
//        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Preferences.plist")
//
//        do {
//            let data = try encoder.encode(newItem)
//            try data.write(to: url)
//        } catch {
//            print(error)
//        }
//    }
    


//class WebSite:NSObject{
//    var webSiteName:String
//    var newsCategoryArray:[NewsCategory]
//    var isSubscribed:Bool = true
//
//    init(webSiteName:String,newsCategoryArray:[NewsCategory]) {
//        self.webSiteName = webSiteName
//        self.newsCategoryArray = newsCategoryArray
//    }
//}
//
//class NewsCategory:NSObject{
//    var typeNews:news_type
//    var newsArray:[news]?
//    var xmlAddress:String
//
//    init(typeNews:news_type,xmlAddress:String) {
//        self.typeNews = typeNews
//        self.xmlAddress = xmlAddress
//    }
//}
//
//
//struct news {
//    var title:String?
//    var link:String?
//    var pubDate:String?
//    var imgLink:String?
//    var subTitle:String?
//}
//
//struct favoriteWebSitePList: Codable {
//    var isSubscribed:[String:Bool]
//}
//
//enum news_type:Int{
//    case 頭條
//    case 科技
//    case 財經
//    case 運動
//    case 國際
//    case 政治
//    case 娛樂
//    case 社會
//    case 生活
//}

//        webSiteArray.append(WebSite(webSiteName: "聯合新聞網",
//                                    newsCategoryArray:[NewsCategory(typeNews: news_type.頭條,
//                                                                    xmlAddress: "https://udn.com/rssfeed/hottest?ch=news"),
//                                                       NewsCategory(typeNews: news_type.科技,
//                                                                    xmlAddress: "https://udn.com/rssfeed/news/2/7226?ch=news"),
//                                                       NewsCategory(typeNews: news_type.財經,
//                                                                    xmlAddress: "https://udn.com/rssfeed/news/2/6644?ch=news"),
//                                                       NewsCategory(typeNews: news_type.運動,
//                                                                    xmlAddress: "https://udn.com/rssfeed/news/2/7227?ch=news"),
//                                                       NewsCategory(typeNews: news_type.國際,
//                                                                    xmlAddress: "https://udn.com/rssfeed/news/2/7225?ch=news"),
//                                                       NewsCategory(typeNews: news_type.政治,
//                                                                    xmlAddress: "https://udn.com/rssfeed/news/2/6638/6656?ch=news"),
//                                                       NewsCategory(typeNews: news_type.社會,
//                                                                    xmlAddress: "https://udn.com/rssfeed/news/2/6639?ch=news"),
//                                                       NewsCategory(typeNews: news_type.生活,
//                                                                    xmlAddress: "https://udn.com/rssfeed/news/2/6649?ch=news")
//                                                    ]
//                                    )
//                            )
//        webSiteArray.append(WebSite(webSiteName: "自由時報",
//                                    newsCategoryArray:[NewsCategory(typeNews: news_type.頭條,
//                                                                    xmlAddress: "http://news.ltn.com.tw/rss/focus.xml"),
//                                                       NewsCategory(typeNews: news_type.財經,
//                                                                    xmlAddress: "http://news.ltn.com.tw/rss/business.xml"),
//                                                       NewsCategory(typeNews: news_type.運動,
//                                                                    xmlAddress: "http://news.ltn.com.tw/rss/sports.xml"),
//                                                       NewsCategory(typeNews: news_type.國際,
//                                                                    xmlAddress: "http://news.ltn.com.tw/rss/world.xml"),
//                                                       NewsCategory(typeNews: news_type.政治,
//                                                                    xmlAddress: "http://news.ltn.com.tw/rss/politics.xml"),
//                                                       NewsCategory(typeNews: news_type.娛樂,
//                                                                    xmlAddress: "http://news.ltn.com.tw/rss/entertainment.xml"),
//                                                       NewsCategory(typeNews: news_type.社會,
//                                                                    xmlAddress: "http://news.ltn.com.tw/rss/society.xml"),
//                                                       NewsCategory(typeNews: news_type.生活,
//                                                                    xmlAddress: "http://news.ltn.com.tw/rss/life.xml")
//            ]
//            )
//        )
