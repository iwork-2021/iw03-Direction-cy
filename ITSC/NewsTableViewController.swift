//
//  NewsTableViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/8.
//

import UIKit

class NewsTableViewController: UITableViewController {
    var items:[Item] = []
    var host:String = "https://itsc.nju.edu.cn"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        fetchData(str: "/xwdt/list.htm");
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    func fetchData(str:String) {
            let url = URL(string: host + str)!
            let task = URLSession.shared.dataTask(with: url, completionHandler: {
                data, response, error in
                if let error = error {
                    print("\(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("server error")
                    return
                }
                
                if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                            let data = data,
                            let string = String(data: data, encoding: .utf8) {
                                DispatchQueue.main.async {
                                    self.regGetSub(pattern: "class=\"news_title\"><a href=(.*)</a></span>(\\s*)<span class=\"news_meta\">(.*)</span>", str: string)
                                    self.fetchData(str: self.findNext(pattern: "<a class=\"next\" href=\"(.*)\" target=", str: string))
                                }
                }
            })
            task.resume()
    }
    
    func regGetSub(pattern: String, str: String)
    {
        var substr:String = ""
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: str, options: [], range: NSRange(str.startIndex..., in:str))
        for match in matches {
            substr = (str as NSString).substring(with: match.range)
            let range1:Range = substr.range(of: "title='")!
            let range2:Range = substr.range(of: "'>")!
            let range3:Range = substr.range(of: "class=\"news_meta\">")!
            let range4:Range = substr.range(of: "</span>",options: .backwards)!
            let range5:Range = substr.range(of: "<a href='")!
            let range6:Range = substr.range(of: "' target=")!
            let title = String(substr[range1.upperBound ..< range2.lowerBound])
            let date = String(substr[range3.upperBound ..< range4.lowerBound])
            let href = String(substr[range5.upperBound ..< range6.lowerBound])
            items.append(Item(title: title, date: date, href: href))
            
        }
        self.tableView.reloadData()
    }
    
    func findNext(pattern: String, str: String) -> String
    {
        var substr:String = ""
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: str, options: [], range: NSRange(str.startIndex..., in:str))
        for match in matches
        {
            substr = (str as NSString).substring(with: match.range)
            let range1:Range = substr.range(of: "<a class=\"next\" href=\"")!
            let range2:Range = substr.range(of: "\" target=")!
            print(String(substr[range1.upperBound ..< range2.lowerBound]))
            return String(substr[range1.upperBound ..< range2.lowerBound])
        }
        return ""
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // Configure the cell...
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! MyTableViewCell
            let item = items[indexPath.row]
            cell.title.text! = String(item.title.prefix(25))
            cell.date.text! = item.date
            return cell
        }
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

}
