﻿using UnityEngine;
//using System.Collections;

/*
 * Attach this to the camera
 * 
 * */

public class CGrid : MonoBehaviour {

	public GameObject plane;
	
	public bool showMain = true;
	public bool showSub = false;
	
	public int gridSizeX;
	public int gridSizeY;
	public int gridSizeZ;
	
	public float smallStep = 0.1f;
	public float largeStep;
	
	public float startX;
	public float startY;
	public float startZ;
	
	float offsetY = 0;
	float scrollRate = 0.1f;
	float lastScroll = 0f;
	
	Material lineMaterial;
	
	public Color mainColor = new Color(0f,1f,0f,1f);
	public Color subColor = new Color(0f,0.0f,0.5f,1f);
	
	void Start ()
	{
		
	}
	
	void Update ()
	{
		if(lastScroll + scrollRate < Time.time)
		{
			if(Input.GetKey(KeyCode.KeypadPlus))
			{
				offsetY += smallStep;
				lastScroll = Time.time;
			}
			if(Input.GetKey(KeyCode.KeypadMinus))
			{
				offsetY -= smallStep;
				lastScroll = Time.time;
			}
		}
	}
	
	void CreateLineMaterial()
	{
		
		if( !lineMaterial ) {
			lineMaterial = new Material( "Shader \"Lines/Colored Blended\" {" +
			                            "SubShader { Pass { " +
			                            " Blend SrcAlpha OneMinusSrcAlpha " +
			                            " ZWrite Off Cull Off Fog { Mode Off } " +
			                            " BindChannels {" +
			                            " Bind \"vertex\", vertex Bind \"color\", color }" +
			                            "} } }" );
			lineMaterial.hideFlags = HideFlags.HideAndDontSave;
			lineMaterial.shader.hideFlags = HideFlags.HideAndDontSave;}
	}
	
	void OnPostRender()
	{
		CreateLineMaterial();
		// set the current material
		lineMaterial.SetPass( 0 );
		
		GL.Begin( GL.LINES );
		
		if(showSub)
		{
			GL.Color(subColor);
			
			//Layers
			for(float j = 0; j <= gridSizeY; j += smallStep)
			{
				//X axis lines
				for(float i = 0; i <= gridSizeZ; i += smallStep)
				{
					GL.Vertex3( startX, j + offsetY, startZ + i);
					GL.Vertex3( gridSizeX, j + offsetY, startZ + i);
				}
				
				//Z axis lines
				for(float i = 0; i <= gridSizeX; i += smallStep)
				{
					GL.Vertex3( startX + i, j + offsetY, startZ);
					GL.Vertex3( startX + i, j + offsetY, gridSizeZ);
				}
			}
			
			//Y axis lines
			for(float i = 0; i <= gridSizeZ; i += smallStep)
			{
				for(float k = 0; k <= gridSizeX; k += smallStep)
				{
					GL.Vertex3( startX + k, startY + offsetY, startZ + i);
					GL.Vertex3( startX + k, gridSizeY + offsetY, startZ + i);
				}
			}
		}
		
		if(showMain)
		{
			GL.Color(mainColor);
			
			//Layers
			for(float j = 0; j <= gridSizeY; j += largeStep)
			{
				//X axis lines
				for(float i = 0; i <= gridSizeZ; i += largeStep)
				{
					GL.Vertex3( startX, j + offsetY, startZ + i);
					GL.Vertex3( gridSizeX, j + offsetY, startZ + i);
				}
				
				//Z axis lines
				for(float i = 0; i <= gridSizeX; i += largeStep)
				{
					GL.Vertex3( startX + i, j + offsetY, startZ);
					GL.Vertex3( startX + i, j + offsetY, gridSizeZ);
				}
			}
			
			//Y axis lines
			for(float i = 0; i <= gridSizeZ; i += largeStep)
			{
				for(float k = 0; k <= gridSizeX; k += largeStep)
				{
					GL.Vertex3( startX + k, startY + offsetY, startZ + i);
					GL.Vertex3( startX + k, gridSizeY + offsetY, startZ + i);
				}
			}
		}
		
		
		GL.End();
	}
}
