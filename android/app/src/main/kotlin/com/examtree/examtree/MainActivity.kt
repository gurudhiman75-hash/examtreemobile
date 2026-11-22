package com.examtree.examtree

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.examtree.examtree/score_share",
        ).setMethodCallHandler { call, result ->
            if (call.method != "share") {
                result.notImplemented()
            } else {
                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, call.arguments as String)
                }
                startActivity(Intent.createChooser(intent, "Share score"))
                result.success(null)
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            COMPANION_WIDGET_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "publish" -> {
                    CompanionWidgetProvider.publish(
                        context = this,
                        dueCount = call.argument<Int>("dueCount") ?: 0,
                        dailyGoal = call.argument<Int>("dailyGoal") ?: 10,
                        completedToday = call.argument<Int>("completedToday") ?: 0,
                        remainingGoal = call.argument<Int>("remainingGoal") ?: 0,
                        savedCount = call.argument<Int>("savedCount") ?: 0,
                        updatedAtMillis = call.argument<Long>("updatedAtMillis") ?: 0L,
                    )
                    result.success(null)
                }
                "clear" -> {
                    CompanionWidgetProvider.clear(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    companion object {
        private const val COMPANION_WIDGET_CHANNEL =
            "com.examtree.examtree/companion_widget"
    }
}
