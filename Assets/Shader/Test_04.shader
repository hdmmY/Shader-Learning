// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Test_04"
{
	SubShader {

		Pass {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 

			struct vertexInput
			{
				float4 vertex : POSITION ;
				float3 normal : NORMAL ;
				float4 tex : TEXCOORD0 ; 
			};


			float4 vert(vertexInput input) : SV_POSITION
			{
				float4 output;

				output = UnityObjectToClipPos(input.vertex);

				return output;
			}

			float4 frag (float4 input : SV_POSITION) : SV_TARGET
			{
				return input;
			}

			ENDCG
		}
	}
}