import SwiftUI
import os

/// Ein Picker der den UserInterfaceStyle ändert
///
/// Es kann gewählt werden zwischen System, Hell oder Dunkel.
///
/// **Standardinizialisierung**
/// ```
/// ColorSchemePicker.standard
/// ```
/// - Important: Init ColorSchemeManager in AppGroup!
@available(iOS 14.0, *)
public struct ColorSchemePicker<PickerLabel>: View where PickerLabel: View {
    
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    
    let systemLabel: PickerLabel
    let darkLabel: PickerLabel?
    let lightLabel: PickerLabel?
    
    /// Erstelle einen `ColorSchemePicker` mit einem Standardlabel
    /// - Important: Call 'ColorSchemeManager.shared.applyColorScheme()' in AppGroup!
    /// - Parameter label: vom Typ `View` z.B. Text, Label etc.
    public init(@ViewBuilder label: () -> PickerLabel) {
        self.systemLabel = label()
        self.lightLabel = nil
        self.darkLabel = nil
    }
    
    /// Erstelle einen `ColorSchemePicker` mit System-, Hell- und Dunkellabel
    /// - Important: Call 'ColorSchemeManager.shared.applyColorScheme()' in AppGroup!
    /// - Parameters:
    ///   - systemLabel: vom Typ `View` z.B. Text, Label etc.
    ///   - lightLabel: vom Typ `View` z.B. Text, Label etc.
    ///   - darkLabel: vom Typ `View` z.B. Text, Label etc.
    public init(@ViewBuilder systemLabel: () -> PickerLabel,
         @ViewBuilder lightLabel: () -> PickerLabel,
         @ViewBuilder darkLabel: () -> PickerLabel) {
        self.systemLabel = systemLabel()
        self.lightLabel = lightLabel()
        self.darkLabel = darkLabel()
    }

    public var body: some View {
        Picker(selection: $colorSchemeManager.colorScheme) {
            ForEach(colorSchemeManager.allCases, id: \.rawValue) { scheme in
                Text(scheme.description).tag(scheme)
            }
        } label: {
            if let label = lightLabel, colorSchemeManager.colorScheme == .light {
                label
            } else if let label = darkLabel, colorSchemeManager.colorScheme == .dark {
                label
            } else {
                systemLabel
            }
        }
    }
}

@available(iOS 14.0, *)
extension ColorSchemePicker where PickerLabel == Text {
    /// Erstelle einen `ColorSchemePicker` mit einem Text
    /// - Parameter text: Beschreibung für den Picker
    /// - Important: Call 'ColorSchemeManager.shared.applyColorScheme()' in AppGroup!
    public init(_ text: String) {
        self.systemLabel = Text(text)
        self.lightLabel = nil
        self.darkLabel = nil
    }
}

@available(iOS 14.0, *)
extension ColorSchemePicker where PickerLabel == Label<Text, Image> {
    /// Standard `ColorSchemePicker` mit vordefinierten Label
    ///
    /// Der Text lautet: 'Darstellung'
    /// - Important: Call 'ColorSchemeManager.shared.applyColorScheme()' in AppGroup!
    public static let standard: ColorSchemePicker = {
        ColorSchemePicker {
            Label(NSLocalizedString("Appearance", bundle: .module, comment: "Appearance"), systemImage: "circle.righthalf.filled")
        } lightLabel: {
            Label(NSLocalizedString("Appearance", bundle: .module, comment: "Appearance"), systemImage: "sun.max.circle")
        } darkLabel: {
            Label(NSLocalizedString("Appearance", bundle: .module, comment: "Appearance"), systemImage: "moon.circle")
        }
    }()
}

@available(iOS 14.0, *)
public final class ColorSchemeManager: ObservableObject {
    
    @AppStorage("ColorSchemePicker_colorScheme") var colorScheme: ColorScheme = .unspecified {
        didSet { applyColorScheme() }
    }
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: String(describing: ColorSchemeManager.self))
    
    public static let shared = ColorSchemeManager()
    
    private var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else { return nil }
        return window
    }
    
    private init() {
        applyColorScheme()
    }
    
    var allCases: [ColorScheme] { ColorScheme.allCases }
    
    enum ColorScheme: Int, CaseIterable {
        case unspecified, light, dark
 
        var description: String {
            switch self {
            case .unspecified: return NSLocalizedString("system", bundle: .module, comment: "system interface style")
            case .light: return NSLocalizedString("light", bundle: .module, comment: "light interface style")
            case .dark: return NSLocalizedString("dark", bundle: .module, comment: "dark interface style")
            }
        }
    }
    
    public func applyColorScheme() {
        window?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: colorScheme.rawValue) ?? .unspecified
        Self.logger.info("UserInterfaceStyle changed to: \(self.colorScheme.description)")
    }
}
