using UnityEngine;
using System.Collections;
using System.Collections.Generic;

//colorizes CDataNodes based on fields


public class CColorizer  {

	static string tag = "CColorizer";

	public static Color ColorWheel( float n, float divisor ){
		float nr = n/divisor;
		nr *= 300; //red to blue
		HSLColor c = new HSLColor( nr , 0.5f, 0.5f );
		return c.ToRGBA();
	}

	public static void ColorByFloatField( List<CDataNode> nodes, string sField, float lower, float upper ){

		for ( int n = 0; n< nodes.Count; n++ )
		{
			CDataNode node = nodes[n];
			if ( node == null ) CLog.d ( tag, "WARNING NULL NODE " + n );
			float value = node.GetFloatField( sField, 0 );
			value += lower;
			node.SetColour( ColorWheel( value, upper ));
		}
	}

	public static void ColorByTextField( List<CDataNode> nodes, string sField ){

		ArrayList hash = new ArrayList();
		for ( int n = 0; n< nodes.Count; n++ )
		{
			CDataNode node = nodes[n];
			if ( node == null ) CLog.d ( tag, "WARNING NULL NODE " + n );
			string value = node.GetTextField( sField, "" );
			if ( hash.Contains( value ) ) continue;
			hash.Add( value );
		}

		float Total = hash.Count;

		for ( int n = 0; n< nodes.Count; n++ )
		{
			CDataNode node = nodes[n];
			if ( node == null ) CLog.d ( tag, "WARNING NULL NODE " + n );
			string value = node.GetTextField( sField, "" );
			float Pos = hash.IndexOf( value );
			node.SetColour( ColorWheel( Pos, Total ));
		}
	}

	public static void ColorByGroup( List<CDataNode> nodes, int TotalGroups )
	{	
		for ( int n = 0; n< nodes.Count; n++ )
		{
			CDataNode node = nodes[n];
			if ( node == null ) CLog.d ( tag, "WARNING NULL NODE " + n );
			string value = node.GetTextField( CDataNode.FIELD_GROUP, "" );
			float Pos = value[0]-65;
			node.SetColour( ColorWheel( Pos, TotalGroups ));
		}
	}

}
