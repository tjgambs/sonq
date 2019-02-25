package fm.sonq.sonq.features.settings.views

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import androidx.fragment.app.Fragment
import fm.sonq.sonq.R

class FragmentMore : Fragment() {

    companion object {
        fun newInstance(): FragmentMore {
            return FragmentMore()
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View {
        return inflater.inflate(R.layout.more_view, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val endPartyButton: Button? = getView()?.findViewById(R.id.end_party)
        endPartyButton?.setOnClickListener {
            activity?.finish()
        }
    }
}