using UnityEngine;
using System.Collections;

public class CLabel : MonoBehaviour {

	public Vector3 TargetPos ;
	float Speed = 10f;

	public Transform TextNode;

	public void MoveTo( Vector3 v ){
		TargetPos = v;
	}
	// Use this for initialization
	void Start () {

		TextNode = transform.Find( "Text" ) as Transform;	
	}

	public void SetText( string s )
	{
		if ( TextNode != null ) 
		{
			TextMesh tm = TextNode.GetComponent<TextMesh>( );
			tm.text = s;
		}
	}
	
	// Update is called once per frame
	void Update () {
		this.transform.localPosition = Vector3.Lerp( this.transform.localPosition, TargetPos, Time.deltaTime * Speed );	
	}
}
