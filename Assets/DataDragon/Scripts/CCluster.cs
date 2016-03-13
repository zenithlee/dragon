using UnityEngine;
using System.Collections;

public class CCluster  {

	ArrayList Members = new ArrayList();
	Vector3 Centroid = Vector3.zero;
	public string Group;
	public float TempDistance = 0; //temp holder for node under scrutiny

	public CCluster( string sGroup ){
		Group = sGroup;
	}

	public void AddMember( CDataNode node ){
		Members.Add( node );
		node.SetTextField( CDataNode.FIELD_GROUP, Group );
	}

	public void RemoveMember( CDataNode node) {
		if ( Members.Contains( node ) ){
			Members.Remove( node );
		}
	}

	public void FlagMembers( string sFlag, string sLabel ){
		for ( int i = 0; i< Members.Count; i++ ){
			CDataNode node = (CDataNode)Members[i];
			node.SetTextField( sFlag, sLabel );
		}
	}

	public void Clear( ){
		while( Members.Count>0) {
			Members.RemoveAt(0);
		}
	}

	public void SetCentroid( Vector3 v ){
		Centroid = v;
	}

	public Vector3 GetCentroid(  ){
		return Centroid;
	}

	public void SetCentroidColour( Transform t, Color c ){
		t.GetComponent<Renderer>().material.color = c;
	}

	//add up all member positions and divide by total members
	public void CalculateCentroid( ){

		if ( Members.Count == 0 ) 
		{
			Centroid = Vector3.zero;
			return ;
		}

		Vector3 total = Vector3.zero;

		for ( int i = 0; i< Members.Count; i++ ){
			CDataNode node = (CDataNode)Members[i];
			Transform t = node.GetComponent<Transform>( );
			total += t.localPosition;
		}

		Centroid = total / Members.Count;
	}
}
