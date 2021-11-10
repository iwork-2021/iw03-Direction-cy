//
//  AboutViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/10.
//

import UIKit

class AboutViewController: UIViewController {
    var host:String = "https://itsc.nju.edu.cn"
    @IBOutlet weak var textview: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData(str: "/main.htm")
        // Do any additional setup after loading the view.
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
                                //print(string)
                                self.regGetSub(pattern: "服务电话</a>[\\s\\S]*?</ul>", str: string)
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
            substr.filterHTML()
            substr = substr.replacingOccurrences(of: "\t", with: "")
            substr = substr.replacingOccurrences(of: "\r", with: "")
            var content:String = ""
            let lines = substr.split(separator: "\n")
            for line in lines{
                content = content + line + "\n\n"
            }
            textview.text = content
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

