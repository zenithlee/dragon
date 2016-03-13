using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public delegate CDataNode Spawner(Hashtable hash);

public class CRandom  {

	public static void GenerateR1( List<CDataNode> nodes, Spawner Spawn, float meanrange, float sentimentrange ){

		int Rank = 0;
		for (int i = 0; i< 100; i++) {
			
			Hashtable ar = new Hashtable();
			ar.Add( "user", "Name" );
			ar.Add( "tweet", "Text" );
			ar.Add( "rank", 0 );
			ar.Add( CDataNode.FIELD_SENTIMENT, 0.5f ); 
			ar.Add( CDataNode.FIELD_POPULARITY, 1.0f ); 
			ar.Add( "keywords", "general" );
			
			Rank++;
			if ( Rank > Random.value * 10 ) Rank = 0;
			ar[CDataNode.FIELD_RANK] = Rank;
			ar[CDataNode.FIELD_MEAN] = Random.value * meanrange;
			ar[CDataNode.FIELD_FAVORITED] = Random.value * meanrange;
			ar[CDataNode.FIELD_RETWEETS] = Random.value * meanrange;
			ar[CDataNode.FIELD_POPULARITY] = Random.value * meanrange;
			ar[CDataNode.FIELD_SENTIMENT] = Random.value * sentimentrange; 
			Spawn( ar );
			//node.SetColour( ColorWheel( Rank, TotalRank ));
		}

	}
}
