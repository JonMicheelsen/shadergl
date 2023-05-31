#include <common.fh>


USE_TEXTURE_LIGHTING
DEF_LIGHT_AMBIENT(1)
DEF_LIGHT_DIR(1)

void main()
{
	half4 ColorBaseDiffuse = S_diffuse_color.rgba;
	_IF(S_diffuse_bool)
	{
		ColorBaseDiffuse = tex2D(S_diffuse_map, IO_uv0).rgba;
	}
	AlphaTest(ColorBaseDiffuse.a * F_alphascale);

	half3 TexSpecularStr = S_specular_color.rgb;
	half3 TexSpecularStrPure = S_specular_color.rgb;
	_IF(S_specular_bool)
	{
		TexSpecularStr.rgb = tex2D(S_specular_map, IO_uv0).rgb;
	}

	_IF(B_vertexdata0)
	{ 
		// NOTE: none blend areas need 128 grey!
		ColorBaseDiffuse.rgb = blendOverlay(ColorBaseDiffuse.rgb, IO_colorRGB_specstrA.rgb);
	}

	half Occl = 1.0;
//	half Occl = 1.0 - tex2Dlod(s_Occlusion, float4((inVPos.xy + 0.5f) / ViewPort.xy, 0.0, 0.0) ).g;
//	Occl = pow(Occl, 5.0); // use power to better scale occlusion 
	
	
	INPUT_NTB_ONESIDED()
	
	float3 Normal = vec3(0);
	STANDARD_NORMAL_MAP(Normal)
	
	
	CONST half3 VertexToEye = normalize(IO_VertexToEye.xyz);
	
	half3 ColorEnvi = S_environment_color.rgb;
	_IF(S_environment_bool)
	{
		half3 R_Eye = reflect(-VertexToEye, Normal);
		#ifdef _3DSMAX_
			R_Eye.xyz = R_Eye.xzy; //Max coordinate system
		#endif
		ColorEnvi.rgb = texture(S_environment_map, R_Eye).rgb;
		ColorEnvi.rgb = blendMultiply(ColorEnvi.rgb, TexSpecularStr.rgb);
	}
	
	// Shadow value, Ohoh we just have shadow calced for the main light so we only need to darken the light we have for the first global ? (does this always match?)
	float Shadow = 1.0f;
	_IF(B_shadow)
	{
		Shadow = GetShadow();
		Shadow = saturate(Shadow + (1.0 - F_alphascale)); // TODO: Bug -> last 20% dont work correctly we have a offset 0.1->0.2 somewhere
	}
	
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Convert all input colors to linear RGB space for correct light multiply.
///////////////////////////////////////////////////////////////////////////////////////////////////////
	ColorBaseDiffuse.rgb 		= TO_linearRGB(ColorBaseDiffuse.rgb);
	TexSpecularStr.rgb 			= TO_linearRGB(TexSpecularStr.rgb);
	ColorEnvi.rgb 				= TO_linearRGB(ColorEnvi.rgb);
///////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
///////////////////////////////////////////////////////////////////////////////////////////////////////
//				start per pixel light calculations
///////////////////////////////////////////////////////////////////////////////////////////////////////
	CONST half2 LightPower = half2(8, 4.0);
	CONST half3 AmbientColor = TO_linearRGB(V_ambient1.rgb);
	half3 DiffuseLight = half3(0);
	half3 SpecularLight = half3(0);
	half3 LocalDiffuseLight = half3(0);
	half3 LocalSpecularLight = half3(0);
	
	half3 finalColor = half3(0);

	CONST half3 diffnorm = ColorBaseDiffuse.rgb / luminance(ColorBaseDiffuse.rgb);

#ifdef _3DSMAX_
	CALC_GLOBAL_DIRLIGHT(1, calc_LambertHalf_Phong)
#else
	// local lights
/*	_IF(B_lighting) // check this bool, just reading my be faster, but we optimize later
	{
		CONST float4 lightindextexlookup = float4(inVPos.xy / ViewPort.xy, 0.0, 0.0); // use ps3 inputs and set LOD to 0
		CONST half localoccl = pow(Occl, 1.0/4.0); // scale power up, allow locallight to ignore occl to some degree, but if its very dark still scale down more.
		CONST half4 locallightdata = localoccl * LocalLightScale * tex2Dlod(s_LightIndexTexture, lightindextexlookup).rgba;
		LocalDiffuseLight = locallightdata.rgb;
		LocalSpecularLight = normalize(LocalDiffuseLight.rgb) * locallightdata.a; // just reconstruct color from diffuse and scale with intensity
	} */
	
	CALC_GLOBAL_DIRLIGHT_SHADOW(1, calc_LambertHalf_Phong, LightPower, DiffuseLight, SpecularLight, Shadow)
	//CALC_GLOBAL_DIRLIGHT(2, calc_LambertHalf_Phong)
	//CALC_GLOBAL_DIRLIGHT(3, calc_LambertHalf_Phong)	
	
#endif

	finalColor += S_diffusestr * (LocalDiffuseLight + DiffuseLight * Occl) * ColorBaseDiffuse.rgb;
	finalColor += S_specularstr * (LocalSpecularLight + SpecularLight * Occl) * TexSpecularStr.rgb;

	// add environmental reflection
	half3 Crm = blendMultiply(diffnorm.rgb, ColorEnvi.rgb);
	half3 Crp = ColorEnvi.rgb;
	half3 Cr = lerp(Crp, Crm, 0.5);
	finalColor += S_environmentstr * Cr.rgb;
	
//////////////////////////////////////////////////////////////////////////////////////////	
	//REMEMBER: on xbox360+TV we have to compensate for a gamma of 2.5! PC/Win has 2.2 and Mac 1.8!
#ifdef _3DSMAX_
   	finalColor.rgb = pow(finalColor.rgb, 1.0/2.2); //user gamma correction
#endif
 	OUT_Color = half4(finalColor.rgb, ColorBaseDiffuse.a * F_alphascale) * vec4(0.0, 1.0, 0.0, 1.0);
}
