package sonq.app.songq;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

public class PartyActivity extends AppCompatActivity {

    private ViewPager viewPager;
    private FragmentSearch fragmentSearch;
    private FragmentQueue fragmentQueue;
    private FragmentQRCode fragmentQRCode;
    private FragmentPlayer fragmentPlayer;
    private BottomNavigationView navigation;
    private Stack<Integer> pageHistory;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_party);

        navigation = findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);

        viewPager = findViewById(R.id.viewpager);
        viewPager.addOnPageChangeListener(mOnPageChangeListener);
        setupViewPager(viewPager);

        pageHistory = new Stack<>();
    }

    private void setupViewPager(ViewPager viewPager) {
        ViewPagerAdapter viewPagerAdapter = new ViewPagerAdapter(getSupportFragmentManager());
        fragmentSearch = new FragmentSearch();
        fragmentQueue = new FragmentQueue();
        fragmentQRCode = new FragmentQRCode();
        fragmentPlayer = new FragmentPlayer();
        viewPagerAdapter.addFragment(fragmentSearch);
        viewPagerAdapter.addFragment(fragmentQueue);
        viewPagerAdapter.addFragment(fragmentQRCode);
        viewPagerAdapter.addFragment(fragmentPlayer);
        viewPager.setAdapter(viewPagerAdapter);
    }

    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {
            switch (item.getItemId()) {
                case R.id.navigation_search:
                    viewPager.setCurrentItem(0);
                    setTitle(R.string.title_search);
                    return true;
                case R.id.navigation_queue:
                    viewPager.setCurrentItem(1);
                    setTitle(R.string.title_queue);
                    return true;
                case R.id.navigation_qr_code:
                    viewPager.setCurrentItem(2);
                    setTitle(R.string.title_qr_code);
                    return true;
                case R.id.navigation_player:
                    viewPager.setCurrentItem(3);
                    setTitle(R.string.title_player);
                    return true;
            }
            return false;
        }
    };

    private ViewPager.OnPageChangeListener mOnPageChangeListener = new ViewPager.OnPageChangeListener() {
        @Override
        public void onPageScrolled(int i, float v, int i1) {

        }

        @Override
        public void onPageSelected(int position) {
            navigation.getMenu().getItem(position).setChecked(true);
            switch (position) {
                case 0:
                    setTitle(R.string.title_search);
                    break;
                case 1:
                    setTitle(R.string.title_queue);
                    break;
                case 2:
                    setTitle(R.string.title_qr_code);
                    break;
                case 3:
                    setTitle(R.string.title_player);
                    break;
            }
        }

        @Override
        public void onPageScrollStateChanged(int i) {

        }
    };
}

class ViewPagerAdapter extends FragmentPagerAdapter {
    private final List<Fragment> mFragmentList = new ArrayList<>();

    public ViewPagerAdapter(FragmentManager manager) {
        super(manager);
    }
    @Override
    public Fragment getItem(int position) {
        return mFragmentList.get(position);
    }

    @Override
    public int getCount() {
        return mFragmentList.size();
    }

    public void addFragment(Fragment fragment) {
        mFragmentList.add(fragment);
    }
}