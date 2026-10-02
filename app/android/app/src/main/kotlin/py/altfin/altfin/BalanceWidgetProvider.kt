package py.altfin.altfin

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Widget "Dinero disponible": el monto abre Mi balance; el "+" abre nuevo gasto. */
class BalanceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_balance).apply {
                setTextViewText(R.id.balance_label, widgetData.getString("balance_label", null) ?: "DINERO DISPONIBLE")
                setTextViewText(R.id.balance_value, widgetData.getString("balance_value", null) ?: "Ver balance")
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("altfin://balance")),
                )
                setOnClickPendingIntent(
                    R.id.add_button,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("altfin://add?kind=expense")),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
