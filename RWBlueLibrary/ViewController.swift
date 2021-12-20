//
//  ViewController.swift
//  RWBlueLibrary
//
//  Created by Артур Дохно on 20.12.2021.
//  Copyright © 2021 Razeware LLC. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
  
  private var currentAlbumIndex = 0
  private var currentAlbumData: [AlbumData]?
  private var allAlbums = [Album]()
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var undoBarButtonItem: UIBarButtonItem!
  @IBOutlet var trashBarButtonItem: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    allAlbums = LibraryAPI.shared.getAlbums()
    
    tableView.dataSource = self
    
    showDataForAlbum(at: currentAlbumIndex)
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    if let albumData = currentAlbumData {
      let row = indexPath.row
      cell.textLabel?.text = albumData[row].title
      cell.detailTextLabel?.text = albumData[row].value
    }
    return cell
  }
  
}
