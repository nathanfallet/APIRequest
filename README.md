# APIRequest

A swift package to manage a REST API

## Installation

Add `https://github.com/GroupeMINASTE/APIRequest.swift.git` to your Swift Package configuration (or using the Xcode menu: `File` > `Swift Packages` > `Add Package Dependency`)

## Usage

```swift
// Import the package
import APIRequest

// When your app starts, set the default configuration
APIConfiguration.current = APIConfiguration(host: "api.example.com")

// And then call your API
APIRequest("GET", path: "/path/to/api").with(name: "custom", value: "parameter").execute([String: Any].self) { data, status in
    // Check the data and status
    if let data = data, status == .ok {
        // Do what you want with your data
        
    } else {
        // Something went wrong, check the value of `status`
        
    }
}
```
