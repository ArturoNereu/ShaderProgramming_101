Shader "UniteAsia/Shader04" 
{
	Properties
	{
		_RedValue("Red Value", float) = 0.5
		_GreenValue("Green Value", float) = 0.5
		_BlueValue("Blue Value", float) = 0.5
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

			float _RedValue;
			float _GreenValue;
			float _BlueValue;

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
				return float4(_RedValue, _GreenValue, _BlueValue, 1);
            }
			ENDCG
		}
    }
}
