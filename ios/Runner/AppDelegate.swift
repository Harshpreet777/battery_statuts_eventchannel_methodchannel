import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let batteryChannel = "samples.flutter.io/battery"
    private let chargingChannel = "samples.flutter.io/charging"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        
        let chargingChannel = FlutterEventChannel(name: chargingChannel,
                                                  binaryMessenger: controller.binaryMessenger)
        chargingChannel.setStreamHandler(ChargingStreamHandler())
        
        let batteryChannel = FlutterMethodChannel(name: batteryChannel,
                                                  binaryMessenger: controller.binaryMessenger)
        batteryChannel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "getBatteryLevel":
                let batteryLevel = self.getBatteryLevel()
                if batteryLevel != -1 {
                    result(batteryLevel)
                } else {
                    result(FlutterError(code: "UNAVAILABLE",
                                        message: "Battery level not available.",
                                        details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func getBatteryLevel() -> Int {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        if device.batteryState == .unknown {
            return -1
        } else {
            return Int(device.batteryLevel * 100)
        }
    }
}

class ChargingStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      UIDevice.current.isBatteryMonitoringEnabled=true;
       let batteryState = UIDevice.current.batteryState
        switch batteryState {
        case .charging, .full:
            eventSink("charging")
        case .unplugged:
            eventSink("discharging")
        default:
            eventSink(FlutterError(code: "UNAVAILABLE",
                                   message: "Charging status unavailable",
                                   details: nil))
        }
        self.eventSink = events
        // NotificationCenter.default.addObserver(
        //     self,
        //     selector: #selector(onBatteryStateDidChange),
        //     name: UIDevice.batteryStateDidChangeNotification,
        //     object: nil
        // )
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
    
    @objc private func onBatteryStateDidChange(notification: Notification) {
        guard let eventSink = eventSink else { return }
        let batteryState = UIDevice.current.batteryState
        switch batteryState {
        case .charging, .full:
            eventSink("charging")
        case .unplugged:
            eventSink("discharging")
        default:
            eventSink(FlutterError(code: "UNAVAILABLE",
                                   message: "Charging status unavailable",
                                   details: nil))
        }
    }
}

