Shader "UniteAsia/Shader10" 
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
			float2 uv = float2(IN.uv_MainTexture.x + _Time.y * 0.2, IN.uv_MainTexture.y);
			o.Albedo = tex2D(_MainTexture, uv).rgb;
		}
		ENDCG
		
    }
}
