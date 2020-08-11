//
//  MainTableViewController.swift
//  NewsApplication
//
//  Created by Акбар Уметов on 05.08.2020.
//  Copyright © 2020 Akbar Umetov. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImageWebPCoder

class MainTableViewController: UITableViewController {
    
    private var newsData: NewsData?
    
    private var updatedData = [NewsData?]()
    private var i = 2
    private var newsCounter = 0
    
    let myRefreshControl = { () -> UIRefreshControl in
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    
        parseJSON(urlString: param, completionHandler: {

            self.updatedData.append(self.newsData)
            
                        self.tableView.reloadData()
        })
        
        tableView.refreshControl = myRefreshControl
        
        tableView.delegate = self
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        parseJSON(urlString: param, completionHandler: {

            self.updatedData.append(self.newsData)
            
                        self.tableView.reloadData()
        })
        
        sender.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsData?.results.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
        
        if let lastIndex = newsData?.results.count {
        
        if let result = updatedData[((lastIndex + newsCounter) / 10) - i]?.results[indexPath.row] {
            cell.titleLabel.text = result.title

            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)

            let imageURL = URL(string: result.images[0].image)
            DispatchQueue.main.async {
                cell.imageLabel.sd_setImage(with: imageURL!)
            }

            let textWithoutTags = result.resultDescription
            cell.descriptionLabel.text = textWithoutTags.replacingOccurrences(of: "<[^>]+>",
                                                                              with: "",
                                                                              options: .regularExpression,
                                                                              range: nil)

            let timeInterval = Double(result.publicationDate)
            let myNSDate = Date(timeIntervalSince1970: timeInterval)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let myString = formatter.string(from: myNSDate)
            cell.dataLabel.text = myString
        } else {
            return UITableViewCell()
        }
        } else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func parseJSON(urlString: String, completionHandler: @escaping () -> ()) {
//        let urlString = param
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let data = data {
                if error == nil {
                    do {
                        let decoder = JSONDecoder()
                        let task = try decoder.decode(NewsData.self, from: data)
  
                        self.newsData = task
                        
                        
                        DispatchQueue.main.async {
                            completionHandler()
                            print(task)
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    // TODO: func that gets next value from model. Make pagination on tableView with reloadData()
    // TODO: secondView which shows full news https://kudago.com/public-api/v1.4/news/newsId/?fields=id,publication_date,title,slug,description,body_text,images,site_url
    // TODO: find by title func
    // TODO: find by cityname
    // TODO: comments using news id and url: https://kudago.com/public-api/v1.2/news/newsId/comments/
    // TODO: decorative CardView on tableViewCell
    // TODO: view kudago url on full news page
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (newsData?.results.count)! - 1 {

            guard let nextPage = newsData?.next else { return }

            parseJSON(urlString: nextPage) {
                self.i += 1
                self.newsCounter += 20
                self.updatedData.append(self.newsData)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        

    }
    
}

