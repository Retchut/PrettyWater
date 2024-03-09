Shader "Unlit/PrettyWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            struct Wave {
                float2 direction;
                float speed;
                float amplitude;
                float frequency;
                float phase;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _WaveNumber;
            float3 _SunDirection;
			
			StructuredBuffer<Wave> _Waves;

            float3 getNormal(Wave wave, float3 vPos){
                // sin(x)' = x'cos(x)
                float xzDisplacement = vPos.x * wave.direction.x + vPos.z * wave.direction.y;
                // float xDerivative = wave.frequency * wave.direction.x * wave.amplitude * cos(xzDisplacement * wave.frequency + wave.phase * _Time * wave.speed);
                float xDerivative = wave.frequency * wave.direction.x * wave.amplitude * cos(xzDisplacement * wave.frequency + wave.phase * wave.speed);
                float3 tangentVector = float3(1, 0, xDerivative);
                // float zDerivative = wave.frequency * wave.direction.y * wave.amplitude * cos(xzDisplacement * wave.frequency + wave.phase * _Time * wave.speed);
                float zDerivative = wave.frequency * wave.direction.y * wave.amplitude * cos(xzDisplacement * wave.frequency + wave.phase * wave.speed);
                float3 binormalVector = float3(0, 1, zDerivative);
                return cross(tangentVector, binormalVector);
            }

            v2f vert (VertexData v)
            {
                v2f o;
                o.vertex = mul(unity_ObjectToWorld, v.vertex); // get vertex world position
                float heightOffset = 0.0;
                float3 finalNormal = float3(0.0, 0.0, 0.0);
                for (int i = 0; i < _WaveNumber; i++) {
                    Wave wave = _Waves[i];
                    // displacement depends on the X and Z position
                    float xzDisplacement = o.vertex.x * wave.direction.x + o.vertex.z * wave.direction.y;
                    // heightOffset += wave.amplitude * sin(xzDisplacement * wave.frequency + wave.phase * _Time * wave.speed);
                    heightOffset += wave.amplitude * sin(xzDisplacement * wave.frequency + wave.phase * wave.speed);
                    finalNormal += getNormal(wave, o.vertex);
                }
                float3 normalizedNormal = normalize(finalNormal);
                o.normal = normalizedNormal;
                o.vertex.y += heightOffset;
                o.vertex = UnityObjectToClipPos(o.vertex); // clip to world position
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = float4(i.normal.x, i.normal.y, i.normal.z, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
