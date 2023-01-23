# APIRequest

[![License](https://img.shields.io/github/license/NathanFallet/APIRequest)](LICENSE)
[![Issues](https://img.shields.io/github/issues/NathanFallet/APIRequest)]()
[![Pull Requests](https://img.shields.io/github/issues-pr/NathanFallet/APIRequest)]()
[![Code Size](https://img.shields.io/github/languages/code-size/NathanFallet/APIRequest)]()
[![CodeFactor](https://www.codefactor.io/repository/github/NathanFallet/APIRequest/badge)](https://www.codefactor.io/repository/github/NathanFallet/APIRequest)
[![Open Source Helpers](https://www.codetriage.com/nathanfallet/apirequest/badges/users.svg)](https://www.codetriage.com/nathanfallet/apirequest)

A swift package/android library to interact with a REST API.

## Installation

### iOS

Add `https://github.com/NathanFallet/APIRequest.git` to your Swift Package configuration (or using the Xcode menu: `File` > `Swift Packages` > `Add Package Dependency`)

### Android

Add the following to your `build.gradle` file:

```groovy
repositories {
    mavenCentral()
}

dependencies {
    implementation 'me.nathanfallet.apirequest:apirequest:1.0.4'
}
```

## Usage

### iOS

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

See the [full documentation](DOCUMENTATION_IOS.md) for a complete guide.

### Android

```kotlin
// When your app starts, set the default configuration
APIConfiguration.current = APIConfiguration("api.example.com")

// And then call your API
// This is an equivalent to get `https://api.example.com/path/to/api?custom=parameter` and parse the response from JSON
APIRequest("GET", "/path/to/api")
    .with("custom", "parameter")
    .execute { result, status ->
        
    }
```

See the [full documentation](DOCUMENTATION_ANDROID.md) for a complete guide.

## Examples

### Full example project

Check out the [full example project](https://github.com/NathanFallet/APIRequestExample) made in a [youtube tutorial](https://youtu.be/HBbrZJ0f5gg).

## Donate to the developer

Feel free to make a donation to help the developer to make more great content! [Donate now](https://paypal.me/paynathanfallet)
