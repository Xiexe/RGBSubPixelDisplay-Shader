Shader "Xiexe/RGBSubPixelDisplay" {
  Properties {
    _MainTex("Emission (RGB)", 2D) = "white" {}
    _shiftColor("Tiltshift Color", Color) = (0,0,0,1)
    _RGBSubPixelTex ("RGBSubPixelTex", 2D) = "white" {}
    _LightmapEmissionScale("Lightmap Emission Scale", Float) = 1
    _EmissionColor ("Screen Intensity", Float) = 1
    _Glossiness ("Smoothness", Float) = 0.5
    [Toggle(APPLY_GAMMA)] _ApplyGamma("Apply Gamma", Float) = 0
  }
  SubShader {

      //DO ALL THE SCREEN STUFF
      Tags { "RenderType"="Opaque" }
      LOD 200

      CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
      #pragma surface surf Standard fullforwardshadows
        // Use shader model 3.0 target, to get nicer looking lighting
      #pragma target 3.0
      #pragma shader_feature _EMISSION
      #pragma multi_compile APPLY_GAMMA_OFF APPLY_GAMMA

      float _EmissionColor;
      float _Glossiness;
      sampler2D _MainTex;
      sampler2D _RGBSubPixelTex;
      float4 _shiftColor;
      fixed _LightmapEmissionScale;

      struct Input {
        float2 uv_MainTex;
        float2 uv_RGBSubPixelTex;
        float3 viewDir;
        float3 worldNormal;
      };

      void surf (Input IN, inout SurfaceOutputStandard o) {
        // emissive comes from texture

        float4 e = tex2D (_MainTex, IN.uv_MainTex);

       //viewing angle for tilt shift
        float3 viewDir = IN.viewDir;
        float3 ase_worldNormal = WorldNormalVector( IN, IN.worldNormal );
        float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			  float4 worldNormals = mul(unity_ObjectToWorld,float4( ase_vertexNormal , 0.0 ));
        float vdn = dot(viewDir, worldNormals);

      //Correct for gamma if being used for a VRC Stream script.
        #if APPLY_GAMMA
          e.rgb = pow(e.rgb,2.2);
        #endif
        
      //Do RGB pixels
        float4 rgbpixel = tex2D(_RGBSubPixelTex, IN.uv_RGBSubPixelTex);
        float pixelR = rgbpixel.r * e.r;
        float pixelG = rgbpixel.g * e.g;
        float pixelB = rgbpixel.b * e.b;
        float3 pixelValue = float3(pixelR, pixelG, pixelB);
      
      //Do the color shift at extreme viewing angles
        float3 screenCol = lerp(pixelValue, _shiftColor, max(0, (1-vdn * 1.2)));
        

        #ifdef UNITY_PASS_META
				  float3 finalCol = e * _LightmapEmissionScale;
		  	#else
				  float3 finalCol = screenCol * _EmissionColor;
		  	#endif


        o.Albedo = float4(0,0,0,1);
        o.Alpha = 1;
        o.Emission = finalCol;//finalCol;
        o.Metallic = 0;
        o.Smoothness = _Glossiness;
      }
    ENDCG
  }
  FallBack "Diffuse"
  CustomEditor "XS_RgbEditor"
}
