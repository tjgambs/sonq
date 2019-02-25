package fm.sonq.sonq.features.party.join

import android.os.Bundle
import com.google.android.material.bottomnavigation.BottomNavigationView
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import fm.sonq.sonq.R
import fm.sonq.sonq.features.qr.views.FragmentQRCode
import fm.sonq.sonq.features.searchqueue.views.FragmentQueue
import fm.sonq.sonq.features.settings.views.FragmentMore
import kotlinx.android.synthetic.main.activity_join.*

class JoinActivity : AppCompatActivity() {

    private val fragmentQueue: FragmentQueue = FragmentQueue.newInstance()
    private val fragmentQRCode: FragmentQRCode = FragmentQRCode.newInstance()
    private val fragmentMore: FragmentMore = FragmentMore.newInstance()
    private val fm: FragmentManager = supportFragmentManager
    private var active: Fragment = fragmentQueue

    private val mOnNavigationItemSelectedListener = BottomNavigationView.OnNavigationItemSelectedListener { item ->
        when (item.itemId) {
            R.id.navigation_searchqueue -> {
                fm.beginTransaction().hide(active).show(fragmentQueue).commit()
                active = fragmentQueue
                return@OnNavigationItemSelectedListener true
            }
            R.id.navigation_qrcode -> {
                fm.beginTransaction().hide(active).show(fragmentQRCode).commit()
                active = fragmentQRCode
                return@OnNavigationItemSelectedListener true
            }
            R.id.navigation_more -> {
                fm.beginTransaction().hide(active).show(fragmentMore).commit()
                active = fragmentMore
                return@OnNavigationItemSelectedListener true
            }
        }
        false
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_join)
        fm.beginTransaction().add(R.id.frame_view, fragmentMore, "more").hide(fragmentMore).commit()
        fm.beginTransaction().add(R.id.frame_view, fragmentQRCode, "qr").hide(fragmentQRCode).commit()
        fm.beginTransaction().add(R.id.frame_view, fragmentQueue, "queue").commit()

        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener)
    }
}
