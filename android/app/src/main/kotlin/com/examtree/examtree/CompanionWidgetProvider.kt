package com.examtree.examtree

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import java.text.DateFormat
import java.util.Date

class CompanionWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { widgetId ->
            appWidgetManager.updateAppWidget(widgetId, buildRemoteViews(context))
        }
    }

    companion object {
        private const val PREFS_NAME = "examtree_companion_widget"
        private const val KEY_HAS_DATA = "has_data"
        private const val KEY_DUE_COUNT = "due_count"
        private const val KEY_DAILY_GOAL = "daily_goal"
        private const val KEY_COMPLETED_TODAY = "completed_today"
        private const val KEY_REMAINING_GOAL = "remaining_goal"
        private const val KEY_SAVED_COUNT = "saved_count"
        private const val KEY_UPDATED_AT = "updated_at"

        fun publish(
            context: Context,
            dueCount: Int,
            dailyGoal: Int,
            completedToday: Int,
            remainingGoal: Int,
            savedCount: Int,
            updatedAtMillis: Long,
        ) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_HAS_DATA, true)
                .putInt(KEY_DUE_COUNT, dueCount.coerceAtLeast(0))
                .putInt(KEY_DAILY_GOAL, dailyGoal.coerceAtLeast(1))
                .putInt(KEY_COMPLETED_TODAY, completedToday.coerceAtLeast(0))
                .putInt(KEY_REMAINING_GOAL, remainingGoal.coerceAtLeast(0))
                .putInt(KEY_SAVED_COUNT, savedCount.coerceAtLeast(0))
                .putLong(KEY_UPDATED_AT, updatedAtMillis)
                .apply()
            refreshAll(context)
        }

        fun clear(context: Context) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .clear()
                .apply()
            refreshAll(context)
        }

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, CompanionWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            ids.forEach { widgetId ->
                manager.updateAppWidget(widgetId, buildRemoteViews(context))
            }
        }

        private fun buildRemoteViews(context: Context): RemoteViews {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val hasData = prefs.getBoolean(KEY_HAS_DATA, false)
            val views = RemoteViews(context.packageName, R.layout.companion_widget)

            if (hasData) {
                val dueCount = prefs.getInt(KEY_DUE_COUNT, 0)
                val dailyGoal = prefs.getInt(KEY_DAILY_GOAL, 10)
                val completedToday = prefs.getInt(KEY_COMPLETED_TODAY, 0)
                val remainingGoal = prefs.getInt(KEY_REMAINING_GOAL, dailyGoal)
                val savedCount = prefs.getInt(KEY_SAVED_COUNT, 0)
                val updatedAtMillis = prefs.getLong(KEY_UPDATED_AT, 0L)
                val savedLabel =
                    if (savedCount == 1) "1 saved review" else "$savedCount saved reviews"
                val freshness = if (updatedAtMillis > 0L) {
                    val time = DateFormat.getTimeInstance(DateFormat.SHORT)
                        .format(Date(updatedAtMillis))
                    "$savedLabel • Updated $time"
                } else {
                    savedLabel
                }

                views.setTextViewText(
                    R.id.widget_due,
                    if (dueCount == 1) "1 question due" else "$dueCount questions due",
                )
                views.setTextViewText(
                    R.id.widget_goal,
                    "$completedToday/$dailyGoal today • $remainingGoal left",
                )
                views.setTextViewText(R.id.widget_saved, freshness)
            } else {
                views.setTextViewText(R.id.widget_due, "Open ExamTree to load today’s revision")
                views.setTextViewText(R.id.widget_goal, "Your private Daily Companion stays on-device")
                views.setTextViewText(R.id.widget_saved, "")
            }

            views.setOnClickPendingIntent(
                R.id.widget_root,
                deepLinkIntent(context, "examtree://app/daily", 4100),
            )
            views.setOnClickPendingIntent(
                R.id.widget_quick_revision,
                deepLinkIntent(context, "examtree://app/quick-revision?minutes=5", 4101),
            )
            views.setOnClickPendingIntent(
                R.id.widget_tests,
                deepLinkIntent(context, "examtree://app/exams", 4102),
            )
            return views
        }

        private fun deepLinkIntent(
            context: Context,
            uri: String,
            requestCode: Int,
        ): PendingIntent {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uri), context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            return PendingIntent.getActivity(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}
