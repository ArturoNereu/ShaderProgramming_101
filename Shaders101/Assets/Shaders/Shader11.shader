Shader "UniteAsia/Shader11" 
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white"{}
		_EmissionTexture("Emission Texture", 2D) = "white" {}
		_EmissionMultiplier("Emission Multiplier", Range(0, 1)) = 0.5
	}

    SubShader 
	{
		Tags { "RenderType"="Opaque" }
		
		CGPROGRAM
		#pragma surface surf Standard

		sampler2D _MainTexture;
		sampler2D _EmissionTexture;
		float _EmissionMultiplier;

		struct Input
		{
			float2 uv_MainTexture;
			float2 uv_EmissionTexture;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			o.Albedo = tex2D(_MainTexture, IN.uv_MainTexture).rgb;
			o.Emission = tex2D(_EmissionTexture, IN.uv_EmissionTexture);// * _EmissionMultiplier;
		}
		ENDCG
		
    }
}
