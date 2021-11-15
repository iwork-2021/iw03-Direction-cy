[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-f059dc9a6f8d3a56e377f745f24479a46679e63a5d9fe6f495e02850cd0d8118.svg)](https://classroom.github.com/online_ide?assignment_repo_id=6042793&assignment_repo_type=AssignmentRepo)
# iw03

请基于模板工程，为https://itsc.nju.edu.cn开发一个iOS客户端。

功能要求如下：

1. App界面设计见模板工程的Main Storyboard，首届面通过tab bar controller分为5个栏目
2. 前4个分别对应网站4个信息栏目（如下），下载list.htm内容并将新闻条目解析显示在Table View中
   - https://itsc.nju.edu.cn/xwdt/list.htm
   - https://itsc.nju.edu.cn/tzgg/list.htm
   - https://itsc.nju.edu.cn/wlyxqk/list.htm
   - https://itsc.nju.edu.cn/aqtg/list.htm
3. 点击table view中任意一个cell，获取该cell对应新闻的详细内容页面，解析内容并展示在内容详情场景中
4. 最后一个栏目显示 https://itsc.nju.edu.cn/main.htm 最后“关于我们”部分的信息

非功能需求如下：
1. 界面美观（通过自动化布局适配多种设备）
2. 性能良好（用GCD进行并发编程，网络通信应考虑缓冲已下载数据内容）


以新闻公告设计为例，其余设计类似

## NewsTableViewController

根据课件中给的代码段加以改编， 得到获取html的函数 func fetchData(str:String)

其中并发编程如下:

      DispatchQueue.main.async 
      {
         self.regGetSub(pattern: "class=\"news_title\"><a href=(.*)</a></span>(\\s*)<span class=\"news_meta\">(.*)</span>", str: string)
         //解析下一页
         self.fetchData(str: self.findNext(pattern: "<a class=\"next\" href=\"(.*)\" target=", str: string))
      }

## 设计了func regGetSub(pattern: String, str: String)，使用正则表达式解析html

      func regGetSub(pattern: String, str: String)
      {
         var substr:String = ""
         let regex = try! NSRegularExpression(pattern: pattern, options: [])
         let matches = regex.matches(in: str, options: [], range: NSRange(str.startIndex..., in:str))
         for match in matches {
            substr = (str as NSString).substring(with: match.range)
            
            ...

            items.append(Item(title: title, date: date, href: href))
            
         }
         self.tableView.reloadData()
      }

解析出每一条目的title，date，链接

## 设计了 func findNext(pattern: String, str: String) -> String， 使用正则表达式得到跳转下一页的链接

## 设计了Item 和 MyTableViewCell类，将其映射显示

## NewsViewController

其中并发编程如下:

      DispatchQueue.main.async 
      {
         //得到解析文字内容
         self.regGetSub(pattern: "<h1 class=\"arti_title\">[\\s\\S]*<br /></p></div></div>", str: string)
         //获取图片
         self.getImage(pattern: "<img data-layer=\"photo\" src=\"(.*?) original-src=\"", str: string)
      }

## 设计 func getImage(pattern: String, str: String) 来 获取图片

同样使用正则表达式来获取图片原链接，然后用并发的网络通信下载图片

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

## 切换显示图片的设计

点击一个透明的button获取响应

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

## 为方便解析html写的一个string的extension，去除html标签

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