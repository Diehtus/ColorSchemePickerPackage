import SwiftUI

/// Ein Picker der den UserInterfaceStyle ändert
///
/// Es kann gewählt werden zwischen System, Hell oder Dunkel.
///
/// **Standardinizialisierung**
/// ```
/// ColorSchemePicker.standard
/// ```
@available(iOS 14.0, *)
public struct ColorSchemePicker<PickerLabel>: View where PickerLabel: View {
    
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    
    let systemLabel: PickerLabel
    let darkLabel: PickerLabel?
    let lightLabel: PickerLabel?
    
    /// Erstelle einen `ColorSchemePicker` mit einem Standardlabel
    /// - Parameter label: vom Typ `View` z.B. Text, Label etc.
    public init(@ViewBuilder label: () -> PickerLabel) {
        self.systemLabel = label()
        self.lightLabel = nil
        self.darkLabel = nil
    }
    
    /// Erstelle einen `ColorSchemePicker` mit System-, Hell- und Dunkellabel
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
    public static let standard: ColorSchemePicker = {
        ColorSchemePicker {
            Label("Darstellung", systemImage: "circle.righthalf.filled")
        } lightLabel: {
            Label("Darstellung", systemImage: "sun.max.circle")
        } darkLabel: {
            Label("Darstellung", systemImage: "moon.circle")
        }
    }()
}

@available(iOS 14.0, *)
final class ColorSchemeManager: ObservableObject {
    
    @AppStorage("ColorSchemePicker_colorScheme") var colorScheme: ColorScheme = .unspecified {
        didSet { applyColorScheme() }
    }
    
    fileprivate static let shared = ColorSchemeManager()
    
    private var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else { return nil }
        return window
    }
    
    private init() { }
    
    var allCases: [ColorScheme] { ColorScheme.allCases }
    
    enum ColorScheme: Int, CaseIterable {
        case unspecified, light, dark
 
        var description: String {
            switch self {
            case .unspecified: return "System"
            case .light: return "Hell"
            case .dark: return "Dunkel"
            }
        }
    }
    
    private func applyColorScheme() {
        window?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: colorScheme.rawValue) ?? .unspecified
    }
}
