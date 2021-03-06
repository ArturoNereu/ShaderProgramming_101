﻿Shader "UniteAsia/Shader13" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

    SubShader 
	{
		Tags { "Queue"="Transparent" "RenderType" = "Transparent" "IgnoreProjector"="True" }

		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma surface surf Lambert alpha:fade
      
		struct Input 
		{
			float2 uv_MainTex;
			float3 worldPos;
		};

		sampler2D _MainTex;
    
		void surf (Input IN, inout SurfaceOutput o) 
		{
			clip (frac((IN.worldPos.y+IN.worldPos.z*0.1 * _Time.y * 0.5) * 5) - 0.5);
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * float3(0, 0.5, 0.75);
			o.Alpha = 0.5;	
		}
      ENDCG
    } 
}
