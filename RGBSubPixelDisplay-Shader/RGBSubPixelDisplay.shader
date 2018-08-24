Shader "Xiexe/RGBSubPixelDisplay" {
  Properties {
    _MainTex("Emission (RGB)", 2D) = "white" {}
    _shiftColor("Tiltshift Color", Color) = (0,0,0,1)
    _RGBSubPixelTex ("RGBSubPixelTex", 2D) = "white" {}
    _LightmapEmissionScale("Lightmap Emission Scale", Float) = 1
    _EmissionIntensity ("Screen Intensity", Float) = 1

    
    _Glossiness ("Smoothness", Float) = 0.5
    
    [Toggle(APPLY_GAMMA)] _ApplyGamma("Apply Gamma", Float) = 0

    //needs to be here so the editor script stops throwing errors.
    _EmissionColor ("Emission Color", Color) = (0,0,0,0)
    
    //Color Correction
    [Header(  Color Balance)]
    _Saturation ("Saturation", Range(0,1)) = 1
    _Contrast ("Contrast", Range(0.01,2)) = 1
    _RedScale ("Red Scale", Range(-1,1)) = 1
    _GreenScale ("Green Scale", Range(-1,1)) = 1
    _BlueScale("Blue Scale", Range(-1,1)) = 1

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
      #pragma multi_compile HAS_ALPHA_OFF HAS_ALPHA

      float _EmissionIntensity;
      float _Glossiness;
      sampler2D _MainTex;
      sampler2D _RGBSubPixelTex;
      float4 _shiftColor;
      fixed _LightmapEmissionScale;

      //Color Correction
      float _Saturation;
      float _RedScale;
      float _BlueScale;
      float _GreenScale;
      float _Contrast;

      struct Input {
        float2 uv_MainTex;
        float2 uv_RGBSubPixelTex;
        float3 viewDir;
        float3 worldNormal;
      };

      void surf (Input IN, inout SurfaceOutputStandard o) {
        // emissive comes from texture

			  fixed4 e = tex2D (_MainTex, IN.uv_MainTex);

       //viewing angle for tilt shift
        float3 viewDir = IN.viewDir;
        float3 ase_worldNormal = WorldNormalVector( IN, IN.worldNormal );
        float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			  float4 worldNormals = mul(unity_ObjectToWorld,float4( ase_vertexNormal , 0.0 ));
        float vdn = dot(viewDir, worldNormals);

      //correct for gamma if being used for a VRC Stream script.
      //ONLY on stream panels, not video panels.
        #if APPLY_GAMMA
          e.rgb = pow(e.rgb,2.2);
        #endif
        
      //handle saturation
        float4 greyscalePixel = Luminance(e);
        e = lerp(greyscalePixel, e, _Saturation);
      //handle Contrast
        e = pow(e, _Contrast);

      //Do RGB pixels
        float4 rgbpixel = tex2D(_RGBSubPixelTex, IN.uv_RGBSubPixelTex);

      //sample the main textures color channels to derive how strong any given subpixel should be, 
      //and then adjust the intensity of the subpixel by the color correction values
        float pixelR = ((_RedScale + rgbpixel.r) * rgbpixel.r ) * e.r;
        float pixelG = ((_GreenScale + rgbpixel.g) * rgbpixel.g ) * e.g;
        float pixelB = ((_BlueScale + rgbpixel.b) * rgbpixel.b ) * e.b;

      //if the texture has an alpha, then use that to control how the subpixel lights up
        pixelR = lerp(0, pixelR, saturate(rgbpixel.a + (e.r )));
        pixelG = lerp(0, pixelG, saturate(rgbpixel.a + (e.g )));
        pixelB = lerp(0, pixelB, saturate(rgbpixel.a + (e.b )));

        float3 pixelValue = float3(pixelR, pixelG, pixelB);
      
      //do the color shift at extreme viewing angles
        float3 screenCol = lerp(pixelValue * _EmissionIntensity, _shiftColor, max(0, (1-vdn * 1.2)));
        

        #ifdef UNITY_PASS_META
				  float3 finalCol = e * _LightmapEmissionScale;
		  	#else
				  float3 finalCol = screenCol;
		  	#endif


        o.Albedo = float4(0,0,0,1);
        o.Alpha = 1;
        o.Emission = finalCol;
        o.Metallic = 0;
        o.Smoothness = _Glossiness;
      }
    ENDCG
  }
  FallBack "Diffuse"
  CustomEditor "XS_RgbEditor"
}
