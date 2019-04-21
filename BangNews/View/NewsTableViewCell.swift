//
//  NewsTableViewCell.swift
//  BangNews
//
//  Created by 葉育彰 on 2019/3/5.
//  Copyright © 2019 葉育彰. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {          //客製化新聞NewsTableViewCell
    @IBOutlet weak var cell_img: UIImageView!
    @IBOutlet weak var cell_title: UILabel!
    @IBOutlet weak var cell_subTitle: UILabel!
    @IBOutlet weak var cell_pubDate: UILabel!
    @IBOutlet weak var imgCover: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.4)
        self.layer.cornerRadius = 13                 //設定layer圓角
        cell_img.contentMode = .scaleAspectFill      //調整照片的縮放，放大填滿相框
        cell_img.clipsToBounds = true                //將超出相框的畫面切除
        cell_img.layer.cornerRadius = 13             //設定相框圓角
        imgCover.layer.cornerRadius = 13.0     //設定圖片loading遮罩圓角
        if UIDevice.current.userInterfaceIdiom == .pad{
            cell_title.font = cell_title.font.withSize(20)
            cell_title.numberOfLines = 1
            cell_subTitle.font = cell_subTitle.font.withSize(15)
            cell_pubDate.font = cell_pubDate.font.withSize(12)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
