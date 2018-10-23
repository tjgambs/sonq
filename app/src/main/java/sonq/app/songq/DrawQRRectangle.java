package sonq.app.songq;

import android.animation.ObjectAnimator;
import android.animation.RectEvaluator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.view.View;
import android.widget.RelativeLayout;

public class DrawQRRectangle extends View {

    private Rect qrCodeRect;
    private Paint paint;
    private ObjectAnimator anim;

    public DrawQRRectangle(Context context){
        super(context);
        init();
    }

    public void setQRCode(Rect qrCodeRect) {
        this.qrCodeRect = qrCodeRect;
        if (this.qrCodeRect != null) {
            Rect to = new Rect(qrCodeRect);
            to.bottom += 100;
            to.top += 100;
            to.right += 100;
            to.left += 100;

            RelativeLayout mRelativeLayout = findViewById(R.id.activity_scan_qr_code_layout);
            anim = ObjectAnimator.ofObject(mRelativeLayout,"clipBounds", new RectEvaluator(), this.qrCodeRect, to);
            anim.setDuration(1000);
            anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator valueAnimator) {
                    postInvalidate();
                }
            });
        }
    }

    private void init() {
        paint = new Paint();
        paint.setColor(Color.RED);
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeWidth(8);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (qrCodeRect != null) {
            canvas.drawRect(qrCodeRect, paint);
            anim.start();
        }
    }
}
