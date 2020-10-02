//
//  LGWebViewDelegate.swift
//
//
//  Created by Murilo Araujo on 02/10/20.
//

import UIKit
import WebKit

@objc
public class LGWebView: WKWebView{
    let id: String
    
    @objc
    required init(id: String = "sharedWebView") {
        let configuration = WKWebViewConfiguration()
        self.id = id
        configuration.processPool = LGPoolService.shared.getPool(for: id)
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        super.init(frame: .zero, configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public func persistInstance() {
        LGPoolService.shared.save(pool: self.configuration.processPool, for: id)
        self.configuration.websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
            LGCookieService.shared.saveLoginCookies(cookies, for: self.id)
        }
    }
    
    @objc
    public override func load(_ request: URLRequest) -> WKNavigation? {
        let cookies = LGCookieService.shared.getSavedLoginCookies(for: id)
        
        if (cookies.count > 0){
            let cookieStore = self.configuration.websiteDataStore.httpCookieStore
            
            for cookie in cookies {
                cookieStore.setCookie(cookie)
            }
            
            DispatchQueue.main.async {
                super.load(request)
            }
            return nil
        }else{
            return super.load(request)
        }
    }
    
    @objc
    public static func clearPersistence(for id: String = "sharedWebView") {
        LGPoolService.shared.clearPoolData(for: id)
        LGCookieService.shared.clearLoginCookies(for: id)
    }
}
