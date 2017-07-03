Shader "Custom/Ch10-GrassReflection" {
	Properties {
		_MainTex("Main Texture0", 2D) = "white" {}
		_BumpMap("Bump0", 2D) = "white" {}
		_CubeMap("Environment Cube", Cube) = "_Skybox" {}
		_Refraction("Refraction Amount", Range(0.0, 1.0)) = 1.0  // when it is 1, it only contains refraction; when it is 0, it only contains reflection
		_Distortion("Distortion", Range(0, 100)) = 10
	}
	SubShader {
		
		// it must be transparent, so other objects are drawn before it
		Tags{
			"Queue" = "Transparent"
			"RenderType" = "Opaque"
		}

		GrabPass{
			"_RefractionTex"
		}

		Pass{

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			samplerCUBE _CubeMap;

			float _Distortion;
			fixed _Refraction;

			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;

			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD0; 
			};

			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float4 Ttow0 : TEXCOORD0;
				float4 Ttow1 : TEXCOORD1;
				float4 Ttow2 : TEXCOORD2;
				float4 uv : TEXCOORD3;
				float4 srcPos : TEXCOORD4; 
			};


			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);

				output.srcPos = ComputeGrabScreenPos(output.vertex);

				output.uv.xy = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				output.uv.zw = input.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
				float3 worldNormal = UnityObjectToWorldNormal(input.normal).xyz;
				float3 worldTangent = UnityObjectToWorldDir(input.tangent).xyz;
				float3 worldBinormal = cross(worldNormal, worldTangent) * input.tangent.w;

				output.Ttow0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				output.Ttow1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				output.Ttow2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return output;
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				float3 worldPos = normalize(float3(input.Ttow0.w, input.Ttow1.w, input.Ttow2.w));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap, input.uv.zw));
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize;
				input.srcPos.xy = offset + input.srcPos.xy;

				fixed3 refrColor = tex2D(_RefractionTex, input.srcPos.xy / input.srcPos.w).rgb;

				bump = normalize(half3(dot(input.Ttow0.xyz, bump), dot(input.Ttow1.xyz, bump), dot(input.Ttow2.xyz, bump)));

				fixed3 reflDir = reflect(-worldViewDir, bump);
				fixed4 texColor = tex2D(_MainTex, input.uv.xy);
				fixed3 reflColor = texCUBE(_CubeMap, reflDir).rgb * texColor.rgb;

				fixed3 finalColor = reflColor * (1 - _Refraction) + refrColor * _Refraction;

				return float4(finalColor, 1.0);
			}



			ENDCG

		}


	}
	FallBack "Diffuse"
}
