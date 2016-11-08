//
//  WebViewController.swift
//  Trucky
//
//  Created by Kyle on 9/16/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var businessURL:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        loadRequestWithString()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false

    }
    
    func loadRequestWithString() {
        let url = URL(string: businessURL)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    
    @IBAction func backAction(_ sender: AnyObject) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func forwardAction(_ sender: AnyObject) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func refreshAction(_ sender: AnyObject) {
        webView.reload()
    }
    
    @IBAction func stopAction(_ sender: AnyObject) {
        webView.stopLoading()
    }
    
}
