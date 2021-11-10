//
//  NewsViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/9.
//

import UIKit

class NewsViewController: UIViewController {
    var host:String = "https://itsc.nju.edu.cn"
    var href:String = ""
    var images:[UIImage] = []
    var i:Int = 0
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    func fetchData() {
        let url = URL(string: host + href)!
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
                                self.regGetSub(pattern: "<h1 class=\"arti_title\">[\\s\\S]*<br /></p></div></div>", str: string)
                                self.getImage(pattern: "<img data-layer=\"photo\" src=\"(.*?) original-src=\"", str: string)
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
            let range1:Range = substr.range(of: "<h1 class=\"arti_title\">")!
            let range2:Range = substr.range(of: "</h1>")!
            let range3:Range = substr.range(of: "<p class=\"arti_metas\"><span class=\"arti_update\">")!
            let range4:Range = substr.range(of: "</span></span></p>")!
            titlelabel.text = String(substr[range1.upperBound ..< range2.lowerBound])
            var tmp:String = String(substr[range3.upperBound ..< range4.lowerBound])
            tmp.filterHTML()
            subtitle.text = tmp
            let range5:Range = substr.range(of: "<div class=\"read\">")!
            //let range6:Range = substr.range(of: "<v:imagedata src=")!
            tmp = String(substr[range5.upperBound ..< substr.endIndex])
            tmp.filterHTML()
            textView1.text! = tmp
        }
    }
    
    func getImage(pattern: String, str: String)
    {
        var substr:String = ""
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: str, options: [], range: NSRange(str.startIndex..., in:str))
        for match in matches {
            substr = (str as NSString).substring(with: match.range)
            let range1:Range = substr.range(of: "<img data-layer=\"photo\" src=\"")!
            let range2:Range = substr.range(of:  "\" original-src=")!
            var tmp:String = String(substr[range1.upperBound ..< range2.lowerBound])
            let url = URL(string: host + tmp)
            let request = URLRequest(url:url!)
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request,completionHandler: {
                (data, response, error) -> Void in
                if error != nil{
                    print(error.debugDescription)
                }else{
                    let img = UIImage(data:data!)
                    DispatchQueue.main.async {
                        self.images.append(img!)
                        self.loadImage(index: self.i)
                    }
                }
            }) as URLSessionTask
            dataTask.resume()
        }
    }
    @IBAction func changeImage(_ sender: Any) {
        i = (i + 1) % images.count
        loadImage(index: i)
    }
    
    func loadImage(index:Int)
    {
        if (index < images.count){
            imageview.image = images[index]
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension String {
    mutating func filterHTML() -> String?{
        var scanner = Scanner(string: self)
        var text: NSString?
        while !scanner.isAtEnd {
            scanner.scanUpTo("<", into: nil)
            scanner.scanUpTo(">", into: &text)
            self = self.replacingOccurrences(of: "\(text == nil ? "" : text!)>", with: "")
        }
        scanner = Scanner(string: self)
        while !scanner.isAtEnd {
            scanner.scanUpTo("&", into: nil)
            scanner.scanUpTo(";", into: &text)
            self = self.replacingOccurrences(of: "\(text == nil ? "" : text!);", with: "")
        }
        return self
    }
}

