#include <common.fh>


USE_TEXTURE_LIGHTING
DEF_LIGHT_AMBIENT(1)
DEF_LIGHT_DIR(1)
//DEF_LIGHT_DIR(2)
//DEF_LIGHT_DIR(3)

void main()
{
	CONST half3 VertexToEye = normalize(IO_VertexToEye.xyz);		// V

	half4 ColorBaseDiffuse = half4(0.0,0.0,0.0,0.0);
	_IF(S_diffuse_bool)
	{
		ColorBaseDiffuse = tex2D(S_diffuse_map, IO_uv0).rgba;	//Base Diffuse + alpha
	}

	/*half3 TexOcclSpecRefl = {1.0,1.0,1.0};
	_IF(bTexSpecularPower || bOccl)
	{
		half3 inTexOcclSpecRefl = tex2D(S_specular_map, IO_uv0).rgb;	//Base Specular + Spec Power
		_IF(bOccl)
		{
			TexOcclSpecRefl.x = inTexOcclSpecRefl.x;
			TexOcclSpecRefl.x = pow(TexOcclSpecRefl.x, OcclStr);
		}
		_IF(S_specular_bool)
		{
			TexOcclSpecRefl.y = inTexOcclSpecRefl.y;
		}
		TexOcclSpecRefl.z = inTexOcclSpecRefl.z;
	}*/
	
	half4 TexSpecularStr_Power = half4(1.0,1.0,1.0, U_mat_spec_light_power);
//--------------------------------------------------------------------------------------
//				normals
//--------------------------------------------------------------------------------------	
	
	INPUT_NTB_ONESIDED()
	float3 Normal = IO_normal;
	float3 NormalRippled = IO_normal;
	
	_IF(S_normal_bool)
	{
		Normal = TEXTURE_NORMAL(normal, IO_uv0);
		Normal = CalcWorldNormal(Normal); 
		_IF(S_normal_noise_bool)
		{
			NormalRippled = TEXTURE_NORMAL(normal_noise, IO_uv0);
			NormalRippled += Normal;
		}
	}
	
	
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Convert all input colors to linear RGB space for correct light multiply.
///////////////////////////////////////////////////////////////////////////////////////////////////////
	ColorBaseDiffuse.rgb 		= TO_linearRGB(ColorBaseDiffuse.rgb);
	TexSpecularStr_Power.rgb 	= TO_linearRGB(TexSpecularStr_Power.rgb);
///////////////////////////////////////////////////////////////////////////////////////////////////////
	
//--------------------------------------------------------------------------------------
//				start per pixel light calculations
//--------------------------------------------------------------------------------------
	half3 DiffuseLight = half3(0);
	half3 SpecularLight = half3(0);
	half3 LocalDiffuseLight = half3(0); //zero init (needed ?)
	half3 LocalSpecularLight = half3(0); //zero init (needed ?)
	CONST half2 LightPower = half2(TexSpecularStr_Power.a, U_mat_diff_light_power);

#ifdef _3DSMAX_
	CALC_GLOBAL_DIRLIGHT(1, calc_LambertHalf_Blinn)
#else
/*	CALC_POINTLIGHT(r, calc_LambertHalf_Blinn)
	CALC_POINTLIGHT(g, calc_LambertHalf_Blinn)
	CALC_POINTLIGHT(b, calc_LambertHalf_Blinn)
	CALC_POINTLIGHT(a, calc_LambertHalf_Blinn) */
// global lights
	CALC_GLOBAL_DIRLIGHT(1, calc_LambertHalf_Blinn)
	//CALC_GLOBAL_DIRLIGHT(2, calc_LambertHalf_Blinn)
	//CALC_GLOBAL_DIRLIGHT(3, calc_LambertHalf_Blinn)
#endif
///////////////////////////////////////////////////////////////////////////////////////////////////////
	half3 ambient = U_color_ambient.rgb;
	ambient.rgb = TO_linearRGB(V_ambient1.rgb);
	
	
	DiffuseLight.rgb += LocalDiffuseLight.rgb + ambient.rgb;
	SpecularLight.rgb += LocalSpecularLight.rgb;

	DiffuseLight.rgb *= S_diffusestr /** TexOcclSpecRefl.x roger*/;
	SpecularLight.rgb *= S_specularstr /** TexOcclSpecRefl.y * TexOcclSpecRefl.x roger*/;
//////////////////////////////////////////////////////////////////////////////////////////////////////
//combine all
/////////////////////////////////////////////////////////////////////////////////////////////////////
	half3 finalColor = ((DiffuseLight.rgb + SpecularLight.rgb + U_color_ambient.rgb) * ColorBaseDiffuse.rgb); //no additive spec (preserve diff color's)
//////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////
//combine all
/////////////////////////////////////////////////////////////////////////////////////////////////////

	//Add Envimap reflection
	_IF(S_environment_bool)
	{
		// do we need a fresnel for the eyeball?
		//get reflection
		half3 R_Eye = reflect(-VertexToEye , NormalRippled);
		#ifdef _3DSMAX_
			R_Eye.xyz = R_Eye.xzy; //Max coordinate system
		#endif
		half3 Env = /*TexOcclSpecRefl.x * TexOcclSpecRefl.z * roger */ S_environmentstr * DiffuseLight.rgb * texture/*texCUBE*/(S_environment_map, R_Eye).rgb; //spec str,rgb vs luminosity?
		finalColor = blendAlpha(finalColor, finalColor + Env, pow(luminance(Env), 2.0) ); //power bright spots and blend based on luminance
	}
	
	//REMEMBER: on xbox360+TV we have to compensate for a gamma of 2.5! PC/Win has 2.2 and Mac 1.8!
#ifdef _3DSMAX_
   	finalColor.rgb = pow(finalColor.rgb, 1.0/2.2); //user gamma correction
#endif

//output final Color with unmodified Alpha

   	OUT_Color = float4( finalColor.rgb, F_alphascale) * vec4(0.0, 1.0, 0.0, 1.0);

}
