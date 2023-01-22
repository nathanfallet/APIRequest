package me.nathanfallet.apirequest.decoder

import org.json.JSONArray
import org.json.JSONObject

class JSONAPIDecoder: APIDecoder {

    override fun decode(data: ByteArray): Any? {
        val json = data.toString(charset("utf-8")).trim()
        if (json.startsWith("{")) {
            return JSONObject(json)
        } else if (json.startsWith("[")) {
            return JSONArray(json)
        }
        return null
    }

}