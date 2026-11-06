package com.hiddify.hiddify.bg

import android.app.Service
import android.content.Intent
import com.hiddify.core.libbox.Notification

class ProxyService :
    Service(),
    PlatformInterfaceWrapper {
    // Proxy mode owns no VPN tunnel, so its sockets need no VpnService.protect.
    override fun usePlatformAutoDetectInterfaceControl(): Boolean = false

    override fun autoDetectInterfaceControl(fd: Int) {
        // Some callers invoke the callback without checking the capability.
        // No VPN tunnel belongs to this service, so there is nothing to protect.
    }

    private val service = BoxService(this, this)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int) = service.onStartCommand()

    override fun onBind(intent: Intent) = service.onBind(intent)

    override fun onDestroy() = service.onDestroy()

    override fun sendNotification(notification: Notification) = service.sendNotification(notification)
}