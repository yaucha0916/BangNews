//
//  MyTabBarDelegate.swift
//  BangNews
//
//  Created by ios on 2019/3/27.
//  Copyright © 2019 葉育彰. All rights reserved.
//

import Foundation
import UIKit
protocol MyTabBarDelegate: AnyObject   //加AnyObject解weak var delegate:MyTabBarDelegate?報錯'weak' must not be applied to non-class-bound
{
    func btnDidClick(_ sender:MyTabBar,whichBtn:Int)           //要當MyTabBar的Delegate必須要實作btnDidClick，這樣當MyTabBar的按鍵被按下觸動MyTabBar的UIButton的target-action－@objc func clicked(_ sender: UIButton!)，在這個func中呼叫delegate?.btnDidClick(self, whichBtn: sender.tag)函式，所以才會在此協定要求必須實作此函式
    
    func myTabBar_titles(_ myTabBar: MyTabBar) -> [String]
        //return一個String陣列，使文字顯現在各個按鈕上，在生成按鈕時呼叫，在Delegate實作
}

