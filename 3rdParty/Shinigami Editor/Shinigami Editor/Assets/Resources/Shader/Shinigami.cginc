struct SurfaceOutputCharacter {
    fixed3 Albedo;
    fixed3 Normal;
    fixed4 AnisoDir;
    fixed3 Emission;
    fixed3 Specular;
    fixed Alpha;
};

		inline half4 LightingToon (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) 
		{
				fixed numShades = s.Specular*20;
				half diff = max (0, dot (lightDir, s.Normal));
				diff = floor( diff * numShades);
				diff = min( diff, numShades-1) / numShades;

				fixed spec = max(0.0, dot(s.Normal, normalize(lightDir + viewDir)));
				spec = step(0.5,pow(spec, (1-s.Specular)*128))*atten*s.Gloss;

				half4 res;				


				res.rgb = ((_LightColor0.rgb * diff) + (_LightColor0.rgb / numShades))*atten*s.Albedo;
				res.rgb += spec;
				
				res.a = s.Alpha+spec;
                return res;
        }

		inline fixed4 LightingToon_PrePass (SurfaceOutput s, half4 light)
		{
			fixed spec = light.a*s.Gloss;
	
			fixed4 c;
			c.rgb = s.Albedo * light.rgb;
			c.rgb += spec;
			c.a = s.Alpha+spec;
			return c;
		}