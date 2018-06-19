//
//  Event.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 19.06.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
public class Event<T> {
    
    public typealias EventHandler = (T) -> ()
    
    internal var eventHandlers = [Invocable]()
    
    public func raise(data: T) {
        for handler in self.eventHandlers {
            handler.invoke(data)
        }
    }
    
    public func addHandler<U: AnyObject>(target: U,
                                         handler: @escaping (U) -> EventHandler) -> Disposable {
        let wrapper = EventHandlerWrapper(target: target,
                                          handler: handler, event: self)
        eventHandlers.append(wrapper)
        return wrapper
    }
}

public protocol Disposable {
    func dispose()
}

internal protocol Invocable: class {
    func invoke(_ data: Any)
}
private class EventHandlerWrapper<T: AnyObject, U>
: Invocable, Disposable {
    weak var target: T?
    let handler: (T) -> (U) -> ()
    let event: Event<U>
    
    init(target: T?, handler: @escaping (T) -> (U) -> (), event: Event<U>) {
        self.target = target
        self.handler = handler
        self.event = event;
    }
    
    func invoke(_ data: Any) -> () {
        if let t = target {
            handler(t)(data as! U)
        }
    }
    
    func dispose() {
        event.eventHandlers =
            event.eventHandlers.filter { $0 !== self }
    }
}
/*
//
let handler = event.addHandler(self, ViewController.handleEvent)
// remove the handler
handler.dispose()
}
func handleEvent(data: (String, String)) {
    println("Hello \(data.0), \(data.1)")
}
//
*/
