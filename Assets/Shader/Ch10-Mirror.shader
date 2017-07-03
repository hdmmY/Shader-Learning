Shader "Custom/Ch10-Mirror" {
	Properties {
		_MainTex ("Main Texture", 2D) = "white"
	}
	SubShader {
		
		Pass{
			Tags{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			struct vertexInput{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0; 
			};

			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0; 
			};


			sampler2D _MainTex;

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				
				output.uv = input.uv;
				output.uv.x = 1 - output.uv.x;

				return output;
			}

			fixed4 frag(vertexOutput input) : SV_TARGET
			{
				return tex2D(_MainTex, input.uv);
			}


			ENDCG
		}

	}
	FallBack "Diffuse"
}
