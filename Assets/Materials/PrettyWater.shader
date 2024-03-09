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
			
			StructuredBuffer<Wave> _Waves;

            v2f vert (VertexData v)
            {
                Wave test;
                test.direction = float2(1,1);
                test.speed = 30.0;
                test.amplitude = 0.2;
                test.frequency = 10.0;
                test.phase = 5.0;

                v2f o;
                o.vertex = mul(unity_ObjectToWorld, v.vertex); // get vertex world position
                float heightOffset = 0.0;
                // for (int wi = 0; wi < _WaveCount; ++wi) {
                float xzDisplacement = o.vertex.x * test.direction.x + o.vertex.z * test.direction.y;
                heightOffset += test.amplitude * sin(xzDisplacement * test.frequency + test.phase * _Time * test.speed);
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
