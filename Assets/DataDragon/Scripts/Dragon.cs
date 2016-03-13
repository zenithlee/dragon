//Data Relationship Analysis (with) Graphically Ordered Nodes

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
//using System.Linq;

namespace Dragon2 {

public class Dragon : MonoBehaviour { 

	string RawData;
	public Transform NodeHolder;
	public Transform NodePrefab;

	public Transform LabelHolder;
	public Transform LabelPrefab;

	public Transform CentroidA;
	public Transform CentroidB;
	public Transform BoundsBox;
		public List<Transform> Centroids = new List<Transform>();

	enum GroupingModes {GROUPINGMODE_LINEAR, GROUPINGMODE_SQUAD, GROUPINGMODE_STACKED, GROUPINGMODE_COLOURED, GROUPINGMODE_SCALED, GROUPINGMODE_GRAPHED };
	GroupingModes GroupingMode = GroupingModes.GROUPINGMODE_SQUAD;

	enum PopularityActions {POPULARITYACTION_NONE, POPULARITYACTION_SCALE, POPULARITYACTION_COLOUR};
	PopularityActions PopularityAction = PopularityActions.POPULARITYACTION_NONE;

	enum RankActions {RANKACTION_NONE, RANKACTION_SCALE, RANKACTION_COLOUR};
	RankActions RankAction = RankActions.RANKACTION_NONE;

	enum SentimentActions {SENTIMENTACTION_NONE, SENTIMENTACTION_SCALE, SENTIMENTACTION_COLOUR};
	SentimentActions SentimentAction = SentimentActions.SENTIMENTACTION_NONE;
	float SentimentScale = 2;

	enum ClusterActions {CLUSTERACTION_NONE, CLUSTERACTION_GROUP, CLUSTERACTION_SENTIMENT, CLUSTERACTION_KMEANS};
	ClusterActions ClusterAction = ClusterActions.CLUSTERACTION_NONE;
	bool ClusterDirty = false;


	int NodeCount = 0;
	int TotalRank = 1;
	int HighestPopularity = 0;

	public float RankScale = 2;
	public float GraphScaleMax = 10;
	public UnityEngine.UI.Slider RankScaleSlider;
	//public UnityEngine.UI.Slider SentimentScaleSlider;

	public UnityEngine.UI.Text NodeHeading ; 
	public UnityEngine.UI.Text NodeSubHeading ;
	public UnityEngine.UI.Text StatusText;
	public UnityEngine.UI.Text LogText;

	public UnityEngine.UI.InputField NodeRangeStart;
	public UnityEngine.UI.InputField NodeRangeEnd;
	public UnityEngine.UI.InputField NodeKeywords;

	public UnityEngine.UI.InputField ScriptField;

	public UnityEngine.UI.Text DataText;

		public UnityEngine.UI.Image PlotPanel;
		public GameObject ButtonPrototype;

	public Bounds bounds = new Bounds();
	public Transform Centroid;

	public Vector3 SpacingVector = new Vector3( 0.8f, 0.35f, 0.8f );

	public CCamera MainCamera;

	CDatabase Database;
	List<CDataNode> Nodes = new List<CDataNode>();

	public Color GroupAColour = new Color();
	public Color GroupBColour = new Color();
	public Color GroupCColour = new Color();
	public Color GroupDColour = new Color();

	public Vector3 GroupAPos = new Vector3( 0,0,0 );
	public Vector3 GroupBPos = new Vector3( 0,0,20 );
	public Vector3 GroupCPos = new Vector3( 0,0,40 );


	//scripter
	//CScriptHandler ScriptHandler;

	// Use this for initialization
	void Start () { 
		Database = GetComponent<CDatabase>( );

		tag = "Dragon";
		CLog.SetOutput( LogText );
	}

	public void ClearLabels( )
	{
		while ( LabelHolder.childCount >0 )
		{
			Transform t= LabelHolder.GetChild(0);
			t.SetParent( null );
			GameObject.Destroy( t.gameObject );
		}
	}

	public void ClearAll( ){

		bounds.SetMinMax( Vector3.zero, Vector3.zero );
		Database.ClearAll();
		Nodes.Clear();

		while ( NodeHolder.childCount >0 )
		{
			Transform t= NodeHolder.GetChild(0);
			t.SetParent( null );
			GameObject.Destroy( t.gameObject );
		}

		ClearLabels( );
		UpdateLayoutDelayed();
	}

	void Status( string s )
	{
		StatusText.text = s;
	}

	#region Labels
	public void AddLabel( string sCaption, Vector3 pos )
	{
		Transform t = Instantiate( LabelPrefab, Vector3.zero, Quaternion.identity ) as Transform;
		CLabel label = t.GetComponent<CLabel>( );
		t.SetParent( LabelHolder );
		label.SetText( sCaption );
		label.MoveTo( pos );
	}
	#endregion

	#region data procession functions

	private static int SortByRank(CDataNode o1, CDataNode o2) {
		
		float s1 = o1.GetFloatField( CDataNode.FIELD_RANK );
		float s2 = o2.GetFloatField( CDataNode.FIELD_RANK );
		return s1.CompareTo(s2);
	}

	private static int SortByGroup(CDataNode o1, CDataNode o2) {
		
		string s1 = o1.GetTextField( CDataNode.FIELD_GROUP, CDataNode.GROUPA );
		string s2 = o2.GetTextField( CDataNode.FIELD_GROUP, CDataNode.GROUPB );
		return s1.CompareTo(s2);
	}

	private static int SortBySentiment(CDataNode o1, CDataNode o2) {

		float s1 = o1.GetFloatField( CDataNode.FIELD_SENTIMENT )*10;
		float s2 = o2.GetFloatField( CDataNode.FIELD_SENTIMENT )*10;
		return s1.CompareTo(s2);
	}

	private static int SortByMean(CDataNode o1, CDataNode o2) {
		
		float s1 = o1.GetFloatField( CDataNode.FIELD_MEAN )*10;
		float s2 = o2.GetFloatField( CDataNode.FIELD_MEAN )*10;
		return s1.CompareTo(s2);
	}

	public void SortRank( ){
		CLog.d ( tag, "SortRank" );
		Nodes.Sort( SortByRank );
		UpdateLayout( );
	}

	public void SortGroup( ){
		CLog.d ( tag, "SortGroup" );
		Nodes.Sort( SortByGroup );
		UpdateLayout( );
	}
	public void SortSentiment( ){
		CLog.d ( tag, "SortSentiment" );
		Nodes.Sort( SortBySentiment );
		UpdateLayout( );
	}

	public void SortMean( ){
		CLog.d ( tag, "SortMean" );
		Nodes.Sort( SortByMean );
		UpdateLayout( );
	}

	#endregion

	#region SetOptions

	public void CameraTopView( ){
		MainCamera.MoveToTopView( );
	}

	public void ToggleCameraOrtho( ){
		CLog.Log( tag, "ToggleCameraOrtho" );
		Camera.main.orthographic = !Camera.main.orthographic;
	}
	
	public void ToggleCameraAnimated() {
		CLog.Log( tag, "ToggleCameraAnimated" );
		MainCamera.SetAnimated( );
	}
	//popularity
	public void SetPopularityNone( ){
		CLog.Log( tag, "SetPopularityNone" );
		PopularityAction = PopularityActions.POPULARITYACTION_NONE;
		UpdateLayout();
	}
	public void SetPopularityScale() {
		CLog.Log( tag, "SetPopularityScale" );
		PopularityAction = PopularityActions.POPULARITYACTION_SCALE;
		UpdateLayout();
	}
	public void SetPopularityColor() {
		CLog.Log( tag, "SetPopularityColor" );
		PopularityAction = PopularityActions.POPULARITYACTION_COLOUR;
		UpdateLayout();
	}

	//rank
	public void SetRankNone( ){
		RankAction = RankActions.RANKACTION_NONE;
		UpdateLayout();
	}
	public void SetRankScale() {
		RankAction = RankActions.RANKACTION_SCALE;
		UpdateLayout();
	}
	public void SetRankColour() {
		RankAction = RankActions.RANKACTION_COLOUR;
		UpdateLayout();
	}

	//sentiment
	public void SetSentimentNone( ){
		SentimentAction = SentimentActions.SENTIMENTACTION_NONE;
		UpdateLayout();
	}
	public void SetSentimentScale() {
		SentimentAction = SentimentActions.SENTIMENTACTION_SCALE;
		UpdateLayout();
	}
	public void SetSentimentColour() {
		SentimentAction = SentimentActions.SENTIMENTACTION_COLOUR;
		UpdateLayout();
	}


	//groups modes
	public void SetGroupModeLinear(){
		GroupingMode = GroupingModes.GROUPINGMODE_LINEAR;
		MainCamera.Reset( );
		UpdateLayout();
	}

	public void SetGroupModeSquad() {
		GroupingMode = GroupingModes.GROUPINGMODE_SQUAD;
		UpdateLayout();
	}

	public void SetGroupModeStacked(){
		GroupingMode = GroupingModes.GROUPINGMODE_STACKED;
		UpdateLayout();
	}
	public void SetGroupModeColoured(){
		GroupingMode = GroupingModes.GROUPINGMODE_COLOURED;
		UpdateLayout();
	}
	public void SetGroupModeScaled() {
		GroupingMode = GroupingModes.GROUPINGMODE_SCALED;
		UpdateLayout();
	}

	public void SetGroupModeGraphed() {
		GroupingMode = GroupingModes.GROUPINGMODE_GRAPHED;
		UpdateLayout();
	}

	public void RankScaleChanged( ){
		RankScale = RankScaleSlider.value;
		UpdateLayout( );
	}



	//ANALYSIS ====================================================
	//clusteing
	public void SetClusterModeNone() {
		CLog.d ( tag, "SetClusterModeNone" );
		ClearLabels( );
		ClusterAction = ClusterActions.CLUSTERACTION_NONE;
		ClusterDirty = true;
		UpdateLayout( );

	}
	public void SetClusterModeGrouped() {
		CLog.d ( tag, "SetClusterModeGrouped" );
		ClusterDirty = true;
		ClearLabels( );
		ClusterAction = ClusterActions.CLUSTERACTION_GROUP;
		AddLabel( "A", GroupAPos );
		AddLabel( "B", GroupAPos );
		AddLabel( "C", GroupAPos );
		AddLabel( "D", GroupAPos );
		UpdateLayout( );
	}
	public void SetClusterModeSentiment( ){
		CLog.d ( tag, "SetClusterModeSentiment" );
		ClusterDirty = true;
		ClusterAction = ClusterActions.CLUSTERACTION_SENTIMENT;

		ClearLabels( );
		AddLabel( "Negative", GroupAPos );
		AddLabel( "Neutral", GroupBPos );
		AddLabel( "Positive", GroupCPos );

		UpdateLayout( );
	}

	public void SetClusterModeKMeans( ){
		CLog.d ( tag, "SetClusterModeKMeans" );
		ClusterDirty = true;
		ClearLabels( );
		ClusterAction = ClusterActions.CLUSTERACTION_KMEANS;
		AddLabel( "A", GroupAPos );
		AddLabel( "B", GroupBPos );
		UpdateLayout( );
	}

	public void SetGroupDefaultA( ) {
		Database.SetDefaultGroup( CDataNode.GROUPA );
	}
	public void SetGroupDefaultB( ) {
		Database.SetDefaultGroup( CDataNode.GROUPB );
	}
	public void SetGroupDefaultC( ) {
		Database.SetDefaultGroup( CDataNode.GROUPC );
	}
	public void SetGroupDefaultD( ) {
		Database.SetDefaultGroup( CDataNode.GROUPD );
	}

	#endregion

	public void FocusOnNode( Transform t ){
		CLog.d ( tag, "FocusOnNode" );
		MainCamera.MoveTo( t.localPosition );
		MainCamera.LookAt( t.localPosition );
		//MainCamera.Offset = new Vector3( -bounds.extents.y, 5, -bounds.extents.y );
	}

	public void HoverMe( CDataNode node ) { 
		NodeHeading.text = node.sHeading;
		NodeSubHeading.text = node.sSubHeading + " " + node.GetTextField( CDataNode.FIELD_KEYWORDS, "" ) + " R:" + node.GetIntField ( CDataNode.FIELD_RANK, 0 ) + " S:" + node.GetFloatField( CDataNode.FIELD_SENTIMENT, 0.5f );
		//DataText.text = node.sHeading + "\n" + node.Keywords + "\nRank:" + node.Rank + "\nPopular:" + node.Popularity;
		DataText.text = node.GetFieldSummary( );
	}


	public void ArrangeLinear( ){

		float xx = -1;
		float yy = 0;
		float zz = 0;

		for ( int i=0; i< Nodes.Count; i++) 
		{
			CDataNode d = Nodes[i];
			xx++;
			Vector3 v = new Vector3(xx *SpacingVector.x, yy*SpacingVector.y, zz*SpacingVector.z);
			bounds.Encapsulate( v );
			BoundsBox.transform.localScale = bounds.size;
			d.MoveTo(v);
		}
	}

	public void ArrangeSquad( ){
		
		float xx = -1;
		float yy = 0;
		float zz = 0;
		int xsq = (int)Mathf.Sqrt( Nodes.Count ); 
		
		for ( int i=0; i< Nodes.Count; i++) 
		{
			CDataNode d = Nodes[i];
			xx++;
			if ( xx >= xsq ) {
				zz++; 
				xx=0;
			}
			Vector3 v = new Vector3(xx *SpacingVector.x, yy*SpacingVector.y, zz*SpacingVector.z);
			bounds.Encapsulate( v );
			BoundsBox.transform.localScale = bounds.size;
			d.MoveTo(v);
		}
	}

	void UpdateLayout( ){
		//CLog.d ( tag, "UpdateLayout" );

		bounds = new Bounds(Vector3.zero, new Vector3(1, 1, 1));
		float xx = -1;
		float yy = 0;
		float zz = 0;
		//int xsq = (int)Mathf.Sqrt( NodeHolder.childCount ); //the length of one side of a square

		if ( GroupingMode == GroupingModes.GROUPINGMODE_LINEAR ) {
			ArrangeLinear( );
		}

		if  ( GroupingMode == GroupingModes.GROUPINGMODE_SQUAD ){
			ArrangeSquad( );
		}

		
		MainCamera.LookAt( bounds.center );
	}

	#region Clustering

	void DoClusterNodes( ){
		CLog.d ( tag, "DoClusterNodes" );
		if ( ClusterAction == ClusterActions.CLUSTERACTION_GROUP ){
			DoGroupClustering();
		}

		if ( ClusterAction == ClusterActions.CLUSTERACTION_SENTIMENT ){
			
			ClusterBySentiment( );
		}

		ClusterDirty = false;
	}

	void DoGroupClustering( ) {
		CLog.d ( tag, "DoGroupClustering" );
		for ( int i=0; i< NodeHolder.childCount; i++) {
			Transform t = NodeHolder.GetChild(i);
			CDataNode d = t.GetComponent<CDataNode>();
				//d.Group;
				string sGroup = d.GetTextField( CDataNode.FIELD_GROUP, CDataNode.GROUPA );
				if ( sGroup == CDataNode.GROUPA ) d.MoveBy( GroupAPos );
				if ( sGroup == CDataNode.GROUPB ) d.MoveBy( GroupBPos );
		
		}
	}

	public void ClusterBySentiment() {
		CLog.d ( tag, "DoSentimentClustering" );
		for ( int i=0; i< NodeHolder.childCount; i++) {
			Transform t = NodeHolder.GetChild(i);
			CDataNode d = t.GetComponent<CDataNode>();
			//d.Group;

			float fs = d.GetFloatField( CDataNode.FIELD_SENTIMENT );
			if ( float.IsNaN( fs ) ) fs = 0;
			float fSentimentdex = Mathf.Round( fs*100);

			Vector3 v = new Vector3(fSentimentdex* SpacingVector.x , d.transform.localPosition.y , d.transform.localPosition.x );
			d.MoveTo( v );
			bounds.Encapsulate( v );

			//if ( fSentiment < 0.5 ) d.MoveBy( GroupAPos );
			//if ( fSentiment == 0.5 ) d.MoveBy( GroupBPos );
			//if ( fSentiment > 0.5 ) d.MoveBy( GroupCPos );
		}
		BoundsBox.transform.localScale = bounds.size;
	}

	public void ClusterKMeans( )
	{	
		ClusterDirty = true;

		CKMeans km = GetComponent<CKMeans>();
		if ( km == null ) km = gameObject.AddComponent<CKMeans>();
		km.DoKMeans( bounds, Centroids, Nodes );

		//StartCoroutine( "DoKMeansClusteringThreaded" );
	}
		/*
	IEnumerator DoKMeansClusteringThreaded() 
	{
		CLog.d ( tag, "DoKMeansClusteringThreaded" );
			//setup clusters


		if ( ClusterDirty == true ){
			CCluster ClusterA = new CCluster(CDataNode.GROUPA);
			CCluster ClusterB = new CCluster(CDataNode.GROUPB);
			
			ClusterA.SetCentroid( new Vector3( Random.value*bounds.size.x, Random.value*bounds.size.y, Random.value*bounds.size.z ));
			ClusterB.SetCentroid( new Vector3( Random.value*bounds.size.x, Random.value*bounds.size.y, Random.value*bounds.size.z ));


			//do 10 iterations
			for ( int i = 0; i< 10; i++ )
			{
				int cohesion = 0;

				bool bDone = false;
				CLog.Log ( tag, "Starting KMeans K=" + i + " n=" + NodeHolder.childCount );
				for ( int n = 0; n< Nodes.Count; n++ )
				{
					//Transform t = NodeHolder.GetChild(n);
					CDataNode node = Nodes[n];
					float DistA = node.DistanceTo( ClusterA.GetCentroid() );
					float DistB = node.DistanceTo( ClusterB.GetCentroid() );
					
					if ( DistA > DistB ) 
					{
						ClusterA.RemoveMember( node );
						ClusterB.AddMember( node );
					}
					else if ( DistB > DistA )
					{
						ClusterA.AddMember( node );
						ClusterB.RemoveMember( node );
					}
					else
					{
						cohesion++;
					}
				}

				if ( cohesion == 0 ) {
					Debug.Log ( "Cohesian reached at " + i );
				}

				yield return null;
				
				ClusterA.CalculateCentroid();
				ClusterB.CalculateCentroid();
				CentroidA.transform.localPosition = ClusterA.GetCentroid();
				CentroidB.transform.localPosition = ClusterB.GetCentroid();

				ClusterA.FlagMembers( CDataNode.FIELD_GROUP, ClusterA.Group );
				ClusterB.FlagMembers( CDataNode.FIELD_GROUP, ClusterB.Group );
				
				//now move to their cluster place
				for ( int p=0; p< NodeHolder.childCount; p++) {
					Transform t = NodeHolder.GetChild(p);
					CDataNode d = t.GetComponent<CDataNode>();
					string sGroup = d.GetTextField( CDataNode.FIELD_GROUP, CDataNode.GROUPA );
					if ( sGroup == CDataNode.GROUPA ) d.SetColour( GroupAColour );
					if ( sGroup == CDataNode.GROUPB ) d.SetColour( GroupBColour );
					//if ( sGroup == CDataNode.GROUPA ) d.MoveBy( GroupAPos );
					//if ( sGroup == CDataNode.GROUPB ) d.MoveBy( GroupBPos );
				}
				
			}//for ( int i = 0; i< 3; i++ )
			

		} //if ( ClusterDirty = false ){
		

		
		
		//colour code according to cluster
	}
	*/

	#endregion

	#region colorization

	public void ColorizeRank( ){
		CColorizer.ColorByFloatField( Nodes, CDataNode.FIELD_RANK, 0, TotalRank );	
	}

	public void ColorizeGroup( ){
		CColorizer.ColorByTextField( Nodes, CDataNode.FIELD_GROUP );
	}
	public void ColorizeSentiment( ){
		float lowest = CFormulas.LowestValue( Nodes, CDataNode.FIELD_SENTIMENT );
		float highest = CFormulas.HighestValue( Nodes, CDataNode.FIELD_SENTIMENT );
		CColorizer.ColorByFloatField( Nodes, CDataNode.FIELD_SENTIMENT, lowest, highest );
	}
	public void ColorizeMean( ){	
		float highest = CFormulas.HighestValue( Nodes, CDataNode.FIELD_MEAN );
		CColorizer.ColorByFloatField( Nodes, CDataNode.FIELD_MEAN, 0, highest );		
	}
	#endregion

	#region scaling

	public void ScaleBySentiment( float f ) {
		//float highval = CFormulas.HighestValue( Nodes, CDataNode.FIELD_MEAN );
		//sentiment range is always 0-1
		ScaleByValue( f, 1, CDataNode.FIELD_SENTIMENT );
	}

	public void ScaleByMean( float f ){
		float highval = CFormulas.HighestValue( Nodes, CDataNode.FIELD_MEAN );
		ScaleByValue( f, highval, CDataNode.FIELD_MEAN );
	}

	public void ScaleByPopularity( float f ){
		float highval = CFormulas.HighestValue( Nodes, CDataNode.FIELD_POPULARITY );
		ScaleByValue( f, highval, CDataNode.FIELD_POPULARITY );
	}

	public void ScaleByRank( float f ){
		float highrank = CFormulas.HighestValue( Nodes, CDataNode.FIELD_RANK );
		Debug.Log ( f + "," + highrank );
		ScaleByValue( f, highrank, CDataNode.FIELD_RANK );
	}

	public void ScaleByValue( float f, float fmax, string sField ){
		
		for ( int i = 0; i< Nodes.Count; i++ ){
			
			CDataNode node = Nodes[i];
			float value = node.GetFloatField( sField) / fmax;  //value is now int the Range 0-1
			if ( float.IsNaN( value) ) value = 0;
			node.SetScale( 1 );
			node.MultiplyScale( new Vector3( 1, value * f * GraphScaleMax, 1) );
		}
	}

	#endregion

	#region arrangement

		public void ArrangeXClick(string s ){
			Debug.Log ( s );
			float total = Nodes.Count;
			float ftotal = 40/total;
			if ( float.IsInfinity(ftotal) ) ftotal = 0.1f;
			CArranger.ArangeByTextField( Nodes, s, new Vector3( ftotal,0,0) );
		}

		public void ArrangeYClick(string s ){
			Debug.Log ( s );
			float total = Nodes.Count;
			float ftotal = 40/total;
			if ( float.IsInfinity(ftotal) ) ftotal = 0.1f;
			CArranger.ArangeByTextField( Nodes, s, new Vector3( 0,ftotal,0) );
		}

		public void ArrangeZClick(string s ){
			Debug.Log ( s );
			float total = Nodes.Count;
			float ftotal = 40/total;
			if ( float.IsInfinity(ftotal) ) ftotal = 0.1f;
			CArranger.ArangeByTextField( Nodes, s, new Vector3( 0,0,ftotal) );
		}

		public void ArrangeCustom( ){ 

			string sHeader = "Time,TAG,User,Email,Route,IP"; 
			CArranger.CreateTogglesForFields( sHeader, this, "ArrangeXClick", 0, PlotPanel, ButtonPrototype );
			CArranger.CreateTogglesForFields( sHeader, this, "ArrangeYClick", 200, PlotPanel, ButtonPrototype );
			CArranger.CreateTogglesForFields( sHeader, this, "ArrangeZClick", 400, PlotPanel, ButtonPrototype );
		}
			
	  public void ArrangeMean_vs_Sentiment( ){
		float fMean = 1;
		float fSentiment = 10;
		CArranger.ArangeByFloatFields( Nodes, CDataNode.FIELD_MEAN, CDataNode.FIELD_SENTIMENT, new Vector3( fMean, 1, fSentiment ) );
	}

	public void ArrangePopularity_vs_Sentiment( ){
		float fMean = 1;
		float fSentiment = 50;
		CArranger.ArangeByFloatFields( Nodes, CDataNode.FIELD_POPULARITY, CDataNode.FIELD_SENTIMENT, new Vector3( fMean, 1, fSentiment ) );
	}

	public void ArrangeRank_vs_Mean( ){
		float TotalRank = CFormulas.HighestValue( Nodes, CDataNode.FIELD_RANK );
		float TotalMean = CFormulas.HighestValue( Nodes, CDataNode.FIELD_MEAN );
		float fRank = 20/TotalRank;
			if ( float.IsInfinity( fRank ) ) fRank = 0;
		float fMean = 20/TotalMean;
		CArranger.ArangeByFloatFields( Nodes, CDataNode.FIELD_RANK, CDataNode.FIELD_MEAN, new Vector3( fRank, 1, fMean ) );
	}

	public void ArrangeRank_vs_Sentiment( ){

		float TotalRank = CFormulas.HighestValue( Nodes, CDataNode.FIELD_RANK );
		float TotalSentiment = CFormulas.HighestValue( Nodes, CDataNode.FIELD_SENTIMENT );

		float fMean = 20/TotalRank;
			if ( float.IsInfinity( fMean ) ) fMean = 0;
		float fSentiment = 20/TotalSentiment;
			if ( float.IsInfinity( fSentiment ) ) fSentiment = 0;
		CArranger.ArangeByFloatFields( Nodes, CDataNode.FIELD_RANK, CDataNode.FIELD_SENTIMENT, new Vector3( fMean, 1, fSentiment ) );
	}

	



	#endregion

	/*
	 * Spawns nodes from a list of HashTables
	 * */
	void SpawnNodes( ArrayList list ){

		for ( int i = 0; i <list.Count; i++ ){
			Hashtable h = (Hashtable)list[i];
			SpawnNode ( h );
		}

	}

	//a node needs to be spawned from raw data
	//array of keys in the db table
	//0 = user
	//1 = text
	//2 = rank
	//3 = keywords
	CDataNode SpawnNode( Hashtable o ){

		//Status ( "Created node " + DataHolder.childCount ); 

		Vector3 v = new Vector3( NodeCount * 0.5f, 0, 0 );
		Transform t = Instantiate(NodePrefab, v, Quaternion.identity) as Transform;
		CDataNode dn = t.GetComponent<CDataNode>( );
		Nodes.Add( dn ); 
		dn.SetFields( o );
		//int rank = dn.GetIntField( CDataNode.FIELD_RANK );
		string s = "";

		t.SetParent( NodeHolder );
		//t.localPosition = v;
		dn.MoveTo( v );

		string sGroup = Database.GetDefaultGroup();
		dn.SetTextField( CDataNode.FIELD_GROUP, sGroup );
		if ( sGroup == CDataNode.GROUPA ) {
			dn.SetOriginalColour( GroupAColour );
		} else 
		if ( sGroup == CDataNode.GROUPB ) {
			dn.SetOriginalColour( GroupBColour );
		} else
		if ( sGroup == CDataNode.GROUPC ) {
			dn.SetOriginalColour( GroupCColour );
		} else 
		if ( sGroup == CDataNode.GROUPD ) {
			dn.SetOriginalColour( GroupDColour );
		}

		string sUser = dn.GetTextField( CDataNode.FIELD_USER, "User" );
		string sText = dn.GetTextField( CDataNode.FIELD_TEXT, "Text" );

		dn.SetText( sUser, sText);
		if ( o[CDataNode.FIELD_FAVORITED] != null ) s = o[CDataNode.FIELD_FAVORITED].ToString();
		int favorited  = 0;
		if (( s != null ) && ( s != "" ) && ( s != "null") ){
			favorited = (int)float.Parse(s);
		}
		if ( o[CDataNode.FIELD_RETWEETS] != null ) s = o[CDataNode.FIELD_RETWEETS].ToString();
		int retweets  = 0;
		if ( (s != null) && (s != "" ) && ( s != "null") ){
			retweets = (int)float.Parse(s);
		}

		int popularity = favorited + retweets;
		dn.SetFloatField( CDataNode.FIELD_POPULARITY,  popularity );
        NodeCount++;
		int Rank = dn.GetIntField( CDataNode.FIELD_RANK, 0 );
		TotalRank = Mathf.Max( Rank, TotalRank );
		HighestPopularity = Mathf.Max ( popularity, HighestPopularity );
		return dn;
	}

	//callback when new data arrives
	public void SentientNewData( ){
		CLog.d ( tag, "SentientNewData" );
		Status ( "Data Loaded" );
		//db.DumpRaw( );
		HighestPopularity = 0;
		Database.SpawnVis( NodePrefab, NodeHolder );
		//MainCamera.Reset( );
		//UpdateLayout();
	}
	public void SentientDataDone( ){
		CLog.d ( tag, "SentientDataDone" );
		UpdateLayoutDelayed();
	}

	public void GetTwitter1000() {
		CLog.d ( tag, "GetTwitter1000" );

		Status ( "Loading Data" );

		int RangeStart = 0;

		string sStart = NodeRangeStart.text;
		RangeStart = int.Parse( sStart ); 

		int RangeEnd = 1000;

		string sRangeEnd = NodeRangeEnd.text;
		RangeEnd = int.Parse( sRangeEnd ); 
		string sKeywords = NodeKeywords.text;

		Database.UpdateData( RangeStart, RangeEnd, sKeywords );
	}

	public void CreateDemoRandom100( ){
		CLog.d ( tag, "CreateDemoRandom100" );
		int Rank = 0;

		CRandom.GenerateR1( Nodes, SpawnNode, 20, 1 );
		UpdateLayoutDelayed();
	}

	public void CreateWordDemo( ){
		CLog.d ( tag, "CreateWordDemo" );

		Database.LoadFile();
	}

	public void LoadCSV( ){
		CLog.d ( tag, "LoadCSV" );
		Database.LoadCSV( NodeKeywords.text.ToString() );
	}


	void UpdateLayoutDelayed(){
		CLog.d ( tag, "UpdateLayoutDelayed" );
		Invoke( "UpdateLayout", 0.5f );
	}

	public void ScriptRun( ){
		string s = ScriptField.text;
		//CScriptHandler sh = GetComponent<CScriptHandler>() as CScriptHandler;
		JScriptParser csi = (JScriptParser)GetComponent( "JScriptParser" );
		//JScriptParser csi = GetComponent<JScriptParser>() as JScriptParser;
		try {
		csi.RunScript( this, s );
		} catch( UnityException e ){
			Debug.Log ( e.ToString());
		}
	}

	void Error( string s )
	{

	}	

}
}