using UnityEngine;
using System.Collections;
using System.Windows.Forms;
using ManagedWinapi;
using ManagedWinapi.Windows;
using System;
using System.Drawing;

public class SceneWindow : Singleton<SceneWindow>, System.Windows.Forms.IWin32Window
{
    public SystemWindow Window;
    public IntPtr Handle { get { return Instance.Window.HWnd; } }

    public SceneWindow()
    {
        Window = SystemWindow.ForegroundWindow;
    }

    private string OldName;

    public Panel GetInForm(Panel OwningPanel)
    {
        if (OwningPanel == null) return null;
        UnityEngine.Screen.fullScreen = false;
        Window = SystemWindow.ForegroundWindow;
        OldName = Window.Title;

        //     ParentForm.ContextMenu = ContexMenu;
        SystemWindow window2 = new SystemWindow(OwningPanel);
        //  window2.Position = Window.Position;
        Window.SetParent(window2);

        OwningPanel.Resize += OnResize;

        Window.Style = WindowStyleFlags.CHILD;
        Window.ExtendedStyle = WindowExStyleFlags.APPWINDOW | WindowExStyleFlags.ACCEPTFILES | WindowExStyleFlags.LEFT;
        Window.Position = new RECT(-3, -25, OwningPanel.Size.Width, OwningPanel.Size.Height);
        UnityEngine.Screen.SetResolution(OwningPanel.Size.Width, OwningPanel.Size.Height, false);

        return OwningPanel;
    }

    public SystemWindow WithDrawForm(Panel OwningPanel)
    {
        if (OwningPanel == null) return null;

        Window.SetParent(SystemWindow.DesktopWindow);
        Window.Style = WindowStyleFlags.BORDER | WindowStyleFlags.SYSMENU | WindowStyleFlags.CAPTION | WindowStyleFlags.DLGFRAME;
        Window.ExtendedStyle &= ~(WindowExStyleFlags.APPWINDOW | WindowExStyleFlags.ACCEPTFILES);
        Window.Title = OldName;
        SystemWindow.ForegroundWindow = Window;

        // Window.Location = new Point(ParentForm.DesktopLocation.X, ParentForm.DesktopLocation.Y);
        // Window.Position = new RECT(ParentForm.DesktopLocation.X, ParentForm.DesktopLocation.Y, UnityEngine.Screen.width, UnityEngine.Screen.height);
        OwningPanel.Resize -= OnResize;
        //  ParentForm.FormClosed -= Editor.onClose;
        // ParentForm.Dispose();
        // ParentForm = null;

        return Window;
    }

    public void Dispose()
    {
    }

    void OnResize(object sender, EventArgs e)
    {
        Panel tempPanel = (Panel)sender;
      //  Window.Style |= WindowStyleFlags.CHILD;
        Window.Position = new RECT(-3, -25, tempPanel.Size.Width, tempPanel.Size.Height);
        UnityEngine.Screen.SetResolution(tempPanel.Size.Width, tempPanel.Size.Height, false);
    }
}
