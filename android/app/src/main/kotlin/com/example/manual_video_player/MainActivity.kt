package com.example.manual_video_player

import com.google.android.gms.cast.framework.CastContext
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        CastContext.getSharedInstance(applicationContext)
        super.configureFlutterEngine(flutterEngine)
    }
}
