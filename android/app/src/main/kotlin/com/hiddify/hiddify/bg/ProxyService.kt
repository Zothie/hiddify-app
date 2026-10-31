package com.hiddify.hiddify.bg

import android.app.Service
import android.content.Intent
import com.hiddify.core.libbox.Notification

class ProxyService :
    Service(),
    PlatformInterfaceWrapper {
    private val service = BoxService(this, this)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int) = service.onStartCommand()

    override fun onBind(intent: Intent) = service.onBind(intent)

    override fun useProcFS(): Boolean = false

    override fun onDestroy() = service.onDestroy()

    override fun sendNotification(notification: Notification) = service.sendNotification(notification)

    fun cancelNotification(identifier: String, typeID: Int) = service.cancelNotification(identifier, typeID)
}