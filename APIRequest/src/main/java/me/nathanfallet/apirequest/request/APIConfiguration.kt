package me.nathanfallet.apirequest.request

import me.nathanfallet.apirequest.decoder.APIDecoder
import me.nathanfallet.apirequest.decoder.JSONAPIDecoder
import me.nathanfallet.apirequest.encoder.APIEncoder
import me.nathanfallet.apirequest.encoder.JSONAPIEncoder

class APIConfiguration @JvmOverloads constructor(
    val host: String,
    val scheme: String = "https",
    val port: Int? = null,
) {

    companion object {

        // Default configuration
        @JvmStatic
        var current: APIConfiguration? = null

    }

    // Configuration variables
    var headers: () -> HashMap<String, String> = { HashMap() }
    var encoder: APIEncoder = JSONAPIEncoder()
    var decoder: APIDecoder = JSONAPIDecoder()

}