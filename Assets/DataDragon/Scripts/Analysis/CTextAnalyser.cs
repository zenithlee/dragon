using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;

public class CWord {
	public string sWord;
	public string POS = "n";  //a,n,v,r part of speech, noun, verb, adjective
	public float Sentiment = 0.5f;  //0 is negative, 1 is positive, 0.5 is neutral
	public string sDefinition = "";

	public CWord( string inWord, float inSentiment, string inPOS, string inDefinition )
	{
		sWord = inWord;
		Sentiment = inSentiment;
		POS = inPOS;
		sDefinition = inDefinition ;
	}
}

public class CTextAnalyser : MonoBehaviour {

	string[] data;
	ArrayList Nodes = new ArrayList();
	float TotalSentiment = 0f;

	public TextAsset RawSentiments;  //POS,sentiment,word,definition

	//string sSentimentFile = "DataDragon/data/sentiments.csv";
	Hashtable Sentiments = new Hashtable();

	public void AnalyseWords( string sBook, string sTitle, string sData )
	{
		Nodes.Clear( );

		sData = PrepareText(sData );

	}

	string PrepareText( string sData ){
		sData = sData.Replace( "\n", " " );
		sData = sData.Replace( "\r", " " );
		sData = sData.Replace( "\"", "" );
		sData = sData.Replace( "'", "" );

		sData = sData.ToLower();
		return sData;
	}

	//bWords = false = split into sentences
	//bWords = true = split into words - creates a lot of nodes
	public void AnalyseText( string sBook, string sTitle, string sData , bool bWords = false )
	{
		//CCluster c = new CCluster( sTitle );

		Nodes.Clear();

		sData = PrepareText ( sData );

		//split text into sentences or complete phrases ';'
		char[] Delimeters;
		if ( bWords == false )
		{
			Delimeters = new char[]{ '.', ';','?','!'};
		}
		else{
			Delimeters = new char[]{'.',';','?','!',' '};
		}

		data = sData.Split( Delimeters, System.StringSplitOptions.RemoveEmptyEntries );
		CLog.d ( tag, "Analysing  " + data.Length + " sentences." );

		TotalSentiment = 0;
		for( int i=0; i< data.Length; i++ )
		{
			string sPhrase = data[i];
			sPhrase = sPhrase.Trim( );

			string[] PhraseArray = sPhrase.Split( ' ' );
			float sent = GetSentimentForPhrase( PhraseArray );
			TotalSentiment += sent;
			
			Hashtable obj = new Hashtable();
			obj.Add ( CDataNode.FIELD_RANK, i );
			obj.Add ( CDataNode.FIELD_GROUP, sTitle );
			obj.Add ( CDataNode.FIELD_USER, sBook );
			obj.Add ( CDataNode.FIELD_SENTIMENT, sent );
			obj.Add ( CDataNode.FIELD_TEXT, sPhrase );
			obj.Add ( CDataNode.FIELD_LENGTH, PhraseArray.Length );

			Nodes.Add( obj );
		}

		TotalSentiment = TotalSentiment/(float)data.Length;


		SendMessageUpwards( "SpawnNodes", Nodes );
		
		//return c;
	}
	
	public float GetSentimentForPhrase(string[] w ){

		float sent = 0.0f;
		
		for ( int i= 0; i< w.Length; i++ ){

			if ( w[i] == "" ) continue;
			if ( w[i] == " " ) continue;
			if ( w[i] == "." ) continue;
			sent += GetSentimentForWord( w[i] );
		}
		
		sent = sent / (float)w.Length;
		sent = Mathf.Min ( sent, 1 );
		return sent;
	}
	
	public float GetSentimentForWord( string s ){
		float sent = 0.5f;
		s = s.Trim();

		if ( Sentiments.ContainsKey( s ) )
	    {
			CWord w = (CWord)Sentiments[s];
			sent = w.Sentiment;
		}

		return sent;		
	}

	void LoadSentiments( ){

		string ss = RawSentiments.text;
		string[] rawsentiments = ss.Split( '\n' );

		for ( int i= 0; i< rawsentiments.Length; i++ ){
			string[] ssentimentarray = rawsentiments[i].Split( ',' );
			if ( ssentimentarray.Length < 3 ) continue;

			string POS = ssentimentarray[0];
			float sentiment = 0.5f;
			string sSentiment = ssentimentarray[1];
			float.TryParse( sSentiment, out sentiment );
			string sWord = ssentimentarray[2];
			string sDefinition = ssentimentarray[3];

			CWord w = new CWord( POS, sentiment, sWord, sDefinition );
			if ( Sentiments.ContainsKey( sWord ) ) 
			{
				Sentiments[sWord] = w;
			}
			else
			{
				Sentiments.Add( sWord, w );
			}
		}

		CLog.d( tag,  "Loaded " + rawsentiments.Length + " sentiments" );
	}

	public static Dictionary<string,int> GetWordFrequencies( string sText )
	{
		//var words = new Dictionary<string, int>(StringComparer.CurrentCultureIgnoreCase);
		Dictionary<string,int> words = new Dictionary<string, int>(StringComparer.CurrentCultureIgnoreCase);

		//private void countWordsInFile(string file, Dictionary<string, int> words)

			//var content = File.ReadAllText(file);
			
			var wordPattern = new Regex(@"\w+");
			
			foreach (Match match in wordPattern.Matches(sText))
			{
				int currentCount=0;

				words.TryGetValue(match.Value, out currentCount);
				
				currentCount++;
				words[match.Value] = currentCount;
			}
		return words;
	}


	// Use this for initialization
	void Start () {

		LoadSentiments( );
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
