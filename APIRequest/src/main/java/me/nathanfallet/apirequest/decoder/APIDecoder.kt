package me.nathanfallet.apirequest.decoder

interface APIDecoder {

    /*
     * Decode the input data as a T object
     */
    fun decode(data: ByteArray): Any?

}