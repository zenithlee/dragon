using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class CFormulas : MonoBehaviour {

	//variance
	// Add ( xi - xMean) ^2 / N

	/*
	 * Function: logit
	 * Use: Logistic regression model
	 * Description: Provides the 'score' probability of being interested in purchasing certain products
	 * */
	public static float logit( float w, float x, float y, float z )
	{
		float nlogit = 0.985f - (0.005f*w) + (0.019f*x) + (0.122f*y)-(0.002f*z);
		float score = Mathf.Exp( nlogit) / (1+Mathf.Exp( nlogit ) );
		return score;
	}

	public static float HighestValue( List<CDataNode> nodes, string sField ){
		float highest = -99999999;
		for ( int i= 0; i< nodes.Count; i++ ){
			CDataNode n = nodes[i];
			float mean = n.GetFloatField( sField );
			highest = Mathf.Max ( mean, highest );
		}

		return highest;
	}

	public static float LowestValue( List<CDataNode> nodes, string sField ){
		float lowest = 99999999;
		for ( int i= 0; i< nodes.Count; i++ ){
			CDataNode n = nodes[i];
			float mean = n.GetFloatField( sField );
			lowest = Mathf.Min ( mean, lowest );
		}
		
		return lowest;
	}

	public void SortNodes( string sField ){



	}

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
