using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ShinigamiObject : MonoBehaviour {

    private static int ActualID = 0;

    public List<string> Tags = new List<string>();

    public int EditorID
    {
        get { return _EditorID; }
    }
    private int _EditorID = 0;

    [HideInInspector()]
    public new Transform transform;

    public virtual bool IsActive
    {
        get
        {
            return enabled;
        }
    }

    protected virtual void Awake()
    {
        transform = GetComponent<Transform>();
    }

    protected virtual void Reset()
    {
    }

    protected virtual void EditorLoad()
    {
    }

    protected virtual void EditorInit()
    {
        _EditorID = ActualID++;
    }

    protected virtual void EditorUpdate()
    {
    }

    protected virtual void EditorReset()
    {
    }

}
