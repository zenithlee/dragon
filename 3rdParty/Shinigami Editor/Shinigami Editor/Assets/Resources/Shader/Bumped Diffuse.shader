Shader "Shinigami/Bumped Toon Diffuse"
{
	Properties
	{
		_MainTex ("Sprite Texture (A=Alpha)", 2D) = "white" {}
		_BumpSpec ("(RG = Norm) (B = Spec) (A = Illumn)", 2D) = "gray" {}

		_Params ("(R=Brightness) (G=Brightness) (B=Shades) (A=Outline)", Vector) = (0,0.078125,0.11,1)
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="AlphaTest" 
			"IgnoreProjector"="True" 
			"RenderType"="TransparentCutOut" 
			
		}
		LOD 300
		CGPROGRAM

		#include "Shinigami.cginc"
		#pragma surface surf Toon  

		sampler2D _MainTex;
		sampler2D _BumpSpec;
		fixed4 _Params;

		struct Input
		{
			float2 uv_MainTex;
		};
		
		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;

			o.Alpha = c.a;

			fixed4 BumpSpec = tex2D(_BumpSpec, IN.uv_MainTex);
			o.Normal.xy = (BumpSpec.xy * 2 -1);
			o.Normal.z = sqrt( 1- (o.Normal.x * o.Normal.x - o.Normal.y * o.Normal.y));

			o.Specular = _Params.b;
			o.Gloss = _Params.g*BumpSpec.b;
			o.Emission = o.Albedo * BumpSpec.w * _Params.r;
		}
		ENDCG
	}

Fallback "Bumped Specular"
}
