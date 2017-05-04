Shader "UniteAsia/Shader01" 
{
    SubShader 
	{
		Pass
		{
			Tags { "RenderType"="Opaque" }
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #include "UnityCG.cginc"

			struct v2f 
			{
				float4 pos : SV_POSITION;
			};

            v2f vert(appdata_base v) 
			{
				v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag(v2f i) : COLOR 
			{
				return half4(1, 0, 0, 1);
            }
			ENDCG
		}
    }
}
