package py.altfin.altfin

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Widget "Anotar": tres botones; cada uno abre directo la pantalla de ese tipo de movimiento. */
class QuickAddWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        fun open(uri: String) =
            HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(uri))
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_quick_add).apply {
                setOnClickPendingIntent(R.id.widget_root, open("altfin://add?kind=expense"))
                setOnClickPendingIntent(R.id.widget_icon, open("altfin://add?kind=expense"))
                setOnClickPendingIntent(R.id.btn_expense, open("altfin://add?kind=expense"))
                setOnClickPendingIntent(R.id.btn_income, open("altfin://add?kind=income"))
                setOnClickPendingIntent(R.id.btn_saving, open("altfin://add?kind=saving"))
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
