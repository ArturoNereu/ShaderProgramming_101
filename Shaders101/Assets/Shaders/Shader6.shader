﻿Shader "UniteAsia/Shader06" 
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

			float3 _lightDir;

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float3 normal : TEXCOORD0;
			};

            v2f vert(appdata_base v) 
			{
				v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				//o.normal = v.normal;
                o.normal = mul(UNITY_MATRIX_IT_MV, float4(v.normal, 0)).xyz;
				return o;
            }

            half4 frag(v2f i) : COLOR 
			{
				return half4(half3(1, 1, 1) * dot(i.normal, _lightDir), 1);
            }
			ENDCG
		}
    }
}
