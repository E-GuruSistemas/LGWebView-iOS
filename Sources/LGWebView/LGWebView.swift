//
//  LGWebViewDelegate.swift
//
//
//  Created by Murilo Araujo on 02/10/20.
//

import Foundation
import UIKit
import WebKit

@objc
public class LGWebView: WKWebView{
    let id: String
    var injectedCookies: [HTTPCookie] = []
    @objc
    required init(with id: String = "sharedWebView") {
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
            let cookiesForPersistence = cookies.filter { (httpCookie) -> Bool in
                for injectedCookie in self.injectedCookies {
                    if injectedCookie.name == httpCookie.name,
                       injectedCookie.domain == httpCookie.domain {
                        return false
                    }
                }
                return true
            }
            LGCookieService.shared.saveLoginCookies(cookiesForPersistence, for: self.id)
        }
    }
    
    @objc
    public func loadRequest(_ request: URLRequest, with injectedCookies: [HTTPCookie] = []) -> WKNavigation? {
        var cookies = LGCookieService.shared.getSavedLoginCookies(for: id)
        cookies += injectedCookies
        self.injectedCookies = injectedCookies
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
