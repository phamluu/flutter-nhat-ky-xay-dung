package dhlc.art.nhat_ky_xay_dung;

import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.browser/open";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("openBrowser")) {
                        String url = call.argument("url");
                        if (url != null) {
                            openBrowser(url);
                            result.success(null);
                        } else {
                            result.error("INVALID_URL", "URL is null", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }

    private void openBrowser(String url) {
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        startActivity(intent);
    }
}
