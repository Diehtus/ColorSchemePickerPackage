![ios](https://img.shields.io/badge/iOS-14-green)

# A SwiftUI Picker to change the change the UIUserInterfaceStyle

A modified version of Stewart Lynch´s Picker from the video: https://www.youtube.com/watch?v=ATgOV70YcI8

## Example
For default settings form implementation:
```swift
ColorSchemePicker.standard
```

With one default Label: 
```swift
ColorSchemePicker {
    Label("Scheme", systemImage: "circle.righthalf.filled")
}
```

With three labels for each type (system, light, dark):
```swift
ColorSchemePicker {
    Label("Darstellung", systemImage: "circle.righthalf.filled")
} lightLabel: {
    Label("Darstellung", systemImage: "sun.max.circle")
} darkLabel: {
    Label("Darstellung", systemImage: "moon.circle")
}
```
