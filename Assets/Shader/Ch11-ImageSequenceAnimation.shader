Shader "Custom/Ch11-ImageSequenceAnima"
{
	Properties{
		_Color ("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Image Sequence", 2D) = "white" {}
		_HorizontalAmount ("Horizontal Amount", Float) = 4
		_VerticalAmount("Vertical Amount", Float) = 4
		_Speed ("Speed", Range(1, 100)) = 30
	}

	SubShader {

		Tags{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		Pass {
			Tags{
				"LightMode" = "ForwardBase"
			}

			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;

			float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;


			struct vertexInput{
				float4 vertex : POSITION;
				float2 tex : TEXCOORD0; 
			};


			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0; 
			};


			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				output.uv = input.tex;

				return output;
			}


			fixed4 frag(vertexOutput input): SV_Target
			{
				float time = floor(_Time.y * _Speed);

				float row = floor(time / _HorizontalAmount);
				float column = time - row * _VerticalAmount;

				half2 uv = input.uv + half2(row, -column);
				uv.x /= _HorizontalAmount;
				uv.y /= _VerticalAmount;

				fixed4 color = tex2D(_MainTex, uv);
				color.rgb *= _Color.rgb;

				return color;
			}

			ENDCG
		}
	}
}