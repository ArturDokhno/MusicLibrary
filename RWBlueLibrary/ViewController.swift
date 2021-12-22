//
//  ViewController.swift
//  RWBlueLibrary
//
//  Created by Артур Дохно on 20.12.2021.
//  Copyright © 2021 Razeware LLC. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
  
  private enum Constants {
    static let CellIdentifier = "Cell"
    static let IndexRestorationKey = "currentAlbumIndex"
  }
  
  private var currentAlbumIndex = 0
  private var currentAlbumData: [AlbumData]?
  private var allAlbums = [Album]()
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var undoBarButtonItem: UIBarButtonItem!
  @IBOutlet var trashBarButtonItem: UIBarButtonItem!
  @IBOutlet var horizontalScrollerView: HorizontalScrollerView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    allAlbums = LibraryAPI.shared.getAlbums()
    
    tableView.dataSource = self
    
    horizontalScrollerView.dataSource = self
    horizontalScrollerView.delegate = self
    horizontalScrollerView.reload()

    showDataForAlbum(at: currentAlbumIndex)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    horizontalScrollerView.scrollToView(at: currentAlbumIndex, animated: false)
  }
  
  private func showDataForAlbum(at index: Int) {
    
    // убедился что запрашиваемый индекс меньше чем количество альбомов
    if index < allAlbums.count && index > -1 {
      // получаю альбом
      let album = allAlbums[index]
      // сохраняю данные альбомов, чтобы представить их позже в табличном представлении
      currentAlbumData = album.tableRepresentation
    } else {
      currentAlbumData = nil
    }
    // есть необходимые данные обновляю таблицу
    tableView.reloadData()
  }
  
}

extension ViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let albumData = currentAlbumData else {
      return 0
    }
    return albumData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath)
    if let albumData = currentAlbumData {
      let row = indexPath.row
      cell.textLabel?.text = albumData[row].title
      cell.detailTextLabel?.text = albumData[row].value
    }
    return cell
  }
  
}

extension ViewController: HorizontalScrollerViewDelegate {
  
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int) {
    // беру ранее выбранный альбом и отменяю выбор обложки альбома
    let previousAlbumView = horizontalScrollerView.view(at: currentAlbumIndex) as! AlbumView
    previousAlbumView.highlightAlbum(false)
    // сохраняю текущий индекс обложки альбома который только что нажали
    currentAlbumIndex = index
    // беру выделенную в данный момент обложку альбома и выделяю выделенную область
    let albumView = horizontalScrollerView.view(at: currentAlbumIndex) as! AlbumView
    albumView.highlightAlbum(true)
    // отображаю данные для нового альбома в табличном представлении
    showDataForAlbum(at: index)
  }
  
}

extension ViewController: HorizontalScrollerViewDataSource {
  
  func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int {
    return allAlbums.count
  }
  
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView {
    let album = allAlbums[index]
    let albumView = AlbumView(
      frame: CGRect(x: 0, y: 0, width: 100, height: 100),
      coverUrl: album.coverUrl)
    if currentAlbumIndex == index {
      albumView.highlightAlbum(true)
    } else {
      albumView.highlightAlbum(false)
    }
    return albumView
  }
  
}

//MARK: востановление состояния
extension ViewController {

  override func encodeRestorableState(with coder: NSCoder) {
    coder.encode(currentAlbumIndex, forKey: Constants.IndexRestorationKey)
    super.encodeRestorableState(with: coder)
  }
  
  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)
    currentAlbumIndex = coder.decodeInteger(forKey: Constants.IndexRestorationKey)
    showDataForAlbum(at: currentAlbumIndex)
    horizontalScrollerView.reload()
  }
}

// Пройтись еще раз по всему коду переписав все заново с комитами к каждой строчке
// https://www.raywenderlich.com/477-design-patterns-on-ios-using-swift-part-1-2
// https://www.raywenderlich.com/476-design-patterns-on-ios-using-swift-part-2-2
