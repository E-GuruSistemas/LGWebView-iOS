//
//  File.swift
//  
//
//  Created by Murilo Araujo on 02/10/20.
//

import Foundation
import Disk

internal struct CookieDTO: Codable {
    var version: String
    var name: String
    var value: String
    var expire: Date?
    var created: String
    var sessionOnly: Bool
    var domain: String
    var partition: String
    var sameSite: String?
    var path: String
    var isSecure: Bool
    var isHttpOnly: Bool
}

internal class LGCookieService {
    static let shared = LGCookieService()
    
    private func cookiePath(for id: String) -> String {
        return "Cookies/\(id)"
    }
    
    internal func saveLoginCookies(_ cookies: [HTTPCookie], for id: String) {
        let cookiesDTO = cookieToObject(cookies)
        clearLoginCookies(for: id)
        try? Disk.save(cookiesDTO, to: .applicationSupport, as: cookiePath(for: id))
    }
    
    internal func getSavedLoginCookies(for id: String) -> [HTTPCookie] {
        var cookies = [HTTPCookie]()
        if let cookiedDTOS = try? Disk.retrieve(cookiePath(for: id), from: .applicationSupport, as: [CookieDTO].self) {
            cookies = objectToCookie(cookiedDTOS)
        }
        return cookies
    }
    
    public func clearLoginCookies(for id: String) {
        try? Disk.remove(cookiePath(for: id), from: .applicationSupport)
    }
    
    private func objectToCookie(_ objects: [CookieDTO]) -> [HTTPCookie] {
        var cookies = [HTTPCookie]()
        for cookieDTO in objects {
            if let cookie = HTTPCookie(properties: [
                .version: cookieDTO.version,
                .domain: cookieDTO.domain,
                .expires: cookieDTO.expire ?? "'(null)'",
                .name: cookieDTO.name,
                .value: cookieDTO.value,
                .secure: cookieDTO.isSecure,
                .path: cookieDTO.path,
                .originURL: cookieDTO.domain
            ]) {
                cookies.append(cookie)
            }
        }
        return cookies
    }
    
    private func cookieToObject(_ cookies: [HTTPCookie]) -> [CookieDTO] {
        var cookiesDTO = [CookieDTO]()
        for cookie in cookies {
            let cookieDTO = CookieDTO(
                version: "\(cookie.version)",
                name: cookie.name,
                value: cookie.value,
                expire: cookie.expiresDate,
                created: "\(Date().description)",
                sessionOnly: cookie.isSessionOnly,
                domain: cookie.domain,
                partition: "none",
                path: cookie.path,
                isSecure: cookie.isSecure,
                isHttpOnly: cookie.isHTTPOnly)
            cookiesDTO.append(cookieDTO)
        }
        return cookiesDTO
    }
}
