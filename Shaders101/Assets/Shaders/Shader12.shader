Shader "UniteAsia/Shader12" 
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white"{}
		_AplhaTexture("Alpha Texture", 2D) = "white" {}
	}

    SubShader 
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma surface surf Lambert alpha:fade

		sampler2D _MainTexture;
		sampler2D _AlphaTexture;

		struct Input
		{
			float2 uv_MainTexture;
			float2 uv_AlphaTexture;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			half4 c = tex2D(_MainTexture, IN.uv_MainTexture);
			o.Albedo = c.rgb;
			o.Alpha = 1;//c.a * tex2D(_AlphaTexture, IN.uv_AlphaTexture).a;
		}
		ENDCG
		
    }
}
