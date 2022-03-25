#!/usr/bin/sh

echo "PowerManagement"
dbus-send --print-reply --dest=org.freedesktop.PowerManagement /org/freedesktop/PowerManagement/Inhibit org.freedesktop.PowerManagement.Inhibit.HasInhibit

echo "login1"
dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.CanReboot"
