using UnityEngine;
using System.Collections;
using System.Windows.Forms;
using ManagedWinapi;
using ManagedWinapi.Windows;
using System;
using System.Drawing;

public class ShinigamiNotifyIcon : Singleton<ShinigamiNotifyIcon>
{
    private NotifyIcon Icon;

    public ShinigamiNotifyIcon()
    {
        Icon = new NotifyIcon();

        Icon.BalloonTipIcon = System.Windows.Forms.ToolTipIcon.Info;
        Icon.BalloonTipText = "[Balloon Text when Minimized]";
        Icon.BalloonTipTitle = "[Balloon Title when Minimized]";

        Icon.Visible = true;
        Icon.ContextMenu = RightClickMenu = new System.Windows.Forms.ContextMenu(new MenuItem[] { new MenuItem("Close", Editor.onClose) });
    }

    public void UpdateIconText()
    {
        Icon.Icon = SystemWindow.ForegroundWindow.GetAppIcon();
        string newTitle = SystemWindow.ForegroundWindow.Title;
        if (newTitle.Length > 60) newTitle = newTitle.Substring(0, 60);
        Icon.Text = newTitle;
    }

    public System.Windows.Forms.ContextMenu RightClickMenu;

    public void Show()
    {
        if (Instance != null)
        {
            Icon.Visible = true;
        }
    }

    public void Dispose()
    {
        Icon.Visible = false;
        Icon.Dispose();
        Icon = null;
    }
}
