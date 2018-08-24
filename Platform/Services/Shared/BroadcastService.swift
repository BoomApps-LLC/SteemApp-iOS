//
//  BroadcastService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/7/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import WebKit
import CryptoSwift
import Photos

enum SteemitBroadcastServiceError: Error {
    case noHash
    case fileNotExists
    case invalidWif
    case evaluteJs
    case noConnection
    case badUrl
    case cantBeParsed
}

public protocol UploadService {
    func take(assets: [String: String], completion: @escaping (Result<[ImageAsset]>) -> ())
    func sign(assets: [ImageAsset], wif: String, completion: @escaping (Result<[SignedData]>) -> ())
    func upload(items: [SignedData], username: String, completion: @escaping (Result<[SignedLinks]>) -> ())
}

public protocol BroadcastService {
    func broadcastSend(wif: String, comment: BroadcastComment, options: BroadcastCommentOptions?,
                       vote: BroadcastVote?, completion: @escaping (Result<Bool>) -> ())
    func broadcastVote(wif: String, vote: BroadcastVote, completion: @escaping (Result<Bool>) -> ())
}

public protocol AuthService {
    func validate(wif: String, completion: @escaping (Result<Bool>) -> ())
    func validate(wif: String, username: String, completion: @escaping (Result<Bool>) -> ())
}

public class SteemitBroadcastService: NSObject {
    private let configuration = WKWebViewConfiguration()
    private var webView: WKWebView?
    private var futures: [String: Any] = [:]
    
    init(webViewConatiner: UIView, navigationDelegate: WKNavigationDelegate? = nil) {
        super.init()
        
        if let htmlPath = Bundle.main.path(forResource: Config.API.Broadcast.rpcHandlerFilename, ofType: "html") {
            do {
                self.webView = WKWebView(frame: .zero, configuration: configuration)
                webViewConatiner.addSubview(webView!)
                
                // Loading index page
                let htmlSourceContents = try String(contentsOfFile: htmlPath)
                webView?.loadHTMLString(htmlSourceContents, baseURL: Bundle.main.bundleURL)
                
                let weakScriptMessageHandler = WeakScriptMessageHandler(delegate: self)
                webView?.configuration.userContentController.add(weakScriptMessageHandler, name: "generalChain")
            }
            catch {
                print(error.localizedDescription)
            }
        } else {
            fatalError("No file with html-template")
        }
    }
}

extension SteemitBroadcastService: UploadService {
    public func upload(items: [SignedData], username: String, completion: @escaping (Result<[SignedLinks]>) -> ()) {
        
        var result: Result<[SignedLinks]>!
        var signedLinks: [SignedLinks] = []
        let dispatchGroup = DispatchGroup()
        
        
        items.forEach { signedData in
            if result != nil {
                return
            }
            
            let urlstr = "https://steemitimages.com/\(username)/\(signedData.hash)"
            let url = URL(string: urlstr)!
            let boundary = "----WebKitFormBoundary\(UUID().uuidString)"
            var request = URLRequest(url: url)

            request.httpMethod = "POST"
            request.setValue("*/*", forHTTPHeaderField: "accept")
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            //request.setValue("https://steemit.com/submit.html", forHTTPHeaderField: "referer")
            request.setValue("POST", forHTTPHeaderField: "access-control-request-method")
            request.setValue("https://steemit.com", forHTTPHeaderField: "origin")

            var body = Data();
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(URL(fileURLWithPath: signedData.path).lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            body.append(signedData.imageData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            request.httpBody = body

            dispatchGroup.enter()
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if data != nil {
                    do {
                        let decoder = JSONDecoder()
                        let uploadedImageRaw = try decoder.decode(UploadedImageRaw.self, from: data!)
                        let link = uploadedImageRaw.url
                        let signedLink = SignedLinks(path: signedData.path, link: link)
                        signedLinks.append(signedLink)
                    } catch {
                        result = Result<[SignedLinks]>.error(SteemitBroadcastServiceError.cantBeParsed)
                    }
                } else {
                    result = Result<[SignedLinks]>.error(SteemitBroadcastServiceError.badUrl)
                }

                dispatchGroup.leave()
            }).resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            if result == nil {
                result = Result<[SignedLinks]>.success(signedLinks)
            }
            
            completion(result)
        }
    }
    
    public func take(assets: [String : String], completion: @escaping (Result<[ImageAsset]>) -> ()) {
        let dispatchGroup = DispatchGroup()
        var result: Result<[ImageAsset]>!
        var resassets = [ImageAsset]()
        let options = PHImageRequestOptions()
        options.version = .original
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = assets.count
        
        let values = Array(assets.values)
        let fetchedResult = PHAsset.fetchAssets(withLocalIdentifiers: values, options: fetchOptions)
        
        fetchedResult.enumerateObjects { (asset, idx, _) in
            guard let path = assets.first(where: { $1 == asset.localIdentifier })?.key else {
                result = Result<[ImageAsset]>.error(SteemitBroadcastServiceError.fileNotExists)
                return
            }
            
            // If was error - return
            if result != nil {
                return
            }
            
            dispatchGroup.enter()
            
            PHImageManager.default()
                .requestImageData(for: asset, options: options) { (imgData, uti, orientation, info) in
                    
                    if let imgData = imgData {
//                        var uploadData = Data()
//                        uploadData.append("ImageSigningChallenge".data(using: .utf8)!)
//                        uploadData.append(imgData)
                        
                        let imageAsset = ImageAsset(path: path, asset: asset, imageData: imgData)
                        resassets.append(imageAsset)
                        dispatchGroup.leave()
                    } else {
                        result = Result<[ImageAsset]>.error(SteemitBroadcastServiceError.fileNotExists)
                        dispatchGroup.leave()
                        return
                    }
                    
            }
        
                
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            if result == nil {
                result = Result<[ImageAsset]>.success(resassets)
            }
            completion(result)
        }
    }
    
    public func sign(assets: [ImageAsset], wif: String, completion: @escaping (Result<[SignedData]>) -> ()) {
        let dispatchGroup = DispatchGroup()
        var result: Result<[SignedData]>!
        var resassets = [SignedData]()
        
        assets.forEach { (imageAsset) in
            // If was error - return
            if result != nil {
                return
            }
            
            var uploadData = Data()
            uploadData.append("ImageSigningChallenge".data(using: .utf8)!)
            uploadData.append(imageAsset.imageData)
            
            let hash = uploadData.bytes.sha256().toHexString()
            dispatchGroup.enter()
            self.webView?.evaluateJavaScript("steemApi.sign(\'\(hash)',\'\(wif)');", completionHandler: { (obj, error) in
                if let hash = obj as? String {
                    let signedAsset = SignedData(path: imageAsset.path, hash: hash,
                                                 imageData: imageAsset.imageData)
                    resassets.append(signedAsset)
                    dispatchGroup.leave()
                } else {
                    result = Result<[SignedData]>.error(SteemitBroadcastServiceError.noHash)
                    dispatchGroup.leave()
                }
            })
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            if result == nil {
                result = Result<[SignedData]>.success(resassets)
            }
            completion(result)
        }
    }
}

extension SteemitBroadcastService: AuthService {
    public func validate(wif: String, username: String, completion: @escaping (Result<Bool>) -> ()) {
        let key = UUID().uuidString
        futures[key] = completion
        
        // Async calling
        let script = "steemApi.validatePaar('\(key)','\(wif)','\(username)');"
        webView?.evaluateJavaScript(script, completionHandler: { (validQ, err) in
            if err != nil {
                self.futures.removeValue(forKey: key)
                let res = Result<Bool>.error(SteemitBroadcastServiceError.evaluteJs)
                completion(res)
            }
        })
    }
    
    public func validate(wif: String, completion: @escaping (Result<Bool>) -> ()) {
        let script = "steemApi.validateWif('\(wif)');"
        webView?.evaluateJavaScript(script, completionHandler: { (validQ, err) in
            if let validQ = validQ as? Bool {
                let res = Result<Bool>.success(validQ)
                completion(res)
            } else  {
                let res = Result<Bool>.error(SteemitBroadcastServiceError.invalidWif)
                completion(res)
            }
        })
    }
}

extension SteemitBroadcastService: BroadcastService {
    public func broadcastVote(wif: String, vote: BroadcastVote, completion: @escaping (Result<Bool>) -> ()) {
        if ApplicationReachabilitySvc.internetConnectedQ {
            let author = vote.author
            let permlink = vote.permlink
            let voter = vote.voter
            let weight = vote.weight
            
            let key = UUID().uuidString
            futures[key] = completion
            
            // Async calling
            let script = "steemApi.broadcastVote(\'\(key)',\'\(wif.forJs)', '\(voter.forJs)', '\(author.forJs)', '\(permlink.forJs)', \(weight));"
            
            webView?.evaluateJavaScript(script, completionHandler: { (_, err) in
                if err != nil {
                    self.futures.removeValue(forKey: key)
                    let res = Result<Bool>.error(SteemitBroadcastServiceError.evaluteJs)
                    completion(res)
                }
            })
        } else {
            let res = Result<Bool>.error(SteemitBroadcastServiceError.noConnection)
            completion(res)
        }
    }
    
    public func broadcastSend(wif: String, comment: BroadcastComment, options: BroadcastCommentOptions?,
                              vote: BroadcastVote?, completion: @escaping (Result<Bool>) -> ()) {
        if ApplicationReachabilitySvc.internetConnectedQ {
            let optionsQ = (options != nil)
            let voteQ = (vote != nil)
            
            let author = comment.author
            let permlink = comment.permlink
            let title = comment.title
            let body = comment.body
            let json_metadata = comment.json_metadata
            let max_accepted_payout = options?.max_accepted_payout ?? "0.000 SBD"
            let percent_steem_dollars = options?.percent_steem_dollars ?? 0
            let parent_permlink = comment.parent_permlink
            
            let key = UUID().uuidString
            futures[key] = completion
            
            // Async calling
            let script = "steemApi.broadcastSend(\'\(key)',\'\(wif.forJs)', \(optionsQ), \(voteQ), '\(parent_permlink)', '\(author.forJs)', '\(permlink.forJs)', '\(title.forJs)', '\(body.forJs)', '\(json_metadata.forJs)', '\(max_accepted_payout.forJs)', \(percent_steem_dollars));"
            
            webView?.evaluateJavaScript(script, completionHandler: { (_, err) in
                if err != nil {
                    self.futures.removeValue(forKey: key)
                    let res = Result<Bool>.error(SteemitBroadcastServiceError.evaluteJs)
                    completion(res)
                }
            })
        } else {
            let res = Result<Bool>.error(SteemitBroadcastServiceError.noConnection)
            completion(res)
        }
        
    }
}

private class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

extension SteemitBroadcastService: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let msg = message.body as? [String: Bool] {
            resolve(msg: msg)
        } else if let msg = message.body as? [String: String] {
            resolve(msg: msg)
        } else if let msg = message.body as? [String: Void] {
            resolve(msg: msg)
        } else if let msg = message.body as? [String: Any] {
            resolve(msg: msg)
        } else if let msg = message.body as? String {
            print(msg)
        } else {
            fatalError("Fail calling closure")
        }
        
    }
    
    private func resolve<T>(msg: [String: T]) {
        msg.forEach({ (key, value) in
            if let closure = futures[key] as? (Result<T>) -> () {
                let result = Result<T>.success(value)
                closure(result)
            }
            
            futures.removeValue(forKey: key)
        })
    }
}
