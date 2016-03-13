using UnityEngine;
using System.Collections;

public class CLog {

	ArrayList LogList = new ArrayList();

	static UnityEngine.UI.Text Output;

	static CLog Instance;

	public CLog(){
		Instance = this;
	}
	public static CLog GetInstance( ){
		if ( Instance == null ) {
			Instance = new CLog( );
		}
		return Instance;
	}

	public static void SetOutput( UnityEngine.UI.Text t ){
		Output  = t;
	}

	public static void Log( string TAG, string Data ) {

		CLog clog = CLog.GetInstance();
		clog.AddLog( TAG, Data );

		if ( Output.text.Length > 512) {
			clog.LogList.RemoveAt( 0 );
			Output.text.Remove( 0, 32 );
		}


		if ( Output != null ) Output.text += TAG + " : " + Data + "\n";
	}

	public static void d( string TAG, string Data ) {
		
		CLog.Log ( TAG, Data );
	}

	public void AddLog( string TAG, string Data ){

		LogList.Add( TAG + "::" + Data );
	}

	public void Dump( ){

		for ( int i = 0; i< LogList.Count; i++ )
		{
			Debug.Log ( LogList[i]  + "\n" );
		}
	}

	public void DumpToView( UnityEngine.UI.Text v ){
		
		for ( int i = 0; i< LogList.Count; i++ )
		{
			v.text +=  LogList[i] + "\n";
		}
	}

}
