//
//  LocationManager.swift
//  LocationManager
//
//  Created by Kishan on 23/02/21.
//

import Foundation
import Combine
import CoreLocation
import MapKit

public enum AccuracyLevel : Double {
    case bestForNavigation
    case best
    case nearest10meters
    case HunderdMeters
    case kilometer
    case threeKilometer
    /** Available from iOS 14 only*/
    case accuracyReduce
}

public enum LocationRequestType {
    case always
    case whenInUse
    /** Available from iOS 14 only*/
    case temporaryFullAccess(Key : String)
}

public enum LocationManagerConfiguration {
    case `default`, custom(LocationManagerConfig)
}

public struct LocationManagerConfig {
    public var accuracyLevel : AccuracyLevel = .nearest10meters
    public var locationRequestType : LocationRequestType = .whenInUse
    public var updateEveryXSeconds = 2
    public var allowBackgroundUpdates = true
    public var startAutomatically = true
    public var pauseAutomatically = true
    public var activityType : CLActivityType = .automotiveNavigation
    public var distanceFilter : Double = 0
}

protocol LocationManagerCombineDelegate: CLLocationManagerDelegate {
    
    func authorizationPublisher() -> AnyPublisher<CLAuthorizationStatus, Never>
    func locationPublisher() -> AnyPublisher<[CLLocation], Never>
    func accuracyAuthPublisher() -> AnyPublisher<CLAccuracyAuthorization,Never>
    
}

public class LocationModel : ObservableObject {
    
    fileprivate var authStatus : CLAuthorizationStatus = .notDetermined
    fileprivate var accuracyAuthStatus : CLAccuracyAuthorization = .fullAccuracy
    
    public var currentLocation = CLLocation()
    public var isAuthorized : Bool {
        authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse
    }
    public var latitude : Double {
        currentLocation.coordinate.latitude
    }
    public var longitude : Double {
        currentLocation.coordinate.longitude
    }
    public var timeStamp : Date {
        currentLocation.timestamp
    }
    
    @available(iOS 14.0, *)
    public var isFullyAccurate : Bool {
        accuracyAuthStatus == .fullAccuracy
    }
}

open class LocationManager {
    
    private var choosenAccuracy : Double {
        switch configOptions.accuracyLevel {
        case .bestForNavigation:
            return kCLLocationAccuracyBestForNavigation
        case .best:
            return kCLLocationAccuracyBest
        case .HunderdMeters:
            return kCLLocationAccuracyHundredMeters
        case .kilometer:
            return kCLLocationAccuracyKilometer
        case .threeKilometer:
            return kCLLocationAccuracyThreeKilometers
        case .accuracyReduce:
            if #available(iOS 14.0, *) {
                return kCLLocationAccuracyReduced
            } else {
                fatalError("Available from iOS 14 only")
            }
        default:
            return kCLLocationAccuracyNearestTenMeters
        }
    }
    fileprivate var configOptions = LocationManagerConfig()
    fileprivate lazy var manager : CLLocationManager = {
       let manager = CLLocationManager()
        manager.delegate = publisherObject
        manager.desiredAccuracy = choosenAccuracy
        manager.allowsBackgroundLocationUpdates = configOptions.allowBackgroundUpdates
        manager.pausesLocationUpdatesAutomatically = configOptions.pauseAutomatically
        manager.activityType = configOptions.activityType
        manager.distanceFilter = configOptions.distanceFilter
        print("In manager -------", configOptions)
        return manager
    }()
    fileprivate let publicistDelegate: LocationManagerCombineDelegate
    fileprivate var cancellables = [AnyCancellable]()
    fileprivate var publisherObject = CLLocationManagerPublicist()
    public var locationObject = LocationModel()
    
    
    // Convenience init method
    public convenience init(config : LocationManagerConfiguration) {
        self.init()
        switch config {
        case let .custom(object):
            configOptions = object
        default:
            break
        }
    }
    
    public init() {
        
        // Bind Values
        publicistDelegate = publisherObject
        
        publisherObject
            .authorizationPublisher()
            .receive(on: DispatchQueue.main)
            .print()
            .sink(receiveValue: {
                self.locationObject.authStatus = $0
                self.beginUpdates($0, requestType: self.configOptions.locationRequestType)
            }).store(in: &cancellables)
        
        
        publisherObject
            .accuracyAuthPublisher()
            .receive(on: DispatchQueue.main)
            .print()
            .sink { (status) in
                self.locationObject.accuracyAuthStatus = status
            }.store(in: &cancellables)
        
        
        publisherObject
            .locationPublisher()
            .flatMap(Publishers.Sequence.init(sequence:))
            .compactMap { $0 as CLLocation }
            .throttle(for: .seconds(configOptions.updateEveryXSeconds), scheduler: DispatchQueue.main, latest: true)
            .print()
            .receive(on: DispatchQueue.main)
            .sink { (location) in
                self.locationObject.currentLocation = location
            }.store(in: &cancellables)
        
        
    }
    
    func beginUpdates(_ authorizationStatus: CLAuthorizationStatus, requestType : LocationRequestType) {
        if CLLocationManager.locationServicesEnabled() {
            switch authorizationStatus {
            case .notDetermined:
                requestAuthorization(requestType: requestType)
            case .denied, .restricted:
                break
            case .authorizedAlways, .authorizedWhenInUse:
                if configOptions.startAutomatically {
                    startUpdates()
                }                
            default:
                break
            }
        }
    }
    
    public func requestAuthorization(requestType : LocationRequestType) {
        switch requestType {
        case .whenInUse:
            manager.requestWhenInUseAuthorization()
        case .always:
            manager.requestAlwaysAuthorization()
        case let .temporaryFullAccess(key):
            if #available(iOS 14.0, *) {
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: key)
            }
        }
    }
    
    
    public func startUpdates() {
        manager.startUpdatingLocation()
    }
    
    public func stopUpdates() {
        manager.stopUpdatingLocation()
    }
    
}


extension CLAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .authorizedAlways:
            return "Always Authorized"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        @unknown default:
            return "🤷‍♂️"
        }
    }
}


class CLLocationManagerPublicist: NSObject, LocationManagerCombineDelegate {
    
    let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    let locationSubject = PassthroughSubject<[CLLocation], Never>()
    let accuracyAuthSubject = PassthroughSubject<CLAccuracyAuthorization,Never>()

    
    func authorizationPublisher() -> AnyPublisher<CLAuthorizationStatus, Never> {
        return Just(CLLocationManager.authorizationStatus())
            .merge(with: authorizationSubject.compactMap { $0 })
            .eraseToAnyPublisher()
    }
    
    func locationPublisher() -> AnyPublisher<[CLLocation], Never> {
        return locationSubject.eraseToAnyPublisher()
    }
    
    func accuracyAuthPublisher() -> AnyPublisher<CLAccuracyAuthorization, Never> {
        accuracyAuthSubject.eraseToAnyPublisher()
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSubject.send(locations)
    }
    
    func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        
    }
    
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationSubject.send(status)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            accuracyAuthSubject.send(manager.accuracyAuthorization)
        }
    }
}

