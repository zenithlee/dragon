Shader "Shinigami/Sprites/Bumped Toon Diffuse"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture (A=Alpha)", 2D) = "white" {}
		_BumpSpec ("(RG = Norm) (B = Spec) (A = Illumn)", 2D) = "gray" {}

		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		_Cutoff ("Alpha Cutoff", Range (0,1)) = 0.5

		_Params ("(R=Brightness) (G=Brightness) (B=Shades) (A=Outline)", Vector) = (0,0.078125,0.11,1)

	}

	SubShader
	{
		Tags
		{ 
			"Queue"="AlphaTest" 
			"IgnoreProjector"="True" 
			"RenderType"="TransparentCutOut" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
			
		}
		LOD 300
		Cull Off	
		CGPROGRAM

		#include "../Shinigami.cginc"
		#pragma surface surf Toon vertex:vert alphatest:_Cutoff 
		#pragma multi_compile DUMMY PIXELSNAP_ON 

		sampler2D _MainTex;
		sampler2D _BumpSpec;
		fixed4 _Params;

		struct Input
		{
			float2 uv_MainTex;
			fixed4 color : COLOR;
		};
		
		void vert (inout appdata_full v, out Input o)
		{
			#if defined(PIXELSNAP_ON) && !defined(SHADER_API_FLASH)
				v.vertex = UnityPixelSnap (v.vertex);
			#endif
			v.normal = float3(0,0,-1);
			v.tangent =  float4(-1, 0, 0, 1);
			
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.color = v.color;
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * IN.color;
			c.rgb -= (1-c.a)*_Params.a;
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

Fallback "Transparent/Cutout/Bumped Specular"
}
