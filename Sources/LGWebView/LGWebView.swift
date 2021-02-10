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
open class LGWebView: WKWebView{
    @objc let id: String
    @objc var injectedCookies: [HTTPCookie] = []
    
    
    /// Returns a WKWebview configured with a persistence key
    /// - Parameter id: The key used to track the persistence
    @objc
    required public init(id: String = "sharedWebView") {
        let configuration = WKWebViewConfiguration()
        self.id = id
        configuration.processPool = LGPoolService.shared.getPool(for: id)
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        super.init(frame: .zero, configuration: configuration)
    }
    
    required public convenience init?(coder: NSCoder) {
        self.init()
    }
    
    /// Saves the state of the WebView
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
    
    /// Loads request with optional cookie injection
    /// - Parameters:
    ///   - request: The url request for loading
    ///   - injectedCookies: Optional cookies for injection
    /// - Returns: WKNavigation
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
    
    /// Clears the persistence data
    /// - Parameter id: Optional identifier of the webview instance
    @objc
    
    public static func clearPersistence(for id: String = "sharedWebView") {
        LGPoolService.shared.clearPoolData(for: id)
        LGCookieService.shared.clearLoginCookies(for: id)
    }
}
