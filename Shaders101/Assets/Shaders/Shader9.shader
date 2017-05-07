Shader "UniteAsia/Shader09" 
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white"{}
	}

    SubShader 
	{
		Tags { "RenderType"="Opaque" }
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert

		sampler2D _MainTexture;

		struct Input
		{
			float2 uv_MainTexture;
		};

		void vert(inout appdata_full v)
		{
			v.vertex.xyz += v.normal * (sin(_Time.y) + 1) * 0.01;
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTexture, IN.uv_MainTexture).rgb;
		}
		ENDCG
		
    }
}
