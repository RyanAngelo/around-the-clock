//
//  Timer.swift
//  AroundTheClock
//

import Foundation

/// RepeatingTimer mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52
// Adapted from https://medium.com/over-engineering/a-background-repeating-timer-in-swift-412cecfd2ef9
class RepeatingTimer {
    
    let timeInterval: TimeInterval
    var activity: NSObjectProtocol?
    
    //Constructor with time interval in seconds
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    //Create GCD timer
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    var eventHandler: (() -> Void)?
    
    private enum State {
        case suspended
        case resumed
    }
    
    private var state: State = .suspended
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
    
    //Resume the timer
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        //Disable App Nap for timer accuracy
        activity = ProcessInfo().beginActivity(options: .userInitiated, reason: "User created timer, requiring active thread")
        timer.resume()
    }
    
    //Suspend the timer
    func suspend() {
        //Re-enable App Nap
        if let pinfo = activity {
            ProcessInfo().endActivity(pinfo)
        }
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
