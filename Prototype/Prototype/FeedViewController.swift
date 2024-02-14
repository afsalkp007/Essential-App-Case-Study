//
//  FeedViewController.swift
//  Prototype
//
//  Created by Afsal on 14/02/2024.
//

import UIKit

struct FeedImageViewModel {
  let description: String?
  let location: String?
  let imageName: String
}

final class FeedViewController: UITableViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 10
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")!
  }
}
