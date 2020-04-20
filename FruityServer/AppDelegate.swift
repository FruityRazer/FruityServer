//
//  AppDelegate.swift
//  FruityServer
//
//  Created by Eduardo Almeida on 20/04/2020.
//  Copyright © 2020 Eduardo Almeida. All rights reserved.
//

import Criollo
import FruityKit

protocol HTTPErrorResponseConvertible {
    var httpResponseErrorValue: String { get }
}

extension String: HTTPErrorResponseConvertible {
    var httpResponseErrorValue: String {
        return self
    }
}

class AppDelegate: NSObject, CRApplicationDelegate, CRServerDelegate {
    
    enum RequestError: Error, HTTPErrorResponseConvertible {
        case invalidData
        case malformedRequest
        case modeNotImplemented
        
        var httpResponseErrorValue: String {
            switch self {
            case .invalidData:
                return "INVALID_DATA"
            case .malformedRequest:
                return "MALFORMED_REQUEST"
            case .modeNotImplemented:
                return "MODE_NOT_IMPLEMENTED"
            }
        }
    }
    
    var server: CRServer!
    var key: String?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.server = CRHTTPServer(delegate: self)
        
        setRoutes()
        
        self.server.startListening(nil, portNumber: 24577)
    }
    
    func createErrorResponse(with error: HTTPErrorResponseConvertible?) -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "success": false,
            "error": error?.httpResponseErrorValue ?? "UNKNOWN"
        ], options: .prettyPrinted)
    }
    
    lazy var successResponse: Data = {
        try! JSONSerialization.data(withJSONObject: [
            "success": true
        ], options: .prettyPrinted)
    }()
    
    func checkAuthorization(request: CRRequest, response: CRResponse) -> Bool {
        guard let key = key else {
            return true
        }
        
        let receivedKey = request.allHTTPHeaderFields["X-FruityRazer-Key"]
        
        guard key == receivedKey else {
            response.send(createErrorResponse(with: "UNAUTHORIZED"))
            
            return false
        }
        
        return true
    }
    
    func handleWrite(with handle: Synapse2Handle, request: CRRequest) throws {
        guard let body = request.body as? [String: Any], let type = body["type"] as? String else {
            throw RequestError.malformedRequest
        }
        
        switch type {
        case "wave":
            let direction: Direction
            
            if let directionStr = body["direction"] as? String {
                direction = directionStr == "right" ? .right : .left
            } else {
                direction = .right
            }
            
            handle.write(mode: .wave(direction: direction))
            
        case "spectrum":
            handle.write(mode: .spectrum)
            
        case "reactive":
            guard let speedStr = body["speed"] as? String, let speed = Int(speedStr) else {
                throw RequestError.invalidData
            }
            
            guard let colorStr = body["color"] as? String, let color = try? Color(hex: colorStr) else {
                throw RequestError.invalidData
            }
            
            handle.write(mode: .reactive(speed: speed, color: color))
            
        case "static":
            guard let colorStr = body["color"] as? String, let color = try? Color(hex: colorStr) else {
                throw RequestError.invalidData
            }
            
            handle.write(mode: .static(color: color))
            
        case "breath":
            guard let colorStr = body["color"] as? String, let color = try? Color(hex: colorStr) else {
                throw RequestError.invalidData
            }
            
            handle.write(mode: .breath(color: color))
            
        case "brightness":
            throw RequestError.modeNotImplemented
            
        default:
            throw RequestError.invalidData
        }
    }
    
    func handleWrite(with handle: Synapse3Handle, request: CRRequest) throws {
        guard let body = request.body as? [String: Any], let type = body["type"] as? String else {
            throw RequestError.malformedRequest
        }
        
        guard type == "raw" else {
            throw RequestError.invalidData
        }
        
        do {
            if let parts = body["parts"] as? [String] {
                let colors = try parts.map { try Color(hex: $0) }
                
                handle.write(mode: .raw(colors: colors))
            } else if let rows = body["rows"] as? [[String]] {
                let colors = try rows.map { try $0.map { try Color(hex: $0) } }
                
                handle.write(mode: .rawRows(colors: colors))
            }
        } catch {
            throw RequestError.invalidData
        }
    }
    
    func setRoutes() {
        self.server.add { request, response, completionHandler in
            defer {
                completionHandler()
            }
            
            response.setValue(Bundle.main.bundleIdentifier!, forHTTPHeaderField: "Server")
            response.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let origin = request.allHTTPHeaderFields["Origin"], let acrh = request.allHTTPHeaderFields["Access-Control-Request-Headers"] {
                response.setValue(origin, forHTTPHeaderField: "Access-Control-Allow-Origin")
                response.setValue("GET, POST, PUT, HEAD", forHTTPHeaderField: "Access-Control-Allow-Methods")
                response.setValue(acrh, forHTTPHeaderField: "Access-Control-Allow-Headers")
            }
        }
        
        self.server.options(nil) { request, response, completionHandler in
            defer {
                completionHandler()
            }
            
            response.send("")
        }
        
        self.server.get("/devices") { request, response, completionHandler in
            defer {
                completionHandler()
            }
            
            guard self.checkAuthorization(request: request, response: response) else {
                return
            }
            
            let deviceMap = FruityRazer.devices.map {
                [
                    "shortName": $0.shortName,
                    "fullName": $0.fullName,
                    "connected": $0.connected
                ]
            }
            
            if let json = try? JSONSerialization.data(withJSONObject: deviceMap, options: .prettyPrinted) {
                response.send(json)
            } else {
                response.send(self.createErrorResponse(with: nil))
            }
        }
        
        self.server.get("/devices/:shortName/lighting") { request, response, completionHandler in
            defer {
                completionHandler()
            }
            
            guard self.checkAuthorization(request: request, response: response) else {
                return
            }
        }
        
        self.server.post("/devices/:shortName/lighting") { request, response, completionHandler in
            defer {
                completionHandler()
            }
            
            guard self.checkAuthorization(request: request, response: response) else {
                return
            }
            
            let shortName = request.query["shortName"]
            
            guard let device = FruityRazer.connectedDevices.first(where: { $0.shortName == shortName }) else {
                response.send(self.createErrorResponse(with: "NOT_CONNECTED"))
                
                return
            }
            
            do {
                switch device.driver {
                case .v2(driver: let d):
                    try self.handleWrite(with: d, request: request)
                case .v3(driver: let d):
                    try self.handleWrite(with: d, request: request)
                }
            } catch let error as RequestError {
                response.send(self.createErrorResponse(with: error))
                
                return
            } catch {
                response.send(self.createErrorResponse(with: nil))
                
                return
            }
            
            response.send(self.successResponse)
        }
        
        self.server.get("/key") { request, response, completionHandler in
            defer {
                completionHandler()
            }
            
            guard self.key == nil else {
                response.send(try! JSONSerialization.data(withJSONObject: [
                    "success": false
                ], options: .prettyPrinted))
                
                return
            }
            
            self.key = ProcessInfo.processInfo.globallyUniqueString
            
            response.send(try! JSONSerialization.data(withJSONObject: [
                "success": true,
                "key": self.key!
            ], options: .prettyPrinted))
        }
        
        self.server.get("/") { request, response, completionHandler in
            defer {
                completionHandler()
            }
            
            response.send(try! JSONSerialization.data(withJSONObject: [
                "app": "FruityServer",
                "version": Bundle.main.infoDictionary!["CFBundleVersion"]
            ], options: .prettyPrinted))
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}
