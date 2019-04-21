
import UIKit

class MyTabBar: UIView
{
    var categoryArray:[String]!   //存放按鈕標題的文字陣列
    var underBar:UIView!          //目前點選的頁面位置
    @IBOutlet weak var container: UIView!          //最外層框架
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var putBtnArea: UIView!        //scrollView的內容
    var lastBtn:UIButton!         //上一個按鍵一開始為ＮＩＬ
    var totalSize:CGSize!         //putBtnArea的大小，累加每個按鍵的寬度
    
    weak var delegate:MyTabBarDelegate?   //服從該協定的物件實體，也就是ViewController
    
//    override init(frame:CGRect)
//    {
//        super.init(frame: frame)
//    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        //讀取xib檔
        let myTabBar_xib = UINib(nibName: "MyTabBar", bundle: nil)
        let parts = myTabBar_xib.instantiate(withOwner: self, options: nil)
        let myTabBar:UIView = parts[0] as! UIView
        //在MyTabBar這個ＣＬＡＳＳ的實體上加入addSubview ＝＞ ＸＩＢ檔讀出的myTabBar
        self.addSubview(myTabBar)
        //外在的框架大小傳給myTabBar.frame，scrollView.frame，container.frame
        myTabBar.frame = self.bounds
        scrollView.frame = myTabBar.frame
        container.frame = scrollView.frame
        //生成一個寬高為0的CGSize實體，存到totalSize，初始化
        totalSize = CGSize(width: 0, height: 0)
        
//        漸層顏色layer生成
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = self.bounds
//        gradientLayer.colors =
//            [
//                UIColor(red: CGFloat(13.0/255), green: CGFloat(174.0/255), blue: CGFloat(169.0/255), alpha: 1.0).cgColor,
//                UIColor(red: CGFloat(13.0/255), green: CGFloat(145.0/255), blue: CGFloat(169.0/255), alpha: 1.0).cgColor,
//                UIColor(red: CGFloat(13.0/255), green: CGFloat(112.0/255), blue: CGFloat(190.0/255), alpha: 1.0).cgColor
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        container.layer.insertSublayer(gradientLayer, below: scrollView.layer)
        
        //生成UI按鈕們，必須在主佇列
        DispatchQueue.main.async {
            self.categoryArray = self.delegate?.myTabBar_titles(self)     //呼叫協定方法
            print(self.categoryArray!)
            if self.categoryArray != nil{    //確認categoryArray如果有值
                for btnNum in 0..<self.categoryArray.count
                {
                    if self.lastBtn == nil     //代表目前沒有任何按鍵，以下生成第一個按鍵
                    {
                        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: self.scrollView.frame.height))
                        btn.setTitle(self.categoryArray[btnNum], for: .normal)
                        btn.tag = btnNum      //從0開始依序設定按鈕TAG編號，才知道現在按的是哪一顆
                        self.totalSize = btn.frame.size
                        btn.addTarget(self, action: #selector(self.clicked(_:)), for: .touchUpInside)  //手動加入action
                        self.putBtnArea.frame = btn.frame
                        self.putBtnArea.addSubview(btn)
                        self.lastBtn = btn   //將生成的案件存入lastBtn，開始下一次迴圈
                    }
                    else
                    {
                        //從上一個按鍵的Ｘ位置尾端開始製作新案件
                        let btn = UIButton(frame: self.lastBtn.frame.offsetBy(dx: 50.0, dy: 0))
                        btn.setTitle(self.categoryArray[btnNum], for: .normal)
                        btn.tag = btnNum   //從0開始依序設定按鈕TAG編號，才知道現在按的是哪一顆
                        btn.addTarget(self, action: #selector(self.clicked(_:)), for: .touchUpInside)
                        self.totalSize = CGSize(width: self.totalSize.width + btn.frame.width, height: self.scrollView.frame.height)
                        self.putBtnArea.frame = CGRect(x: 0, y: 0, width: self.totalSize.width, height: self.totalSize.height)
                        self.putBtnArea.addSubview(btn)
                        self.lastBtn = btn
                    }
                }
                //putBtnArea.backgroundColor = UIColor.green
                
                
                //self.scrollView.addSubview(self.putBtnArea)
                self.scrollView.contentSize = self.putBtnArea.frame.size
                //print(self.scrollView.frame)
                //print(self.frame)
                //print(self.container.frame)
                //print(self.putBtnArea.frame)
                
                self.underBar = UIView(frame: CGRect(x: 0, y: self.putBtnArea.frame.height - 3, width: 50, height: 3))
                self.underBar.backgroundColor = UIColor.white
                self.putBtnArea.addSubview(self.underBar)
            }
        }
        DispatchQueue.main.async {
            if self.scrollView.frame.width > self.scrollView.contentSize.width{  //如果是大螢幕寬度大於450
                self.scrollView.isScrollEnabled = false  //讓他不能捲動
                self.scrollView.contentOffset = CGPoint(x: -(self.scrollView.frame.width - self.scrollView.contentSize.width)/2, y: 0)  //將scrollView的內容移到正中間
            }
        }
        
        //自動調整按鈕大小
//        radio_btn_outlet.titleLabel?.font = radio_btn_outlet.titleLabel?.font.withSize(radio.frame.height * 0.6)
        //print("呼叫override init(frame: CGRect)")
    }

    
    @objc func clicked(_ sender: UIButton!) {            //䅁下某個按鈕呼叫此函式
        animate_move_under_bar(index: sender.tag)              //動畫移動新聞種類下方白色指示BAR
        print(categoryArray[sender.tag])                       //印出新聞種類
        delegate?.btnDidClick(self, whichBtn: sender.tag)      //呼叫協定的方法
    }
    
    //動畫移動新聞種類下方白色指示BAR
    func animate_move_under_bar(index:Int){
        
        if scrollView.frame.width < self.scrollView.contentSize.width{
                    if index > 4 {        //如果選到index大於4的按鍵，可能會超過螢幕範圍，所以內容向右移動50點的整數倍
                        self.scrollView.setContentOffset(CGPoint(x: (index-4)*50, y: 0), animated: true)
                    }
                    if index < 4 {        //如果選到index小於4的按鍵，可能會超過螢幕範圍，所以內容向左移回原點
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    }
        }

        UIView.animate(withDuration: 0.2, animations: {   //0.2秒完成動畫，每個按鈕寬度50，index就是目前按到第幾個
            //underBar位置移動
            self.underBar.frame = CGRect(x: index * 50, y: Int(self.putBtnArea.frame.height) - 3, width: 50, height: 3)
            //按鈕本身背景顏色改變
            self.putBtnArea.subviews[index].backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            //按鈕本身大小改變
            self.putBtnArea.subviews[index].bounds = CGRect(x: 5, y: 5, width: 50 - 10, height: self.scrollView.frame.height - 10)
        }) { (finished) in
            //按鈕本身 背景顏色.大小 改回原樣
            self.putBtnArea.subviews[index].backgroundColor = UIColor.clear
            self.putBtnArea.subviews[index].bounds = CGRect(x: 0, y: 0, width: 50 , height: self.scrollView.frame.height)
        }
    }

}
