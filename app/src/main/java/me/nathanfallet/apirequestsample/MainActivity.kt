package me.nathanfallet.apirequestsample

import android.annotation.SuppressLint
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import me.nathanfallet.apirequest.decoder.JSONAPIDecoder
import me.nathanfallet.apirequest.encoder.JSONAPIEncoder
import me.nathanfallet.apirequest.request.APIConfiguration
import me.nathanfallet.apirequest.request.APIRequest
import org.json.JSONArray

class MainActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var recyclerViewAdapter: CommentRecyclerViewAdapter

    private val items = ArrayList<Comment>()

    @SuppressLint("NotifyDataSetChanged")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Init recycler view
        recyclerView = RecyclerView(this)
        recyclerViewAdapter = CommentRecyclerViewAdapter()
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = recyclerViewAdapter
        setContentView(recyclerView)

        // Create configuration
        APIConfiguration.current = APIConfiguration("jsonplaceholder.typicode.com").also {
            // Optional personalization
            it.headers = {
                // Add custom headers (eg: an access token)
                HashMap()
            }
            it.encoder = JSONAPIEncoder() // Set a custom APIEncoder
            it.decoder = JSONAPIDecoder() // Set a custom APIDecoder
        }

        // Create a request
        APIRequest("GET", "/comments")
            .with("postId", 1)
            .execute { result, status ->
                if (result is JSONArray) {
                    // Convert JSON Array to Objects
                    items.clear()
                    for (i in 0 until result.length()) {
                        items.add(Comment(result.getJSONObject(i)))
                    }
                }
                recyclerViewAdapter.notifyDataSetChanged()
            }
    }

    inner class CommentRecyclerViewAdapter(): RecyclerView.Adapter<CommentRecyclerViewAdapter.CommentRecyclerViewHolder>() {

        override fun onCreateViewHolder(
            parent: ViewGroup,
            viewType: Int
        ): CommentRecyclerViewHolder {
            val root = LayoutInflater.from(parent.context).inflate(R.layout.item_post, parent, false)
            return CommentRecyclerViewHolder(root)
        }

        override fun onBindViewHolder(holder: CommentRecyclerViewHolder, position: Int) {
            holder.bind(items[position])
        }

        override fun getItemCount(): Int {
            return items.size
        }


        inner class CommentRecyclerViewHolder(itemView: View): RecyclerView.ViewHolder(itemView) {

            private val id: TextView = itemView.findViewById(R.id.comment_id)
            private val name: TextView = itemView.findViewById(R.id.comment_name)
            private val body: TextView = itemView.findViewById(R.id.comment_body)

            fun bind(comment: Comment) {
                id.text = comment.id.toString()
                name.text = comment.name
                body.text = comment.body
            }

        }

    }

}