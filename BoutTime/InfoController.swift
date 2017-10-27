//
//  InfoController.swift
//  BoutTime
//

import UIKit
import WebKit

class InfoController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var url: URL? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
