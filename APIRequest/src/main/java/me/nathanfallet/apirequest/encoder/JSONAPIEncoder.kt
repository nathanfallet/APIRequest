package me.nathanfallet.apirequest.encoder

import org.json.JSONObject

class JSONAPIEncoder: APIEncoder {

    override fun encode(from: Any): ByteArray? {
        if (from is JSONObject) {
            return from.toString().toByteArray(charset("utf-8"))
        }
        return null
    }

    override val contentType: String
        get() = "application/json"

}