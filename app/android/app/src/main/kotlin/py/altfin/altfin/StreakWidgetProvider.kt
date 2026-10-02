package py.altfin.altfin

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Widget "Racha": días seguidos anotando y si hoy ya se anotó; un toque abre nuevo gasto si falta. */
class StreakWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_streak).apply {
                setTextViewText(R.id.streak_value, widgetData.getString("streak_value", null) ?: "0")
                setTextViewText(R.id.streak_label, widgetData.getString("streak_label", null) ?: "días de racha")
                val logged = widgetData.getString("logged_label", null) ?: "Hoy falta anotar"
                setTextViewText(R.id.logged_label, logged)
                val target = if (logged.contains("falta")) "altfin://add?kind=expense" else "altfin://finn"
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(target)),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
