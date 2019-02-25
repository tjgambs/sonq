package fm.sonq.sonq.features.searchqueue.views

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import fm.sonq.sonq.R

class FragmentQueue : Fragment() {

    companion object {
        fun newInstance(): FragmentQueue {
            return FragmentQueue()
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View {
        return inflater.inflate(R.layout.queue_view, container, false)
    }
}