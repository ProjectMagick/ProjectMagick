//
//  WebSocketManager.swift
//  ProjectMagick
//
//  Created by Kishan on 19/08/21.
//  Copyright © 2021 Kishan. All rights reserved.
//

import Foundation

protocol WebSocketDelegate : AnyObject {
    func connectionOpened(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?)
    func connectionClosed(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func responseString(string : String)
    func responseData(data : Data)
}

extension WebSocketDelegate {
    
    func connectionOpened(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        
    }
    
    func connectionClosed(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
    }
    
}

class WebSocketManager : NSObject {
    
    weak var delegate : WebSocketDelegate?
    var webSocketConnection : URLSessionWebSocketTask!
    
    override init() {
        
    }
    
    deinit {
        disConnect()
    }
    
    convenience init(connectTo : URL) {
        self.init()
        connectWebSocket(url: connectTo)
        addListenerForWebSocket()
        perform(#selector(sendPing), with: nil, afterDelay: 5)
    }
    
    private func connectWebSocket(url : URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketConnection = session.webSocketTask(with: url)
        webSocketConnection.resume()
    }
    
    private func addListenerForWebSocket() {
        webSocketConnection.receive { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let socketResponse):
                switch socketResponse {
                case .data(let data):
                    self.delegate?.responseData(data: data)
                case .string(let string):
//                    print("In String ----->",string)
                    self.delegate?.responseString(string: string)
                default:
                    break
                }
            case .failure(let error):
                print(error)
            }
            self.addListenerForWebSocket()
        }
    }
    
    func disConnect() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        webSocketConnection.cancel(with: .goingAway, reason: nil)
        webSocketConnection = nil
        delegate = nil
    }
    
    func sendDataMessage(object : Codable) {
        if let data = object.toData() {
            webSocketConnection.send(.data(data)) { err in
                if let error = err {
                    print("Data Send failed: \(error)")
                }
            }
        }
    }
    
    @objc func sendPing() {
        webSocketConnection.sendPing { [weak self] (error) in
            guard let _ = self else { return }
            if let error = error {
                print("Ping failed: \(error)")
            } else {
                print("Ping Sent")
            }
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(sendPing), with: nil, afterDelay: 10)
    }
}

extension WebSocketManager : URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        delegate?.connectionOpened(session, webSocketTask: webSocketTask, didOpenWithProtocol: `protocol`)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        delegate?.connectionClosed(session, webSocketTask: webSocketTask, didCloseWith: closeCode, reason: reason)
    }
    
}
