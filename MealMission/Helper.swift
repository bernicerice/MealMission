
import Foundation
import UIKit
import WebKit

class Helper: UIViewController, WKNavigationDelegate, WKUIDelegate {
    var wkView: WKWebView!
    var url: String
    var isRedirecting = false
    
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: self.url), url.absoluteString.contains("bot") {
            print("Initial URL doesn't contain 'bot', opening app directly")

            let viewController = MainMeal()
            DispatchQueue.main.async {
                viewController.firstOpen()
            }
            
            return
        }
        
        self.view.backgroundColor = UIColor(named: "color")
        
        let topBackgroundView = UIView()
            topBackgroundView.backgroundColor = UIColor(named: "color")
            topBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(topBackgroundView)
            
            let bottomBackgroundView = UIView()
            bottomBackgroundView.backgroundColor = UIColor(named: "color")
            bottomBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomBackgroundView)
        
        NSLayoutConstraint.activate([
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            topBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            bottomBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.wkView = self.setupWeb(frame: self.view.bounds, configuration: nil)
        self.view.addSubview(self.wkView)
        
        self.wkView.alpha = 0
        self.view.alpha = 0
        
        self.prepConstrs()
        
        if let url = URL(string: self.url) {
            let request = URLRequest(url: url)
            self.wkView.load(request)
        }
        
        self.makeWindow()
        Orientation.orientation = .all
    }

    func setupWeb(frame: CGRect, configuration: WKWebViewConfiguration?) -> WKWebView {
        let configuration = configuration ?? WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: frame, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsLinkPreview = false
        webView.scrollView.bounces = false
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }
    
    func prepConstrs() {
        NSLayoutConstraint.activate([
            self.wkView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.wkView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.wkView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.wkView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    func makeWindow() {
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow
            let field = UITextField()
            field.isSecureTextEntry = true
            window?.addSubview(field)
            window?.layer.superlayer?.addSublayer(field.layer)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if !["http", "https"].contains(url.scheme ?? "") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        
        if UserDefaults.standard.string(forKey: "finalURL") == nil {
            print("Redirected to: \(url.absoluteString)")
            isRedirecting = true
        }
        
        if url.absoluteString.contains("bot") {
            print("Redirect contains 'bot', open app")
            DispatchQueue.main.async { [weak self] in
                self?.dismiss(animated: false, completion: {
                    let viewController = MainMeal()
                    viewController.firstOpen()
                })
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if #available(iOS 15.0, *) {
            self.view.backgroundColor = self.wkView.underPageBackgroundColor
            if let finalURL = webView.url {
                print("Final URL after all redirects: \(finalURL.absoluteString)")
                self.isRedirecting = false
                if UserDefaults.standard.string(forKey: "finalURL") == nil {
                    UserDefaults.standard.set(finalURL.absoluteString, forKey: "finalURL")
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                 if !self.isRedirecting {
                     self.view.alpha = 1
                     self.wkView.alpha = 1
                     print("WebView fully loaded with final URL.")
                 }
             }
        }
    }
    
    func getCurrentUserAgent() async -> String? {
        let webView = WKWebView(frame: .zero)
        return await withCheckedContinuation { continuation in
            webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
                if let userAgent = result as? String {
                    continuation.resume(returning: userAgent)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || !navigationAction.targetFrame!.isMainFrame {
            let topInset: CGFloat = 44
            let containerView = UIView(frame: self.view.frame)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = UIColor.black
            
            self.view.addSubview(containerView)
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
            
            var webViewFrame = self.view.safeAreaLayoutGuide.layoutFrame
            webViewFrame.size.height -= topInset
            webViewFrame.origin.y += topInset
            
            let targetView = self.setupWeb(frame: webViewFrame, configuration: configuration)
            targetView.translatesAutoresizingMaskIntoConstraints = false
            if let url = navigationAction.request.url {
                targetView.load(URLRequest(url: url))
            }
            targetView.uiDelegate = self
            
            containerView.addSubview(targetView)
            
            let closeButton = UIButton(type: .system)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.tintColor = UIColor.white
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
            containerView.addSubview(closeButton)
            
            NSLayoutConstraint.activate([
                closeButton.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -15),
                closeButton.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 22),
                targetView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: topInset),
                targetView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
                targetView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
                targetView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor)
            ])
            
            containerView.alpha = 0.0
            UIView.animate(withDuration: 0.2) {
                containerView.alpha = 1.0
            }
            
            return targetView
        }
        return nil
    }
    
    @objc func closeButtonTapped(_ sender: UIButton) {
        if let view = sender.superview {
            UIView.animate(withDuration: 0.2) {
                view.alpha = 0.0
            } completion: { _ in
                view.removeFromSuperview()
            }
        }
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if let view = webView.superview {
            UIView.animate(withDuration: 0.2) {
                view.alpha = 0.0
            } completion: { _ in
                view.removeFromSuperview()
            }
        }
    }
}

private extension String {
    
    private var kUIInterfaceOrientationPortrait: String {
        return "UIInterfaceOrientationPortrait"
    }
    
    private var kUIInterfaceOrientationLandscapeLeft: String {
        return "UIInterfaceOrientationLandscapeLeft"
    }
    
    private var kUIInterfaceOrientationLandscapeRight: String {
        return "UIInterfaceOrientationLandscapeRight"
    }
    
    private var kUIInterfaceOrientationPortraitUpsideDown: String {
        return "UIInterfaceOrientationPortraitUpsideDown"
    }
    
    var deviceOrientation: UIInterfaceOrientationMask {
        switch self {
        case kUIInterfaceOrientationPortrait:
            return .portrait
            
        case kUIInterfaceOrientationLandscapeLeft:
            return .landscapeLeft
            
        case kUIInterfaceOrientationLandscapeRight:
            return .landscapeRight
            
        case kUIInterfaceOrientationPortraitUpsideDown:
            return .portraitUpsideDown
            
        default:
            return .all
        }
    }
}

class Orientation {
    private static var preferredOrientation: UIInterfaceOrientationMask {
        guard let maskStringsArray = Bundle.main.object(forInfoDictionaryKey: "UISupportedInterfaceOrientations") as? [String] else {
            return .all
        }
        
        let masksArray = maskStringsArray.compactMap { $0.deviceOrientation }
        
        return UIInterfaceOrientationMask(masksArray)
    }
    
    fileprivate(set) public static var orientation: UIInterfaceOrientationMask = preferredOrientation
}
