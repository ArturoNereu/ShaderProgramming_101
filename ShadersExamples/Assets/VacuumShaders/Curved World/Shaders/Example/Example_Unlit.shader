Shader "Custom/Example_Unlit"
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}

	SubShader 
	{
		//CurvedWorld rendertype, used by image effects
		Tags { "RenderType"="CurvedWorld_Opaque" }

        Pass 
		{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			//CurvedWorld shader API
			#include "../cginc/CurvedWorld_Base.cginc"



			sampler2D _MainTex;		
			fixed4 _Color;


            struct vertexInput 
			{
                float4 vertex : POSITION;
                float4 texcoord0 : TEXCOORD0;
            };

            struct fragmentInput
			{
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            fragmentInput vert(vertexInput i)
			{
                fragmentInput o;
				UNITY_INITIALIZE_OUTPUT(fragmentInput,o); 


				//CurvedWorld vertex transform
				V_CW_TransformPoint(i.vertex);


                o.position = UnityObjectToClipPos(i.vertex);
                o.uv = i.texcoord0.xy;
                return o;
            }

            fixed4 frag(fragmentInput i) : SV_Target 
			{
                return tex2D(_MainTex, i.uv) * _Color;
            }
            ENDCG
        }
    }
}
