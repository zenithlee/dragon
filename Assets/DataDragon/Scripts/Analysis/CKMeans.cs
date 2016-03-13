using UnityEngine;
using System.Collections;
using System.Collections.Generic;

//to setup kmeans:
// set GOCentroids to gameobjects that visualise the centroids
//call DoKMeans( nodes );

public class CKMeans : MonoBehaviour {

	int NumClusters = 4;
	int NumIterationsK = 10;
	List<CCluster> Clusters = new List<CCluster>();
	List<Transform> GOCentroids = new List<Transform>(); //gameobjects used to visualise centroids
	public Bounds bounds = new Bounds();
	List<CDataNode> Nodes = new List<CDataNode>();


	public void DoKMeans( Bounds ibounds, List<Transform> iCentroids, List<CDataNode> iNodes )
	{
		GOCentroids = iCentroids;
		bounds = ibounds;
		Nodes = iNodes;
		SetupClusters();
		StartCoroutine( "DoKMeansClusteringThreaded" );
	}

	void SetupClusters( )
	{
		Clusters.Clear();
		for ( int i = 0; i< NumClusters; i++ )
		{
			char c = (char)(65+i);
			CCluster cluster = new CCluster(c.ToString());
			Clusters.Add( cluster );
			cluster.SetCentroid( new Vector3( Random.value*bounds.size.x, Random.value*bounds.size.y, Random.value*bounds.size.z ));
			//cluster.SetCentroidTransform( GOCentroids[i] );
			cluster.SetCentroidColour( GOCentroids[i], CColorizer.ColorWheel( i, NumClusters ) );

      }
	}

	void RecalculateCentroids( )
	{
		for ( int i = 0; i< Clusters.Count; i++ )
		{
			CCluster cluster = Clusters[i];
			cluster.CalculateCentroid();
			Transform t = (Transform)GOCentroids[i];
			if ( t != null ) t.localPosition = cluster.GetCentroid();
		}
	}

	IEnumerator DoKMeansClusteringThreaded() 
	{
		CLog.d ( tag, "DoKMeansClusteringThreaded" );

		//setup clusters
				
				//do 10 iterations
		for ( int i = 0; i< NumIterationsK; i++ )
		{					
					
					bool bDone = false;
					CLog.Log ( tag, "Starting KMeans K=" + i + " n=" + Nodes.Count );
					for ( int n = 0; n< Nodes.Count; n++ )
					{

						//compare each node to each cluster centroid, finding nearest
						CDataNode node = Nodes[n];
						int closestc = 0;
						float closestdist = 999;
						for ( int c = 0; c< Clusters.Count; c++ )
						{
							CCluster cluster = (CCluster)Clusters[c];
							float dist = node.DistanceTo( cluster.GetCentroid() );
							if ( dist < closestdist ) {
								closestdist = dist;
								closestc = c;
							}
						}

						//remove the node from all clusters except closest c
						for ( int c = 0; c< Clusters.Count; c++ )
						{
							CCluster cluster = Clusters[c];
							if ( c == closestc ) 
							{
								cluster.AddMember( node ) ; 
							}
							else
							{
								cluster.RemoveMember( node );
							}
						}
						
					}
					
					yield return null;

					RecalculateCentroids( );				    
					
			}//for ( int i = 0; i< NumIterationsK; i++ )

		//CColorizer.ColorByTextField( Nodes, CDataNode.FIELD_GROUP );			
		CColorizer.ColorByGroup( Nodes , NumClusters);
			
	}
}
