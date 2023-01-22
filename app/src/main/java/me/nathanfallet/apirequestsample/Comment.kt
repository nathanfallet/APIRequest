package me.nathanfallet.apirequestsample

import org.json.JSONObject

data class Comment(
    val postId: Int,
    val id: Int,
    val name: String,
    val email: String,
    val body: String
    ) {

    constructor(json: JSONObject): this(
        json.getInt("postId"),
        json.getInt("id"),
        json.getString("name"),
        json.getString("email"),
        json.getString("body")
    )

}
