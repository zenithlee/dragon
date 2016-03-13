    
    function RunScript ( pDragon, sCode ) {
        var Dragon = pDragon;
        try {
    	eval(sCode, "unsafe");    
    	} catch ( e ){
    		Debug.Log( e.Message );
    		SendMessageUpwards( "Status", e.Message );
    	}
    }