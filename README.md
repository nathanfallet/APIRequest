# APIRequest

[![License](https://img.shields.io/github/license/GroupeMINASTE/APIRequest.swift)](LICENSE)
[![Issues](https://img.shields.io/github/issues/GroupeMINASTE/APIRequest.swift)]()
[![Pull Requests](https://img.shields.io/github/issues-pr/GroupeMINASTE/APIRequest.swift)]()
[![Code Size](https://img.shields.io/github/languages/code-size/GroupeMINASTE/APIRequest.swift)]()
[![CodeFactor](https://www.codefactor.io/repository/github/groupeminaste/apirequest.swift/badge)](https://www.codefactor.io/repository/github/groupeminaste/apirequest.swift)
[![Open Source Helpers](https://www.codetriage.com/groupeminaste/apirequest.swift/badges/users.svg)](https://www.codetriage.com/groupeminaste/apirequest.swift)

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
// This is an equivalent to get `https://api.example.com/path/to/api?custom=parameter` and parse the response from JSON to a dictionary [String: String]
APIRequest("GET", path: "/path/to/api").with(name: "custom", value: "parameter").execute([String: String].self) { data, status in
    // Check the data and status
    if let data = data, status == .ok {
        // Do what you want with your data
        
    } else {
        // Something went wrong, check the value of `status`
        
    }
}
```

See the [full documentation](documentation.md) for a complete guide.

## Examples

### Full example project
Check out the [full example project](https://github.com/NathanFallet/APIRequestExample) made in a [youtube tutorial](https://youtu.be/HBbrZJ0f5gg).

### Delta: Math helper
- [Initialize the API configuration](https://github.com/GroupeMINASTE/Delta-iOS/blob/72d6d2edc7d7b1c8d65958144204c5f580e8ce9a/Delta/Utils/AppDelegate.swift#L58)
- [Fetch data from an API](https://github.com/GroupeMINASTE/Delta-iOS/blob/72d6d2edc7d7b1c8d65958144204c5f580e8ce9a/Delta/Controllers/CloudHomeTableViewController.swift#L57)

### HiberLink
- [Send data to API](https://github.com/GroupeMINASTE/HiberLink-iOS/blob/63264417d980caabf5b7d9a27efb58fd90b93162/HiberLink/Controllers/UploadViewController.swift#L124)

## Donate to the developer

Feel free to make a donation to help the developer to make more great content! [Donate now](https://paypal.me/NathanFallet)
