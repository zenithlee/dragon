using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using SimpleJSON;  

/**
 * 
 * Cardinality - number of unique values
 * 
 * 
 * */

public class CDatabase : MonoBehaviour {

	CFileDialog dialog = new CFileDialog();

	public string ServiceURL = "http://www.skydeals.co.za/services/sentient/f.php?";
	public string User = "dragon";
	public string Pass = "sentient";
	string RawData = "";

	public int RangeStart = 0;
	public int RangeEnd = 1000;
	public string Keywords = "";

	string sDefaultGroup = "A"; //loads new data with this group tag

	// Use this for initialization
	void Start () {
		tag = "CDatabase";
	}


	public void ClearAll( ){
		RawData = "";
	}

	public void SetDefaultGroup( string s ) {
		sDefaultGroup = s;
	}
	public string GetDefaultGroup( ){
		return sDefaultGroup;
	}

	//data is loaded from WWW JSON service
	//dragon is notified, which then calls SpawnVis below to create the nodes 
	IEnumerator GetSomeData() { 

		string FullURL = ServiceURL + "f=gettweets&user=" + User+ "&pass=" + Pass + "&group=user&rangestart=" + RangeStart + "&rangeend=" + RangeEnd + "&keywords=" + Keywords ; 
		Debug.Log ( FullURL + "...." );
		WWW www = new WWW(FullURL);
		yield return www;
		RawData = www.text;
		Debug.Log ( RawData );
		
		SendMessageUpwards("SentientNewData"); 
	}

	//load a log file  TIME,TAG,DESCRIPTION
	public void LoadLogFile() {
		string sFile = dialog.LoadFile();
		CLog.d ( tag, "Loading log file:" + sFile );

		//log files don't usually have headers, so create one here
		//2014-09-23 00:06:22,TAG,USER:364,EMAIL:nazeem.r@gmail.com,ROUTE:,IP:105.236.209.220
		string sHeader = "Time,TAG,User,Email,Route,IP\n"; 

		Hashtable options = new Hashtable();
		options["file"] = sFile ;
		options["header"] = sHeader;

		StartCoroutine( "LoadCSVAsync", options );
	}

	//load a book/document into word nodes (slow!)
	public void LoadTextFileParseWords(){
		string sFile = dialog.LoadFile();
		CLog.d ( tag, "Loading file:" + sFile );

		Hashtable options = new Hashtable();
		options["file"] = sFile ;
		options["parsewords"] = true;
		
		StartCoroutine( "LoadAsync", options );
	}

	//load a book/document into sentence nodes
	public void LoadFile( ){

		string sFile = dialog.LoadFile();
		CLog.d ( tag, "Loading file:" + sFile );

		Hashtable options = new Hashtable();
		options["file"] = sFile ;
		options["parsewords"] = false;


		StartCoroutine( "LoadAsync", options );
	}

	IEnumerator LoadAsync( Hashtable options ){

		string sFile = (string)options["file"];
		bool bWords = (bool)options["parsewords"];
		WWW www = new WWW("file://" + sFile );
		yield return www;

		string s = www.text;
		CLog.d ( tag, "Loaded:" + sFile + "(" + s.Length + " bytes)" );

		CTextAnalyser TextAn = GetComponent<CTextAnalyser>();
		if ( TextAn == null ){
			CLog.d ( tag, "ERROR: no CTextAnalyser component" );
		}
		else {

			//strip name from sFile 
			string sName = sFile;
			int li  = sFile.LastIndexOf( "\\" );				
			if ( li != -1 ) {
				sName = sFile.Substring( li+1, sFile.Length-(li+1) );
			}

			TextAn.AnalyseText( sName, sFile, s, bWords );
		}

		SendMessageUpwards( "SentientDataDone" );
	}

	public void LoadCSV( string row ) {
		string sFile = dialog.LoadFile();
		CLog.d ( tag, "LoadCSV:" + sFile );

		Hashtable options = new Hashtable();
		options["file"] = sFile;

		StartCoroutine( "LoadCSVAsync", options );
		//LoadCSVAsync( sFile );
	}

	IEnumerator LoadCSVAsync( Hashtable options ){

		string sFile = (string)options["file"];
		if ( sFile == "" ) yield return true;
		string sHeader = (string)options["header"];

		WWW www = new WWW("file://" + sFile ); 
		yield return www;
		
		string s = sHeader + www.text;
		CLog.d ( tag, "Loaded:" + sFile + "(" + s.Length + " bytes)" ); 
		
		//strip name from sFile 
		string sName = sFile;
		int li  = sFile.LastIndexOf( "\\" );				
		if ( li != -1 ) {
				sName = sFile.Substring( li+1, sFile.Length-(li+1) );
		}

		ParseCSV( sName, s );
	}

	public void ParseCSV( string sName, string s ){

	string[] row = s.Split( '\n' );
	
	string[] headers = row[0].Split( ',' );

	//get the frequencies
	//Dictionary<string,int> freq = CTextAnalyser.GetWordFrequencies( s );
	
	for ( int r=1; r< row.Length; r++ ) {
		
		string[] fields = row[r].Split( ',' );
		if ( fields.Length <=0 ) continue;

		float total = 0;
		
		Hashtable obj = new Hashtable();
		
		//TODO: string fields with comma names "hello,kitty" get delimeted incorectly, parse strings, replace "xy,xy" with "xy_xy"
		for ( int i=0; i< fields.Length; i++ ){
				string sHeader = "";
				if ( i < headers.Length ) sHeader = headers[i];
				string sField = fields[i];
				obj[sHeader] = sField;			
			
			if ( i > 0 ) {
				float fvalue = 0;
				float.TryParse( sField, out fvalue );
				if ( float.IsNaN(fvalue) ) fvalue = 0;
				total  += fvalue;
			}
		}
		
		CLog.d ( tag, "Loading line " + r );		

		obj.Add( CDataNode.FIELD_RANK, r );
		obj.Add ( CDataNode.FIELD_GROUP, headers[0] );
		obj.Add( CDataNode.FIELD_USER, fields[0] );
			float mean = (float)total / (float)(fields.Length-1); //-1 because of label column
		obj.Add( CDataNode.FIELD_MEAN, mean );
		
		SendMessageUpwards( "SpawnNode", obj );
		
	}
	
	SendMessageUpwards( "SentientDataDone" );
	}


	public string Strip( string s )
	{
		s = s.Replace( "\"", "" );
		s = s.Replace( "\"", "" );
		return s;
	}

	//create visible nodes for the loaded data.
	//data is appended to the view
	public void SpawnVis( Transform tNode, Transform tParent ){
		var N = JSONNode.Parse( RawData );

		if ( N== null ) 
		{
			SendMessageUpwards( "Error", "Error accessing Database. Check network connection"  );
		}
		string sPrev = "";
		int rank = 0;

		foreach( var key in N.Keys )
		{
			if ( key == "twitter" )
			{
				var o = N["twitter"] ;
				if ( o == null ) continue;
				foreach( var okey in o.Childs )
				{
					//Debug.Log ( okey.ToString() );
					string sCurrent = okey["user"].ToString();
					if ( sPrev.CompareTo(sCurrent) == 0 ) rank++; else rank = 0;
					//Debug.Log (sPrev + " : " + sCurrent + " rank:" + rank );
					sPrev = sCurrent;

					Hashtable obj = new Hashtable();

					foreach( string item in okey.Keys )
					{
						obj.Add ( Strip(item), Strip(okey[item]) );
					}

					obj.Add( CDataNode.FIELD_RANK, rank );
					obj.Add ( CDataNode.FIELD_GROUP, sDefaultGroup );

					SendMessageUpwards( "SpawnNode", obj );
				}
			}
		}

		SendMessageUpwards( "SentientDataDone" ) ;
	}

	// Update is called once per frame
	void Update () { }

	public void UpdateData(int inRangeStart, int inRangeEnd, string inKeywords ){
		RangeStart= inRangeStart;
		RangeEnd = inRangeEnd;
		Keywords = inKeywords;
		StartCoroutine("GetSomeData");
	}

	public void DumpRaw( ){
		Debug.Log ( RawData );
	}
}
