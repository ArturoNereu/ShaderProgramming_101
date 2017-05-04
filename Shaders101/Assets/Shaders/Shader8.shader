Shader "UniteAsia/Shader08" 
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white"{}
	}

    SubShader 
	{
		Tags { "RenderType"="Opaque" }
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTexture;

		struct Input
		{
			float2 uv_MainTexture;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTexture, IN.uv_MainTexture).rgb;
		}
		ENDCG
		
    }
}
