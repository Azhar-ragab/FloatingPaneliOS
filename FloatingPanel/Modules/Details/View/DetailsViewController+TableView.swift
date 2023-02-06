//
//  DetailsViewController+TableView.swift
//  FloatingPanel
//
//  Created by Azhar Ragab on 06/02/2023.
//

import Foundation
import UIKit

extension DetailsViewController: UITableViewDelegate,
                                  UITableViewDataSource {
   
    func setupTableView() {
        tableView.registerCellNib(cellClass: ItemCell.self)
        tableView.estimatedRowHeight = 90
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
    }
  
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getItemList().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(cellClass: ItemCell.self)
        cell.configure(with: getItemList()[indexPath.row])
        return cell
    }
}
