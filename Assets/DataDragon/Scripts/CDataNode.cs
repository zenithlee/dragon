using UnityEngine;
using System.Collections;

public class CDataNode : MonoBehaviour {

	bool Awake = true;

	public static string FIELD_GROUP = "cluster_group";
	public static string FIELD_USER = "user";
	public static string FIELD_SENTIMENT = "sentiment";
	public static string FIELD_TEXT = "text";
	public static string FIELD_LENGTH = "length";
	public static string FIELD_RANK = "rank";
	public static string FIELD_POPULARITY = "popularity";
	public static string FIELD_FAVORITED = "favorited";
	public static string FIELD_RETWEETS = "retweets";
	public static string FIELD_MEAN = "mean";
	public static string FIELD_FREQUENCY = "frequency";
	public static string FIELD_KEYWORDS = "keywords";
	public static string GROUPA = "A";
	public static string GROUPB = "B";
	public static string GROUPC = "C";
	public static string GROUPD = "D";

	public Vector3 TargetPos = Vector3.zero ;
	public Vector3 TargetScale = Vector3.one;
	public float Speed = 1f;

	public string sHeading = "";
	public string sSubHeading = "";

	public Transform Geometry; 
	public Color OriginalColor = new Color( 0.9f, 0.1f, 0.1f );

	Hashtable Fields = new Hashtable();

	// Use this for initialization
	void Start () {
		this.tag = "CDataNode";
		TargetPos = this.transform.localPosition;
	}

	//returns a float from the field hashtable, or the default value if the field does not exist
	public float GetFloatField( string sKey, float defvalue = 0 )
	{
		float f = defvalue;
		if ( Fields.ContainsKey( sKey ) ) 
		{
			object o = Fields[sKey];
			if ( o is string ) 
			{
				string sf = (string)o; 
				if ( sf != null )
				{
					float.TryParse( sf, out f );
					if ( float.IsNaN( f ) ) f = 0;
				}
			}
			else if ( o is float ){
				f = (float)o;
			}
			else if ( o is int) {
				f = (int)o;
			}
		}
		return f;
	}

	//returns an integer from the field hashtable, or the default value if the field does not exist
	public int GetIntField( string sKey, int defvalue = 0 )
	{
		int f = defvalue;
		if ( Fields.ContainsKey( sKey ) ) 
		{
			object o = Fields[sKey];
			if ( o is int ) 
			{
				f = (int)o;
			}
			else
			{
				string sf = (string)o; 
				if ( sf != null )
				{
					int.TryParse( sf, out f );
				}
			}
		}
		return f;
	}


	public void SetFloatField( string sKey, float value )
	{
		if ( Fields.ContainsKey( sKey ) ) Fields[sKey] = value;
		else
		Fields.Add(sKey, value);
	}

	public void SetTextField( string sKey, string value )
	{
		if ( Fields.ContainsKey( sKey ) ) Fields[sKey] = value;
		else
			Fields.Add(sKey, value);
	}

	public string GetTextField( string sKey, string sDefValue )
	{
		if ( Fields.ContainsKey( sKey ) ) {
			return (string)Fields[sKey];
		}
		else
		{
			return sDefValue;
		}
	}

	public void SetFields( Hashtable hash ){
		Fields = hash;
	}

	public string GetFieldSummary(  )
	{
		string sFields = "";
		foreach( string Key in Fields.Keys )
		{
			sFields += Key + ":" + Fields[Key] + "\n";
		}
		return sFields;
	}

	public void MoveTo( Vector3 v ){
		TargetPos = v;
		Wakeup();
	}
	public void MoveBy( Vector3 v ){
		TargetPos += v;
		Awake = true;
	}
	public void MoveXTo( float nx ){
		TargetPos.x = nx;
		Wakeup();
	}
	public void MoveYTo( float ny ){
		TargetPos.y = ny;
		Wakeup();
	}
	public void MoveZTo( float nz ){
		TargetPos.z = nz;
		Wakeup();
	}

	public float DistanceTo( Vector2 v ){
		float d = Vector3.Distance( transform.localPosition, v );
		return d;
	}

	public void Reset( ){
		//SetColour( OriginalColor );
		SetScale ( 1 );
		Wakeup();
	}

	public void SetOriginalColour( Color c ) {
		OriginalColor = c;
		Geometry.GetComponent<Renderer>().material.color = c;
	}

	public void SetColour( Color c ){
		Geometry.GetComponent<Renderer>().material.color = c;
	}
	public void SetScale( float f ) {
		TargetScale = new Vector3( f, f, f );
		Wakeup();
	}
	public void AddScale( float f ) {
		TargetScale += new Vector3( f, f, f );
		Wakeup();
	}
	public void AddScale( Vector3 v ) {
		TargetScale += v;
		Wakeup();
	}
	public void MultiplyScale( Vector3 v ) {
		TargetScale = Vector3.Scale( TargetScale, v ) ;  
		Wakeup();
	}

	void ShowLabel( bool show )
	{
		Transform t = transform.FindChild( "Label" );
		t.gameObject.SetActive( show );
	}

	void OnMouseEnter( ){
		Wakeup ();
		ShowLabel( true );
		SendMessageUpwards( "HoverMe", this );
	}

	void OnMouseExit( ){
		ShowLabel( false );
	}

	public void SetText( string insHeading, string insSub ){

		sHeading = insHeading;
		sSubHeading = insSub;

		Transform label = transform.FindChild( "Label" );
		Transform t = label.FindChild( "Heading" );
		TextMesh tm = t.GetComponent<TextMesh>( );
		tm.text = sHeading + " (" + GetIntField(CDataNode.FIELD_RANK) + ")";

		t = label.FindChild( "SubHeading" );
		tm = t.GetComponent<TextMesh>( );
		tm.text = sSubHeading ;
		Awake = true;
	}

	void Wakeup( ){
		this.enabled = true;
		Awake = true;
		Collider c = GetComponent<Collider>( );
		if ( c != null ){
			c.enabled = false;
		}
	}

	void GotoSleep() {
		Awake = false;
		this.enabled = false;
		Collider c = GetComponent<Collider>( );
		if ( c != null ){
			c.enabled = true;
		}
	}

	void OnMouseUpAsButton() { 
			//SendMessageUpwards( "FocusOnNode", transform );
	}
	
	// Update is called once per frame
	void FixedUpdate () {

		this.transform.localScale = Vector3.Lerp( this.transform.localScale, TargetScale, Time.deltaTime * Speed );

		if ( Awake ){
			this.transform.localPosition = Vector3.Lerp( this.transform.localPosition, TargetPos, Time.deltaTime * Speed );

			Vector3 v = this.transform.localPosition - TargetPos;
			Vector3 vs = this.transform.localScale - TargetScale;
			if ( v.magnitude + vs.magnitude <= 0.02f )
			{
				//CLog.d ( tag, "Sleepy" );
				GotoSleep();
			}
		}
	}
}
