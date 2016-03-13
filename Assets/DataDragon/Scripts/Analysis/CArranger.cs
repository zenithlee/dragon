using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;

public class CArranger  {

	static string tag = "CArranger";

	public static void ArangeByFloatFields( List<CDataNode> nodes, string sFieldX, string sFieldZ, Vector3 Scaling ){
		
		for ( int n = 0; n< nodes.Count; n++ )
		{
			CDataNode node = nodes[n];
			if ( node == null ) CLog.d ( tag, "WARNING NULL NODE " + n );
			float xvalue = node.GetFloatField( sFieldX, 0 );
			if ( float.IsNaN( xvalue ) ) xvalue = 0;
			float yvalue = 0;
			float zvalue = node.GetFloatField( sFieldZ, 0 );
			if ( float.IsNaN( zvalue )) zvalue = 0;
			node.MoveTo( new Vector3( xvalue * Scaling.x, yvalue*Scaling.y, zvalue*Scaling.z ) );
		}
	}

	//arranges data in a single axis by a sorted text field index.
	// multiple passes are usually required for regression
	// To omit an axis set Scaling to 0
	public static void ArangeByTextField( List<CDataNode> nodes, string sField, Vector3 Scaling ){
		List<string> xv = new List<string>();
		//add values to hash tables
		for ( int n = 0; n< nodes.Count; n++ )
		{
			CDataNode node = nodes[n];
			if ( node == null ) CLog.d ( tag, "WARNING NULL NODE " + n );
			string sval = node.GetTextField( sField, "" );
			if ( !xv.Contains( sval ) ) xv.Add(sval);
		}
		xv.Sort();
		//put nodes based on position in tables
		for ( int n = 0; n< nodes.Count; n++ )
		{
			float value = 0;
			CDataNode node = nodes[n];
			string sval = node.GetTextField( sField, "" );
			value = xv.IndexOf( sval );
			if ( Scaling.x != 0 ) node.MoveXTo( value * Scaling.x );
			if ( Scaling.y != 0 ) node.MoveYTo( value * Scaling.y );
			if ( Scaling.z != 0 ) node.MoveZTo( value * Scaling.z );
		}
	}

	public static void ArangeByTextFields( List<CDataNode> nodes, string sFieldX, string sFieldZ, Vector3 Scaling ){

		List<string> xv = new List<string>();

		List<string> zv = new List<string>(); 

		//add values to hash tables
		for ( int n = 0; n< nodes.Count; n++ )
		{
			CDataNode node = nodes[n];
			if ( node == null ) CLog.d ( tag, "WARNING NULL NODE " + n );
			string sx = node.GetTextField( sFieldX, "" );
			if ( !xv.Contains( sx ) ) xv.Add(sx);
			float yvalue = 0;
			string sz = node.GetTextField( sFieldZ, "" );
			if ( !zv.Contains( sz ) ) zv.Add( sz );
		}

		xv.Sort();
		zv.Sort();

		//sort tables

		//put nodes based on position in tables
		for ( int n = 0; n< nodes.Count; n++ )
		{
			float xvalue = 0;
			float yvalue = 0;
			float zvalue = 0;
			CDataNode node = nodes[n];
			string sx = node.GetTextField( sFieldX, "" );
			xvalue = xv.IndexOf( sx );
			string sz = node.GetTextField( sFieldZ, "" );
			zvalue = zv.IndexOf( sz );

			node.MoveTo( new Vector3( xvalue * Scaling.x, yvalue*Scaling.y, zvalue*Scaling.z ) );
		}
	}

	public static void CreateTogglesForFields( string sHeader, MonoBehaviour ClickHandler, string sCallback, int offset, UnityEngine.UI.Image parent, GameObject ProtoType )
	{
		string[] heads = sHeader.Split( ',' ); 

		for ( int i=0; i< heads.Length; i++ )
		{
			GameObject go = GameObject.Instantiate( ProtoType ) as GameObject;
			string sHead = heads[i];
			Transform tr = go.transform.FindChild( "Text" );
			Text t = tr.GetComponent<Text>();
			if ( t != null ) {
				t.text = heads[i];
			}
			Button b = go.GetComponent<Button>();
			if ( b != null ) {
				b.onClick.AddListener( () => ClickHandler.SendMessage( sCallback , sHead ) );
			}

			go.name = "Button" + i;
			go.transform.SetParent( parent.transform );
			go.transform.localPosition = new Vector3( -200 + offset, 100- (i*35));		
		}
	}
}
