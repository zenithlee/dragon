using UnityEngine;
using System.Collections;

public class World : SingletonMonoBehaviour<World> {

    public LoadingScreenManager LoadingScreen;

    void AwakeSingleton()
    {
       // System.Windows.Forms.Application.ApplicationExit += OnApplicationQuitForm;
        //System.Windows.Forms.Application.SetCompatibleTextRenderingDefault(false);
        //System.Windows.Forms.Application.EnableVisualStyles();
        Application.RegisterLogCallback(Editor.Instance.HandleLog);
    }

    void OnGUI()
    {
        GUI.enabled = !Editor.IsInEditor;
        if (GUILayout.Button("Show"))
        {
            Editor.Instance.StartEditor();
        }
        GUI.enabled = true;
        if (Debug.isDebugBuild)
        {
            Debug.developerConsoleVisible = GUILayout.Toggle(Debug.developerConsoleVisible, "DeveloperConsole");
        }
        if (GUILayout.Button("Test")) Debug.Log("TEst wat the fuck");
        GUILayout.TextArea(Editor.Instance.Log);
    }

    public void LateUpdate()
    {
        if (Editor.IsInEditor)
        {
            System.Windows.Forms.Application.DoEvents();
        }
    }

    void OnApplicationQuit()
    {
        if (Editor.IsInEditor)
        {
            ShinigamiNotifyIcon.Instance.Dispose();
            System.Windows.Forms.Application.Exit();
        }
    }
}
