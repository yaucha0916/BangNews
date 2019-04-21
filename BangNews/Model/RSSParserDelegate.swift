//
//  RSSParserDelegate.swift
//  BangNews
//
//  Created by 葉育彰 on 2019/2/19.
//  Copyright © 2019 葉育彰. All rights reserved.
//  參考用
//struct news {
//    var title:String?
//    var link:String?
//    var pubDate:String?
//    var imgLink:String?
//    var subTitle:String?
//}
import Foundation

class RSSParserDelegate: NSObject,XMLParserDelegate {
    var currentNewsItem:News?          //暫存目前要解析的這則新聞
    var currentElementValue:String?    //暫存目前解析到的字
    var resultArray = [News]()         //要傳回ViewController的新聞陣列
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "item"{     //catch到的標籤名稱item的開始標籤
            //START A NEW ITEM
            currentNewsItem = News()
        }else if elementName == "title"{   //catch到的標籤名稱title的開始標籤
            currentElementValue = nil       //將目前解析到的字清空，準備裝入title的文字內容
        }else if elementName == "link"{    //catch到的標籤名稱link的開始標籤
            currentElementValue = nil       //將目前解析到的字清空，準備裝入link的文字內容
        }else if elementName == "pubDate"{ //catch到的標籤名稱pubDate的開始標籤
            currentElementValue = nil       //將目前解析到的字清空，準備裝入pubDate的文字內容
        }else if elementName == "description"{   //catch到的標籤名稱description的開始標籤
            currentElementValue = nil       //將目前解析到的字清空，準備裝入description的文字內容
        }
        //如果是解析到其他的標籤就 略過
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" //catch到的標籤名稱item的結束標籤，且currentNewsItem暫存目前要解析到的字裡面有字
        {
            if currentNewsItem != nil
            {
                resultArray.append(currentNewsItem!)   //將解析好的新聞依序加入新聞陣列
                currentNewsItem = nil                  //遇到item標籤的結尾，代表另一個item要開始了，把暫存目前解析到的字清空
            }
        }else if elementName == "title"{        //catch到的標籤名稱title的結束標籤
            currentNewsItem?.title = currentElementValue   //將目前解析到的字裝入News的title的屬性
        }else if elementName == "link"{
            currentNewsItem?.link = currentElementValue    //同上類推
        }else if elementName == "pubDate"{
            currentNewsItem?.pubDate = currentElementValue     //同上類推
        }else if elementName == "description"{
            currentNewsItem?.description = currentElementValue   //同上類推
        }
        currentElementValue = nil   //解析好的字已經存入屬性中，將暫存目前解析到的字清空
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElementValue == nil{            //如果目前暫存目前解析到的字裡面沒值
            currentElementValue = string             //直接把解析到的字元賦值給他
        }else{
            currentElementValue = currentElementValue! +  string  //否則將解析到的字元加在暫存目前解析到的字的後面
        }
    }
    
    func getResult()->[News]{      //回傳擷取到的新聞陣列
        return resultArray
    }
}
