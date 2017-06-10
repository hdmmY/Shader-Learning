Shader "Custom/Ch7-NormalMapWorld" {
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
				float4 Ttow0 : TEXCOORD1;
				float4 Ttow1 : TEXCOORD2;
				float4 Ttow2 : TEXCOORD3;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);

				output.uv.xy = input.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				output.uv.zw = input.tex.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;

				float3 worldPos = mul(UNITY_MATRIX_M, input.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(input.normal);
				float3 worldTangent = UnityObjectToWorldDir(input.tangent);
				float3 worldBinormal = cross(worldNormal, worldTangent) * input.tangent.w;

				output.Ttow0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				output.Ttow1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				output.Ttow2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				
				return output;
			}

			fixed4 frag(vertexOutput input): SV_Target
			{
				float3 worldPos = float3(input.Ttow0.w, input.Ttow1.w, input.Ttow2.w);

				float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));

				fixed4 packedNormal = tex2D(_BumpTex, input.uv.zw);
				fixed3 bump = UnpackNormal(packedNormal);
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				float3x3 rotation = float3x3(input.Ttow0.xyz, input.Ttow1.xyz, input.Ttow2.xyz);
				bump = mul(rotation, bump);

				fixed3 albedo = tex2D(_MainTex, input.uv.xy).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, lightDir));

				fixed3 halfDir = normalize(dot(viewDir, lightDir));
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color, 1.0);
			}

			ENDCG

		}
	}

	FallBack "Specular"
}
