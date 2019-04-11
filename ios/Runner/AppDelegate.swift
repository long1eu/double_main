import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

    private var channel: FlutterMethodChannel?
    private var background: FlutterMethodChannel?
    private var backgroundRunner: FlutterEngine?
    private var initialized = false

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        backgroundRunner = FlutterEngine(name: "FlutterBackgroundRunner", project: nil, allowHeadlessExecution: true)
        background = FlutterMethodChannel(name: "com.app/background_channel", binaryMessenger: backgroundRunner!)
        channel = FlutterMethodChannel(name: "com.app/foreground_channel", binaryMessenger: (window.rootViewController as! FlutterViewController))
        channel?.setMethodCallHandler(self.handle)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }


    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog("\(call.method == "ForegroundRunner.helloBackground")")

        switch (call.method) {
        case "ForegroundRunner.initialize":
            setDispatcherHandle(handler: (call.arguments as! NSNumber).int64Value, key: "callbackDispatcher")
            startBackgroundService() {
                result(nil)
            }
            break;
        case "BackgroundRunner.initialized":
            result(nil)
            break;
        default:
            result(FlutterMethodNotImplemented)
            break;
        }
    }

    private func startBackgroundService(withCompletionHandler completionHandler: @escaping () -> Void) {
        if (initialized) {
            completionHandler()
            return;
        }

        if let info = FlutterCallbackCache.lookupCallbackInformation(getDispatcherHandle(key: "callbackDispatcher")) {
            backgroundRunner!.run(withEntrypoint: info.callbackName, libraryURI: info.callbackLibraryPath)
            GeneratedPluginRegistrant.register(with: backgroundRunner)

            background!.setMethodCallHandler { call, result in
                if call.method == "BackgroundRunner.initialized" {
                    self.initialized = true
                    completionHandler()
                }
                self.handle(call, result: result)
            }
        }
    }

    private func setDispatcherHandle(handler: Int64, key: String) {
        UserDefaults.standard.set(handler, forKey: key)
    }

    private func getDispatcherHandle(key: String) -> Int64 {
        let object = UserDefaults.standard.object(forKey: key)
        guard let handle: NSNumber = object as? NSNumber else {
            return 0
        }

        return handle.int64Value
    }
}
