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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
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
			
			StructuredBuffer<Wave> _Waves;

            v2f vert (VertexData v)
            {
                v2f o;
                o.vertex = mul(unity_ObjectToWorld, v.vertex); // get vertex world position
                float heightOffset = 0.0;
                for (int i = 0; i < _WaveNumber; i++) {
                    Wave wave = _Waves[i];
                    float xzDisplacement = o.vertex.x * wave.direction.x + o.vertex.z * wave.direction.y;
                    heightOffset += wave.amplitude * sin(xzDisplacement * wave.frequency + wave.phase * _Time * wave.speed);
                }
                o.vertex.y += heightOffset;
                o.vertex = UnityObjectToClipPos(o.vertex); // clip to world position
                o.uv = v.uv;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
