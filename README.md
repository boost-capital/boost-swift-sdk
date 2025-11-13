# BoostKYC SDK for iOS

BoostKYC SDK provides a complete end-to-end user verification flow for iOS applications, supporting document verification with ID cards and passports.

## Features

- **Document Verification**: Support for ID cards and passports
- **Liveness Detection**: Integrated AWS Rekognition liveness checks
- **Fraud Detection**: Built-in fraud detection capabilities
- **Camera Integration**: Streamlined document capture with quality checks
- **Event Tracking**: Real-time delegate callbacks for monitoring verification flow

## Requirements

- iOS 14.0+
- Swift 5.0+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add BoostKYC to your project using SPM:

1. In Xcode, select **File > Add Packages...**
2. Enter the repository URL:
   ```
   https://github.com/boost-capital/boost-swift-sdk
   ```
3. Select the version you want to use
4. Add the package to your target

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/boost-capital/boost-swift-sdk", from: "1.0.0")
]
```

## Configuration

### 1. Add Camera Permission

Add the camera usage description to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture your identity document</string>
```

### 2. Initialize the SDK

Import and configure BoostKYC in your app:

```swift
import BoostKYCKit

// In your AppDelegate or initial view controller
BoostKYC.shared.configure(apiKey: "your_api_key_here")
```

## Usage

### Basic Integration

```swift
import BoostKYCKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure SDK
        BoostKYC.shared.configure(apiKey: "your_api_key_here")

        // Optional: Set event delegate
        BoostKYC.shared.eventDelegate = self
    }

    func startVerification() {
        // Start verification with completion handler
        BoostKYC.shared.startVerification(for: .idCard) { result in
            switch result {
            case .success(let status):
                print("Verification completed. Status: \(status)")

            case .failure(let error):
                print("Verification failed: \(error.localizedDescription)")
            }
        }
    }
}
```

### Using Async/Await

```swift
func startVerification() async {
    do {
        let status = try await BoostKYC.shared.startVerification(for: .passport)
        print("Verification completed. Status: \(status)")
    } catch {
        print("Verification failed: \(error.localizedDescription)")
    }
}
```

## API Reference

### Main Methods

#### `configure(apiKey:)`
Initializes the SDK with your API key.

```swift
BoostKYC.shared.configure(apiKey: "your_api_key_here")
```

**Parameters:**
- `apiKey`: Your BoostKYC API key

---

#### `startVerification(for:completion:)`
Starts the verification flow with a completion handler.

```swift
BoostKYC.shared.startVerification(for: .idCard) { result in
    // Handle result
}
```

**Parameters:**
- `type`: Document type (`.idCard` or `.passport`)
- `completion`: Callback with `Result<String, Error>`

**Returns:** Verification status string on success

---

#### `startVerification(for:)` async
Starts the verification flow using async/await.

```swift
let status = try await BoostKYC.shared.startVerification(for: .passport)
```

**Parameters:**
- `type`: Document type (`.idCard` or `.passport`)

**Returns:** Verification status string

**Throws:** `BoostKYCError` on failure

### Document Types

```swift
enum BoostKYCDocumentType {
    case idCard    // ID card verification
    case passport  // Passport verification
}
```

### Error Handling

The SDK throws `BoostKYCError` for various error scenarios:

```swift
enum BoostKYCError: Error {
    case userCanceledFlow                      // User canceled the verification
    case initializationFailed(reason: String)  // SDK not configured properly
    case failedToFindPresentingViewController  // No view controller to present from
    case cameraPermissionDenied                // Camera access denied
    case somethingWentWrong                    // General error
}
```

## Delegate Methods

Implement `BoostKYCEventDelegate` to receive real-time events:

```swift
extension ViewController: BoostKYCEventDelegate {
    func boostKYC(didCapturePhoto photoData: Data, for documentType: BoostKYCDocumentType) {
        print("Photo captured for \(documentType)")
        // Handle captured photo data
    }
}
```

### BoostKYCEventDelegate Protocol

#### `boostKYC(didCapturePhoto:for:)`
Called when a photo is captured during verification.

**Parameters:**
- `photoData`: The captured image as `Data`
- `documentType`: The type of document being verified

## Demo App

The repository includes a demo app showing the SDK integration.

### Running the Demo

1. Clone the repository:
   ```bash
   git clone https://github.com/boost-capital/boost-swift-sdk
   cd boost-swift-sdk
   ```

2. Open the demo project:
   ```bash
   open BoostKYC_DemoApp/BoostKYC_DemoApp.xcodeproj
   ```

3. Build and run the project (⌘R)

### Demo App Structure

The demo app (`StartVC.swift`) demonstrates:
- SDK configuration
- Document type selection
- Starting verification flow
- Handling results and errors
- Implementing event delegate