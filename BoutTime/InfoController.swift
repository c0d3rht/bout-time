import UIKit
import WebKit

class InfoController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var eventURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = eventURL {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
