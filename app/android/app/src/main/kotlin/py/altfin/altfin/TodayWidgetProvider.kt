package py.altfin.altfin

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Widget "Podés gastar hoy": el monto del día; el "+" abre nuevo gasto, el resto abre la app. */
class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_today).apply {
                setTextViewText(R.id.today_label, widgetData.getString("today_label", null) ?: "PODÉS GASTAR HOY")
                setTextViewText(R.id.today_value, widgetData.getString("today_value", null) ?: "Abrí AltFin")
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("altfin://home")),
                )
                setOnClickPendingIntent(
                    R.id.add_button,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("altfin://add")),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
