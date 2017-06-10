Shader "Custom/Ch7-NormalMapTangent" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Maint Texture", 2D) = "white" {}
		_BumpTex ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_Specular ("Specular Color", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		
		Pass {
			Tags{
				"LightingMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 
			#include "Lighting.cginc"

			fixed4 _Color;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 tex : TEXCOORD0; 
			};

			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;  
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);

				output.uv.xy = input.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				output.uv.zw = input.tex.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;

				float3 binormal = cross(input.normal, input.tangent.xyz) * input.tangent.w;
				float3x3 rotation = float3x3(input.tangent.xyz, binormal, input.normal);

				output.lightDir = mul(rotation, ObjSpaceLightDir(input.vertex).xyz);
				output.viewDir = mul(rotation, ObjSpaceViewDir(input.vertex).xyz);

				return output;
			}

			fixed4 frag(vertexOutput input): SV_Target
			{
				fixed3 tangentLightDir = normalize(input.lightDir);
				fixed3 tangentViewDir = normalize(input.viewDir);

				fixed4 packedNormal = tex2D(_BumpTex, input.uv.zw);

				fixed3 tangentNormal;
				tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, input.uv.xy).rgb * _Color.rgb;

				fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, tangentNormal)), _Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color, 1.0);
			}

			ENDCG

		}


	}
	FallBack "Specular"
}
