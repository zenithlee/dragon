using UnityEngine;
using System.Collections;

public class Editor : Singleton<Editor> {



    public string Log = "";

    public void HandleLog(string condition, string stackTrace, LogType type)
    {
        Log += condition + "\n";
        

        EditorWindow.outPutText.AppendText(condition + "\n");
        if(type != LogType.Log) 
		{
			EditorWindow.outPutText.AppendText(stackTrace + "\n");
			Log += stackTrace + "\n";
		}
    }

    public static bool IsInEditor
    {
        get { return Instance._IsInEditor; } 
    }

    public string EditorTitle
    {
        set
        {
            if (_IsInEditor && EditorWindow != null) EditorWindow.Text = value;
        }
        get
        {
            if (_IsInEditor && EditorWindow != null) return EditorWindow.Text;
            else return "Not In Editor or non EditorWindow created!";
        }
    }

    private bool _IsInEditor = false;

    private EditorForm EditorWindow;

    public void StartEditor()
    {
        if (_IsInEditor) return;

        if (EditorWindow == null)
        {
            EditorWindow = new EditorForm();
            EditorWindow.Size = new System.Drawing.Size(1000, 800);
            EditorWindow.FormClosed += onClose;
        }
        System.Windows.Forms.Panel temp2 = SceneWindow.Instance.GetInForm(EditorWindow.outputSplitContainer.Panel1);
        EditorWindow.Text = SceneWindow.Instance.Window.Title += " | Editor";
        EditorWindow.Icon = SceneWindow.Instance.Window.GetAppIcon();
        ShinigamiNotifyIcon.Instance.UpdateIconText();
        ShinigamiNotifyIcon.Instance.Show();

        EditorWindow.TopLevel = true;
        EditorWindow.Show();

        _IsInEditor = true;
    }

    public void StopEditor()
    {
        if (!_IsInEditor) return;
        SceneWindow.Instance.WithDrawForm(EditorWindow.outputSplitContainer.Panel1);
        EditorWindow.FormClosed -= onClose;
        EditorWindow.Dispose();
        ShinigamiNotifyIcon.Instance.Dispose();

        _IsInEditor = false;
    }

    public void Dispose()
    {
    }

    public static void onHide(object sender, System.EventArgs e)
    {
        Instance.StopEditor();
    }

    public static void onClose(object sender, System.EventArgs e)
    {
        if (Editor.IsInEditor)
        {
            ShinigamiNotifyIcon.Instance.Dispose();
            System.Windows.Forms.Application.Exit();
        }
        UnityEngine.Application.Quit();
    }


}
