
using System.Collections;
using UnityEngine;

//using Microsoft.Win32;
#if UNITY_STANDALONE_WIN
using System.Windows.Forms;
#endif

public class CFileDialog  {

	string tag = "CFileDialog";

	public string LoadFile( ){

		//System.Windows.Forms.Application.Run();

		CLog.d( tag, "LoadFile" );

	#if UNITY_STANDALONE_WIN
		//OpenFileDialog ofd = new OpenFileDialog();
		OpenFileDialog ofd = new OpenFileDialog();
		DialogResult result = DialogResult.No;
		try {
		 result = ofd.ShowDialog();
		} catch ( UnityException e ){
			Debug.Log ( e.Message );
		}

		if ( result == DialogResult.OK ){
			CLog.d ( tag, ofd.FileName );
			return ofd.FileName;
		}
	#endif
		return "";
		//string sOpenPath = EditorUtility.OpenFilePanel("Open Session","","png");

		//OpenFileDialog.ShowDialog();
//		ofg.ShowDialog();
		
	}
	
	void OnApplicationQuit( ){
		#if UNITY_STANDALONE_WIN
		System.Windows.Forms.Application.Exit();
		#endif
	}
}
