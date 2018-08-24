
      //Emission
      float _EmissionIntensity;
      float _LightmapEmissionScale;
      float4 _shiftColor;
      float _Backlight;

      //Color Correction
      float _Saturation;
      float _RedScale;
      float _BlueScale;
      float _GreenScale;
      float _Contrast;

      float4 RGBSubPixelConvert(sampler2D MainTex, sampler2D RGBTex, float2 uv0, float2 uv1, float3 viewDir, float3 worldNormal)
      {
      //our emission map
			  float4 e = tex2D (MainTex, uv0);

      //viewing angle for tilt shift
        float3 rawWorldNormal = worldNormal;
        float3 vertexNormal = mul( unity_WorldToObject, float4(rawWorldNormal, 0));
			  float4 worldNormals = mul(unity_ObjectToWorld,float4(vertexNormal, 0));
        float vdn = dot(viewDir, worldNormals);

      //correct for gamma if being used for a VRC Stream script.
      //ONLY on stream panels, not video panels.
        #if APPLY_GAMMA
          e.rgb = pow(e.rgb,2.2);
        #endif
        
      //handle saturation
        float4 greyscalePixel = Luminance(e);
        e = lerp(greyscalePixel, e, _Saturation);
      //handle contrast
        e = pow(e, _Contrast);

      //do RGB pixels
        float4 rgbpixel = tex2D(RGBTex, uv1);

        float backlight = dot(rgbpixel, 0.5);
          backlight *= 0.005;
          backlight = lerp(0, backlight, _Backlight);

      //sample the main textures color channels to derive how strong any given subpixel should be, 
      //and then adjust the intensity of the subpixel by the color correction values
        float pixelR = ((_RedScale + rgbpixel.r) * rgbpixel.r) * e.r;
        float pixelG = ((_GreenScale + rgbpixel.g) * rgbpixel.g) * e.g;
        float pixelB = ((_BlueScale + rgbpixel.b) * rgbpixel.b) * e.b;

      //if the texture has an alpha, then use that to control how the subpixel lights up
        pixelR = lerp(0, pixelR, saturate(rgbpixel.a + e.r));
        pixelG = lerp(0, pixelG, saturate(rgbpixel.a + e.g));
        pixelB = lerp(0, pixelB, saturate(rgbpixel.a + e.b));

      //add the backlight, if there is any, and ensure that it only happens within
      //the area of a subpixel. We don't want lightleak through the black areas of the texture.
        pixelR += backlight * rgbpixel.r;
        pixelG += backlight * rgbpixel.g;
        pixelB += backlight * rgbpixel.b;
      
      //return all of our pixel values in a float3
        float3 pixelValue = float3(pixelR, pixelG, pixelB);

      //do the color shift at large viewing angles, shifting to whatever color we want, based on 
      //1 - the dot product of the viewdir and the normals, multipled, to make the dot larger.
      //i'm sure there's a more accurate way to handle this.
        float3 screenCol = lerp(pixelValue * _EmissionIntensity, _shiftColor, max(0, (1-vdn * 1.2)));
        
      //if we're in the meta pass, just pass through the final color as the emission texture * the emission scale.
      //this ensures we don't have anything else effecting our lightmap emissions (such as the tilt shifting),
      //otherwise, we pass through the final color from above
        #ifdef UNITY_PASS_META
				  float3 finalCol = e * _LightmapEmissionScale;
		  	#else
				  float3 finalCol = screenCol;
		  	#endif

      //Return it all as a float4 with an alpha of 1
        return float4(finalCol.xyz,1);
      }
