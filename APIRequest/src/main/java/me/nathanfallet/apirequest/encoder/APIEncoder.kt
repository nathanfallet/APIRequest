package me.nathanfallet.apirequest.encoder

interface APIEncoder {

    /*
     * Encode the input object as data
     */
    fun encode(from: Any): ByteArray?

    /*
     * Content type of the request
     */
    val contentType: String?

}