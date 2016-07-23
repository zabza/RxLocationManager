//
//  MonitoringVisitsService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//
#if os(iOS)
    import Foundation
    import CoreLocation
    import RxSwift
    
    
    //MARK: MonitoringVisitsService
    public protocol MonitoringVisitsService{
        /// Observable of visit event
        var visiting: Observable<CLVisit>{get}
    }
    
    //MARK: DefaultMonitoringVisitsService
    class DefaultMonitoringVisitsService: MonitoringVisitsService{
        private let locMgr: LocationManagerBridge = Bridge()
        private var observers = [(id:Int, observer: AnyObserver<CLVisit>)]()
        
        var visiting: Observable<CLVisit>{
            get{
                return Observable.create{
                    observer in
                    var ownerService:DefaultMonitoringVisitsService! = self
                    let id = nextId()
                    ownerService.observers.append((id, observer))
                    ownerService.locMgr.startMonitoringVisits()
                    return AnonymousDisposable{
                        ownerService.observers.removeAtIndex(ownerService.observers.indexOf{$0.id == id}!)
                        if ownerService.observers.count == 0{
                            ownerService.locMgr.stopMonitoringVisits()
                        }
                        ownerService = nil
                    }
                }
            }
        }
        
        init(){
            locMgr.didVisit = {
                [weak self]
                mgr, visit in
                if let copyOfObservers = self?.observers{
                    for (_, observer) in copyOfObservers{
                        observer.onNext(visit)
                    }
                }
            }
        }
    }
#endif