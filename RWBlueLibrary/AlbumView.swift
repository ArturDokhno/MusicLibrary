//
//  AlbumView.swift
//  RWBlueLibrary
//
//  Created by Артур Дохно on 20.12.2021.
//  Copyright © 2021 Razeware LLC. All rights reserved.
//


import UIKit

class AlbumView: UIView {
  
  private var coverImageView: UIImageView!
  private var indicatorView: UIActivityIndicatorView!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  init(frame: CGRect, coverUrl: String) {
    super.init(frame: frame)
    commonInit()
    NotificationCenter.default.post(name: .BLDownloadImage, object: self, userInfo: ["imageView": coverImageView, "coverUrl" : coverUrl])
  }
  
  private func commonInit() {
    // Настройка фона
    backgroundColor = .black
    // Создайте представление изображения обложки
    coverImageView = UIImageView()
    coverImageView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(coverImageView)
    // Создайте представление индикатора
    indicatorView = UIActivityIndicatorView()
    indicatorView.translatesAutoresizingMaskIntoConstraints = false
    indicatorView.style = .whiteLarge
    indicatorView.startAnimating()
    addSubview(indicatorView)
    
    NSLayoutConstraint.activate([
      coverImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
      coverImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
      coverImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
      coverImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
      indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      indicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
      ])
  }
  
  func highlightAlbum(_ didHighlightView: Bool) {
    if didHighlightView == true {
      backgroundColor = .white
    } else {
      backgroundColor = .black
    }
  }
  
}
