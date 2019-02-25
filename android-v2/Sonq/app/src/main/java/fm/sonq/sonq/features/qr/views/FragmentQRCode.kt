package fm.sonq.sonq.features.qr.views

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import fm.sonq.sonq.R

class FragmentQRCode : Fragment() {

    companion object {
        fun newInstance(): FragmentQRCode {
            return FragmentQRCode()
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View {
        return inflater.inflate(R.layout.qr_code_view, container, false)
    }
}