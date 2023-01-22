# Full documentation

## Import the package

```swift
import APIRequest
```

## Configure your API

This sould be done when your app starts, before any request is executed.

```swift
// Set host, and use default https with port 443
APIConfiguration.current = APIConfiguration(host: "api.example.com")

// Set host, and use a custom scheme and port
APIConfiguration.current = APIConfiguration(host: "api.example.com", scheme: "https", port: 443)

// Set host, and custom headers for every request
APIConfiguration.current = APIConfiguration(host: "api.example.com", headers: {
    // Define headers
    var headers = [String: String]()
    
    // Set them, for example an authorization token
    headers["Authorization"] = "mytoken"
    
    // Return your custom headers
    return headers
})

// Of course, you can set a custom scheme/port and headers at the same time
```

## Calling your API

```swift
// Create a request a GET request to /path/to/api
// You can use GET, POST, PUT, DELETE, ...
// Warning: The path should start with a / to avoid malformed URLs
var request = APIRequest("GET", path: "/path/to/api")

// Add GET parameters (you can add strings, integers, bools, ...)
request = request.with(name: "id", value: 4)

// In case of POST/PUT request, add a body
request = request.with(body: [
    "name": "John",
    "id": 42
])

// Add a custom header (for this request only)
request = request.with(header: "X-CUSTOM-HEADER", value: "CustomValue")

// And execute the request, decoding the result as [String: String]
request.execute([String: String].self) { data, status in
    // Check received data
    if let data = data {
        // Process the result of the response
        
    } else {
        // Something went wront during the request, check status value
        
    }
}

// You can write all of this in a single line: (RECOMMANDED)
APIRequest("GET", path: "/path/to/api").with(name: "id", value: 4).with(header: "X-CUSTOM-HEADER", value: "CustomValue").execute([String: String].self) { data, status in
    // Here nothing changes
    // ...
}
```

## Decoding data with a custom type

Imagine that we are fetching a user from our API, and we want to decode the data as a user.

Here is the JSON returned from the API, for this example, at `/users/profile?id=42`:

```json
{
    "id": 42,
    "name": "John",
    "username": "@johndoe"
}
```

We need to declare the class/struct of our users as `Codable`:

```swift
struct User: Codable {

    var id: Int
    var name: String
    var username: String

}
```

And then we can fetch our API and decode the data

```swift
APIRequest("GET", "/users/profile").with(name: "id", value: 42).execute(User.self) { data, status in
    // Check our user object is correct
    if let user = data {
        print(user.id) // 42
        print(user.name) // John
        print(user.username) // @johndoe
    }
}
```

## Use a one-time configuration for a dedicated request

Imagine that one request in your code needs to fetch another API than yours. You can set a custom configuration that only applies to one request:

```swift
APIRequest("GET", "/some/path", configuration: APIConfiguration(host: "api.anotherexample.com"))
```
