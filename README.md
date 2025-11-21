# BoostKYC SDK for iOS

BoostKYC SDK provides a complete end-to-end user verification flow for iOS applications, supporting document verification with ID cards and passports.

## Features

- **Document Verification**: Support for ID cards and passports
- **Liveness Detection**: Integrated liveness checks
- **Fraud Detection**: Built-in fraud detection capabilities
- **Camera Integration**: Streamlined document capture with quality checks
- **Event Tracking**: Real-time delegate callbacks for monitoring verification flow

## Requirements

- iOS 13.0+
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

Add the camera usage description to your `Info.plist` to allow the SDK to capture identity documents and perform liveness checks (face verification):

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture your identity document and verify your face</string>
```

### 2. Initialize the SDK

You must configure the SDK with your API key before using any other features. A good place to do this is in your `AppDelegate` or the initial view controller of your app.

```swift
import BoostKYC

// In your AppDelegate or initial view controller
BKYC.shared.configure(apiKey: "your_api_key_here")
```

## Usage

### Basic Integration

The `startVerification` method initiates the UI flow.

```swift
import BoostKYC

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Configure the SDK (if not done elsewhere)
        BKYC.shared.configure(apiKey: "your_api_key_here")

        // 2. Set the event delegate (optional)
        BKYC.shared.eventDelegate = self
    }

    func startVerification() {
        // 3. Start verification
        BKYC.shared.startVerification(for: .idCard) { result in
            switch result {
            case .success:
                print("Verification completed successfully.")

            case .failure(let error):
                print("Verification failed: \(error.localizedDescription)")
            }
        }
    }
}
```

### Using Async/Await

For modern Swift concurrency, use the async/await variant:

```swift
func startVerification() async {
    do {
        try await BKYC.shared.startVerification(for: .passport)
        print("Verification completed successfully.")
    } catch {
        print("Verification failed: \(error.localizedDescription)")
    }
}
```

## API Reference

### BKYC Class

The main entry point for the SDK. Access the singleton instance via `BKYC.shared`.

#### `configure(apiKey:)`

Initializes the SDK with your unique API key. This **must** be called before starting any verification.

```swift
func configure(apiKey: String)
```

- **Parameters:**
  - `apiKey`: Your BoostKYC API key provided by the dashboard.

---

#### `startVerification(for:from:completion:)`

Starts the verification flow. This method will present a modal view controller on top of the current top-most view controller.

```swift
func startVerification(
    for type: BKYCDocumentType,
    from vc: UIViewController? = nil,
    completion: @escaping (Result<Void, Error>) -> Void
)
```

- **Parameters:**
  - `type`: The type of document to verify (see [Document Types](#document-types)).
  - `from`: (Optional) The `UIViewController` to present the SDK from. If `nil`, the SDK attempts to find the top-most view controller.
  - `completion`: A closure called when the flow finishes. Returns `.success(())` on success or `.failure(Error)` if canceled or failed.

---

#### `startVerification(for:from:)` async

The async/await alternative for starting verification.

```swift
func startVerification(for type: BKYCDocumentType, from vc: UIViewController? = nil) async throws
```

- **Parameters:**
  - `type`: The type of document to verify.
  - `from`: (Optional) The `UIViewController` to present the SDK from.
- **Throws:** `BKYCError` if the verification fails or is canceled.

### Document Types

The `BKYCDocumentType` enum defines the supported documents for verification.

```swift
public enum BKYCDocumentType: String, Decodable {
    /// National ID Card verification
    case idCard
    
    /// Passport verification
    case passport
}
```

### Error Handling

The SDK uses `BKYCError` to report specific failure reasons.

```swift
public enum BKYCError: Error, LocalizedError {
    /// The SDK was not configured with an API key before use.
    case initializationFailed(reason: String)
    
    /// Could not find a valid view controller to present the SDK UI.
    case failedToFindPresentingViewController
    
    /// Required keys are missing from Info.plist (e.g., NSCameraUsageDescription).
    case missingPlistKey(_ key: String)
    
    /// The user denied camera permissions.
    case cameraPermissionDenied
    
    /// An unexpected internal error occurred.
    case somethingWentWrong
    
    /// The user explicitly canceled the verification flow.
    case userCanceled
}
```

## Advanced Usage: Event Delegation

You can implement the `BKYCEventDelegate` protocol to receive real-time updates during the verification process. This is useful for analytics or custom processing of captured data.

### Setting the Delegate

```swift
BKYC.shared.eventDelegate = self
```

### Protocol Methods

#### `boostKYC(didCapturePhoto:for:)`

Called immediately after the user captures a photo of their document, before it is processed by the backend.

```swift
func boostKYC(didCapturePhoto photoData: Data, for documentType: BKYCDocumentType)
```

- **Parameters:**
  - `photoData`: The raw image data of the captured document.
  - `documentType`: The type of document that was captured.

**Example Implementation:**

```swift
extension ViewController: BKYCEventDelegate {
    func boostKYC(didCapturePhoto photoData: Data, for documentType: BKYCDocumentType) {
        // Example: Upload to your own analytics or display a preview
    }
}
```

## Demo App

The repository includes a demo app (`BoostKYC_DemoApp`) that showcases the complete integration.

### Running the Demo

1. Clone the repository:
   ```bash
   git clone https://github.com/boost-capital/boost-swift-sdk
   cd boost-swift-sdk
   ```

2. Open the project in Xcode:
   ```bash
   open BoostKYC_DemoApp/BoostKYC_DemoApp.xcodeproj
   ```

3. Build and run (⌘R).
