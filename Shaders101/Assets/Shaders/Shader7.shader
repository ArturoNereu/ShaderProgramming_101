Shader "UniteAsia/Shader07" 
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white"{}
	}

    SubShader 
	{
		Pass
		{
			Tags { "RenderType"="Opaque" }
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #include "UnityCG.cginc"

			sampler2D _MainTexture;

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD1;
			};

            v2f vert(appdata_base v) 
			{
				v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
				return o;
            }

            half4 frag(v2f i) : COLOR 
			{
				half4 color = tex2D(_MainTexture, i.uv);
				return color;
            }
			ENDCG
		}
    }
}
