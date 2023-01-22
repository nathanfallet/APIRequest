package me.nathanfallet.apirequest.request

import android.os.Handler
import android.os.Looper
import java.net.HttpURLConnection
import java.net.URI
import java.net.URL
import java.util.concurrent.Executors
import java.util.concurrent.Future

class APIRequest @JvmOverloads constructor(
    private val method: String,
    private val path: String,
    configuration: APIConfiguration? = APIConfiguration.current
) {

    // Object properties
    private val configuration: APIConfiguration = configuration!!
    private val headers: HashMap<String, String> = HashMap()
    private val queryItems: HashMap<String, Any> = HashMap()
    private var body: ByteArray? = null
    private var contentType: String? = null

    // Task properties
    private val executor = Executors.newSingleThreadExecutor()
    private val handler = Handler(Looper.getMainLooper())
    private var task: Future<*>? = null

    /*
     * Add a get parameter
     */
    fun with(name: String, value: Any): APIRequest {
        queryItems[name] = value
        return this
    }

    /*
     * Add a header to the request
     */
    fun withHeader(name: String, value: String): APIRequest {
        headers[name] = value
        return this
    }

    /*
     * Add a body to the request (for POST or PUT requests)
     */
    fun withBody(body: ByteArray?): APIRequest {
        this.body = body
        return this
    }

    /*
     * Add a body to the request (for POST or PUT requests)
     */
    fun withBody(body: Any): APIRequest {
        this.body = configuration.encoder.encode(body)
        this.contentType = configuration.encoder.contentType
        return this
    }

    /*
     * Add a content type to the request (for POST or PUT requests)
     */
    fun withContentType(contentType: String): APIRequest {
        this.contentType = contentType
        return this
    }

    private val url: URL?
        get() {
            try {
                val port = configuration.port ?: if (configuration.scheme == "https") 443 else 80
                val uri = URI(configuration.scheme, null, configuration.host, port, path, query, null)
                return uri.toURL()
            } catch (e: Exception) {
                e.printStackTrace()
            }
            return null
        }

    private val query: String
        get() {
            val sb = StringBuilder()
            if (queryItems.isNotEmpty()) {
                for (key in queryItems.keys) {
                    if (sb.toString().isNotEmpty()) {
                        sb.append("&")
                    }
                    sb.append(key)
                    sb.append("=")
                    sb.append(queryItems[key])
                }
            }
            return sb.toString()
        }

    fun execute(completionHandler: (result: Any?, status: APIResponseStatus) -> Unit): APIRequest {
        task = executor.submit {
            url?.let { url ->
                try {
                    // Create the request based on give parameters
                    val con = url.openConnection() as HttpURLConnection
                    con.requestMethod = method

                    // Get headers from configuration
                    for (item in configuration.headers()) {
                        con.setRequestProperty(item.key, item.value)
                    }

                    // Get headers from request
                    for (item in headers) {
                        con.setRequestProperty(item.key, item.value)
                    }

                    // Set body
                    if (body != null) {
                        if (contentType != null) {
                            con.setRequestProperty("Content-Type", contentType)
                        }
                        con.doOutput = true
                        con.outputStream.use { os ->
                            os.write(body, 0, body!!.size)
                        }
                    }

                    // Launch the request to server
                    con.connect()

                    // Get data and response
                    end(
                        configuration.decoder.decode(con.inputStream.readBytes()),
                        APIResponseStatus.status(con.responseCode),
                        completionHandler
                    )
                } catch (e: Exception) {
                    // Unknown server error
                    e.printStackTrace()
                    end(null, APIResponseStatus.ERROR, completionHandler)
                }
            } ?: run {
                // URL is not valid
                end(null, APIResponseStatus.ERROR, completionHandler)
            }
        }

        // Return the request object
        return this
    }

    /*
     * Cancel the ongoing request
     */
    fun cancel(): APIRequest {
        task?.cancel(true)
        task = null
        return this
    }

    private fun end(
        data: Any?,
        status: APIResponseStatus,
        completionHandler: (result: Any?, status: APIResponseStatus) -> Unit
    ) {
        handler.post {
            completionHandler(data, status)
        }
    }

}