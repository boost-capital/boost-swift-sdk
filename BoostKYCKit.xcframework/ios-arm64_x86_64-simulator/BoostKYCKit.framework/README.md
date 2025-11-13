# BoostKYC

BoostKYC is a lightweight SDK that allows you to launch a simple KYC flow from any iOS application.

This SDK version presents:

- camera preview screen
- card scanning framing rectangle
- debug close button

> **Note:** this SDK is currently a prototype / PoC implementation.

---

## Requirements

- iOS 14+
- Swift

---

## Installation

### Swift Package Manager

1. Open your Xcode project
2. `File` → `Add Packages...`
3. Add the SDK Git URL

---

## App Permissions

BoostKYC uses the camera.
The host app must add the following entry in its **Info.plist**:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera is used to scan the card.</string>
```

Without this key iOS will not allow camera access, and video preview will fail.

---

## Usage Example

```swift
import BoostKYC

BoostKYC.startWithId("123456", from: self)
```

---

## Notes

- SDK does not modify your plist automatically
- SDK will request camera access when starting the capture session
- Detection logic is currently mocked for prototype stage

---
