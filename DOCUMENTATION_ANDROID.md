# Full documentation

## Configure your API

This sould be done when your app starts, before any request is executed.

```kotlin
// Set host, and use default https with port 443
APIConfiguration.current = APIConfiguration("api.example.com")

// Set host, and use a custom scheme and port
APIConfiguration.current = APIConfiguration("api.example.com", "https", 443)

// Set host, and custom headers for every request
APIConfiguration.current = APIConfiguration("api.example.com").also {
    // Define headers
    it.headers = {
        // Define headers
        val headers = HashMap<String, String>()

        // Set them, for example an authorization token
        headers["Authorization"] = "mytoken"

        // Return your custom headers
        headers
    }
}

// Of course, you can set a custom scheme/port and headers at the same time
```

## Calling your API

```kotlin
// Create a request a GET request to /path/to/api
// You can use GET, POST, PUT, DELETE, ...
// Warning: The path should start with a / to avoid malformed URLs
val request = APIRequest("GET", "/path/to/api")

// Add GET parameters (you can add strings, integers, bools, ...)
request = request.with("id", 4)

// In case of POST/PUT request, add a body
val obj = JSONObject()
obj.put("name", "John")
obj.put("id", 42)
request = request.withBody(obj)

// Add a custom header (for this request only)            
request = request.withHeader("X-CUSTOM-HEADER", CustomValue

// And execute the request
request.execute { result, status ->
    // Check received data
    
}

// You can write all of this in a single line: (RECOMMANDED)
APIRequest("GET", "/path/to/api").with("id", 4).withHeader("X-CUSTOM-HEADER", "CustomValue").execute { result, status ->
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

We need to declare the data class of our users:

```kotlin
data class User(
    val id: Int,
    val name: String,
    val username: String
) {

    constructor(json: JSONObject): this(
        json.getInt("id"),
        json.getString("name"),
        json.getString("username")
    )

}
```

And then we can fetch our API and decode the data

```kotlin
APIRequest("GET", "/users/profile").with("id", 42).execute { result, status ->
    // Check our user object is correct
    if (result is JSONObject) {
        val user = User(result)
        print(user.id) // 42
        print(user.name) // John
        print(user.username) // @johndoe
    }
}
```

## Use a one-time configuration for a dedicated request

Imagine that one request in your code needs to fetch another API than yours. You can set a custom configuration that only applies to one request:

```kotlin
APIRequest("GET", "/some/path", APIConfiguration("api.anotherexample.com"))
```
