//
//  NewsDataStucture.swift
//  BangNews
//
//  Created by 葉育彰 on 2019/4/21.
//  Copyright © 2019 葉育彰. All rights reserved.
//
//enum news_type:Int{
//    case 頭條  //0
//    case 科技  //1
//    case 財經  //2
//    case 運動  //3
//    case 國際  //4
//    case 政治  //5
//    case 娛樂  //6
//    case 社會  //7
//    case 生活  //8
//}
//
//json encode decode 資料結構
struct AllData:Codable {
    var bangKeywords:[String]?
    var favoriteNews:[News]?
    var tabBarTitles:[String]?
    var version:Float?
    var wantKeywords:[String]?
    var wantSeeNews:[News]?
    var webSites:[WebSite]?
}

struct WebSite:Codable{
    var webSiteName:String?
    var isSubscribed:Bool?
    var newsCategoryArray:[NewsCategory]?
    
}

struct NewsCategory:Codable{
    var category:Int?
    var xmlAddress:String?
    var newsArray:[News]?
}


struct News:Codable {
    var title:String?
    var link:String?
    var pubDate:String?
    var description:String?
    var img_link:String?
    var subTitle:String?
}

