import UIKit
import Flutter
import AVFAudio
import AVKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let audioSessionChannelName = "bracket/audio_session"
  private let orientationChannelName = "bracket/orientation"
  private let airPlayRoutePickerViewType = "bracket/airplay_route_picker"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let registrar = self.registrar(forPlugin: "BracketPlatformChannels") else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    registrar.register(AirPlayRoutePickerFactory(), withId: airPlayRoutePickerViewType)

    let channel = FlutterMethodChannel(
      name: audioSessionChannelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self else {
        result(FlutterError(code: "unavailable", message: "AppDelegate released", details: nil))
        return
      }

      switch call.method {
      case "ensurePlaybackSession":
        do {
          result(try self.configurePlaybackAudioSession())
        } catch {
          result(
            FlutterError(
              code: "audio_session_error",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let orientationChannel = FlutterMethodChannel(
      name: orientationChannelName,
      binaryMessenger: registrar.messenger()
    )
    orientationChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self else {
        result(FlutterError(code: "unavailable", message: "AppDelegate released", details: nil))
        return
      }

      switch call.method {
      case "getCurrentDeviceOrientation":
        result(self.currentDeviceOrientation())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    do {
      _ = try configurePlaybackAudioSession()
    } catch {
      print("Failed to configure AVAudioSession: \(error)")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configurePlaybackAudioSession() throws -> [String: Any] {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay])
    try session.setActive(true)
    let outputs = session.currentRoute.outputs.map(\.portType.rawValue)
    return [
      "category": session.category.rawValue,
      "mode": session.mode.rawValue,
      "outputs": outputs,
    ]
  }

  private func currentDeviceOrientation() -> String? {
    guard
      let windowScene = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first
    else {
      return nil
    }

    switch windowScene.interfaceOrientation {
    case .portrait:
      return "portraitUp"
    case .portraitUpsideDown:
      return "portraitDown"
    case .landscapeLeft:
      return "landscapeLeft"
    case .landscapeRight:
      return "landscapeRight"
    default:
      return nil
    }
  }
}

final class AirPlayRoutePickerFactory: NSObject, FlutterPlatformViewFactory {
  override init() {
    super.init()
  }

  func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol) {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    AirPlayRoutePickerPlatformView(frame: frame, args: args)
  }
}

final class AirPlayRoutePickerPlatformView: NSObject, FlutterPlatformView {
  private let containerView: AirPlayRoutePickerContainerView
  private let routePickerView: AVRoutePickerView

  init(frame: CGRect, args: Any?) {
    containerView = AirPlayRoutePickerContainerView(frame: frame)
    routePickerView = AVRoutePickerView(frame: frame)
    super.init()

    containerView.backgroundColor = .clear
    containerView.clipsToBounds = false
    routePickerView.backgroundColor = .clear
    routePickerView.prioritizesVideoDevices = true
    routePickerView.translatesAutoresizingMaskIntoConstraints = false
    routePickerView.tintColor = Self.resolveColor(
      from: args,
      key: "tintColor",
      fallback: .white
    )
    routePickerView.activeTintColor = Self.resolveColor(
      from: args,
      key: "activeTintColor",
      fallback: routePickerView.tintColor
    )

    containerView.embed(routePickerView)
  }

  func view() -> UIView {
    containerView
  }

  private static func resolveColor(
    from args: Any?,
    key: String,
    fallback: UIColor
  ) -> UIColor {
    guard
      let parameters = args as? [String: Any],
      let number = parameters[key] as? NSNumber
    else {
      return fallback
    }

    let value = number.uint32Value
    let alpha = CGFloat((value >> 24) & 0xFF) / 255.0
    let red = CGFloat((value >> 16) & 0xFF) / 255.0
    let green = CGFloat((value >> 8) & 0xFF) / 255.0
    let blue = CGFloat(value & 0xFF) / 255.0
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}

final class AirPlayRoutePickerContainerView: UIView {
  private weak var hostedPickerView: AVRoutePickerView?

  func embed(_ pickerView: AVRoutePickerView) {
    hostedPickerView?.removeFromSuperview()
    hostedPickerView = pickerView

    addSubview(pickerView)
    NSLayoutConstraint.activate([
      pickerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      pickerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      pickerView.topAnchor.constraint(equalTo: topAnchor),
      pickerView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    refreshHostedPickerLayout()
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    DispatchQueue.main.async { [weak self] in
      self?.refreshHostedPickerLayout()
    }
  }

  private func refreshHostedPickerLayout() {
    hostedPickerView?.setNeedsLayout()
    hostedPickerView?.layoutIfNeeded()
  }
}
