// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Test_03" {

	SubShader
	{
		Pass 
		{
			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag 

			struct vertOut
			{
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0; 
			};

			vertOut vert( appdata_base input)
			{
				vertOut output;

				output.pos = UnityObjectToClipPos(input.vertex);
				output.scrPos = ComputeScreenPos(output.pos);

				return output;
			}


			fixed4 frag(vertOut input) : SV_Target
			{
				float2 wcoord = (input.scrPos / input.scrPos.w);

				return fixed4 (wcoord, 0.0, 1.0);
			}

			ENDCG
		}

		
	}


	FallBack "Diffuse"
}
