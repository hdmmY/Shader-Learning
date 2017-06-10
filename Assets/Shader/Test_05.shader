Shader "Custom/Test_05"
{
	Properties {
		_Color ("Color Tint", Color) = (0.0, 0.0, 0.0, 1.0)
	}

	SubShader {

		Pass {

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 

			float4 _Color;

			struct vertexInput{
				float4 pos : POSITION;
			};

			float4 vert(vertexInput input) : SV_POSITION
			{
				return UnityObjectToClipPos(input.pos);
			}

			fixed4 frag() : sV_Target
			{
				return _Color;
			}

			ENDCG
		}
	}
}