//
//  HorizontalScrollerView.swift
//  RWBlueLibrary
//
//  Created by Артур Дохно on 21.12.2021.
//  Copyright © 2021 Razeware LLC. All rights reserved.
//

protocol HorizontalScrollerViewDataSource: AnyObject {
  // Спрашиваю источник данных сколько просмотров он хочет представить внутри горизонтального скроллера
  func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int
  // Прошу источник данных вернуть представление которое должно появиться в <index>
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView,
                              viewAt index: Int) -> UIView
}

protocol HorizontalScrollerViewDelegate: AnyObject {
  // сообщяю делегату что представление в <index> было выбрано
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView,
                              didSelectViewAt index: Int)
}

import UIKit

class HorizontalScrollerView: UIView {
  
  weak var dataSource: HorizontalScrollerViewDataSource?
  weak var delegate: HorizontalScrollerViewDelegate?
  
  private enum ViewConstants {
    static let Padding: CGFloat = 10
    static let Dimensions: CGFloat = 100
    static let Offset: CGFloat = 100
  }
  
  private let scroller = UIScrollView()
  
  private var contentViews = [UIView]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeScrollView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeScrollView()
  }
  
  func initializeScrollView() {
    
    scroller.delegate = self
    
    addSubview(scroller)
    
    scroller.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      scroller.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scroller.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scroller.topAnchor.constraint(equalTo: self.topAnchor),
      scroller.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollerTapped(gesture:)))
    scroller.addGestureRecognizer(tapRecognizer)
  }
  
  func scrollToView(at index: Int, animated: Bool = true) {
    let centralView = contentViews[index]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
    scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: animated)
  }
  
  @objc func scrollerTapped(gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: scroller)
    guard let index = contentViews.index(where: { $0.frame.contains(location)}) else { return }
    delegate?.horizontalScrollerView(self, didSelectViewAt: index)
    scrollToView(at: index)
  }
  
  func view(at index :Int) -> UIView {
    return contentViews[index]
  }
  
  func reload() {
    // проверяю есть ли источник данных если нет то загружать нечего
    guard let dataSource = dataSource else {
      return
    }
    
    // удалить старые представления контента
    contentViews.forEach { $0.removeFromSuperview() }
    
    // xValue является отправной точкой каждого вида внутри скроллера
    var xValue = ViewConstants.Offset
    // извлечь и добавить новые виды
    contentViews = (0..<dataSource.numberOfViews(in: self)).map {
      index in
      // добавить вид в нужном положении
      xValue += ViewConstants.Padding
      let view = dataSource.horizontalScrollerView(self, viewAt: index)
      view.frame = CGRect(x: CGFloat(xValue), y: ViewConstants.Padding, width: ViewConstants.Dimensions, height: ViewConstants.Dimensions)
      scroller.addSubview(view)
      xValue += ViewConstants.Dimensions + ViewConstants.Padding
      return view
    }
    // после того как все виды будут установлены устанавливаю смещение содержимого для просмотра прокрутки чтобы пользователь мог прокручивать все обложки альбомов
    scroller.contentSize = CGSize(width: CGFloat(xValue + ViewConstants.Offset), height: frame.size.height)
  }
  
  private func centerCurrentView() {
    let centerRect = CGRect(
      origin: CGPoint(x: scroller.bounds.midX - ViewConstants.Padding, y: 0),
      size: CGSize(width: ViewConstants.Padding, height: bounds.height))
    
    guard let selectedIndex = contentViews.index(where: {
      $0.frame.intersects(centerRect) })
    else { return }
    let centralView = contentViews[selectedIndex]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
    
    scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
    delegate?.horizontalScrollerView(self, didSelectViewAt: selectedIndex)
  }
  
}

extension HorizontalScrollerView: UIScrollViewDelegate{
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      centerCurrentView()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    centerCurrentView()
  }
}
