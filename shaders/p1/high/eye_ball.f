#include <common.fh>
 

USE_TEXTURE_LIGHTING
//USE_SHADOW_MAP
DEF_LIGHT_AMBIENT(1)
DEF_LIGHT_DIR(1)
DEF_LIGHT_DIR(2)
DEF_LIGHT_DIR(3)


void main()
{

    // CONST mat4x3 inCOLORMATRIX_EYE = make_ColorMatrix(EyeBrightness, EyeContrast, EyeSaturation, EyeHue)
	CONST mat4x3 inCOLORMATRIX_EYE = make_ColorMatrix(U_eyeball_brightness_shift, U_eyeball_contrast_shift, U_eyeball_saturation_shift, U_eyeball_hue_shift);
 

	CONST half3 VertexToEye = normalize(IO_VertexToEye.xyz);	// V

	half4 ColorBaseDiffuse = half4(TO_linearRGB(S_diffuse_color.rgb), 0.0);
	half4 ColorBaseDiffuseSub = half4(1.0, 1.0, 1.0, 0.0);

	float SmoothnessVal = U_smoothness;
	float MetalnessVal = U_metallness;
	_IF(S_smooth_bool)
	{
		SmoothnessVal *= tex2D(S_smooth_map, IO_uv0).r;
	}

	_IF(S_metal_bool)
	{
		MetalnessVal *= tex2D(S_metal_map, IO_uv0).r;
	}

	_IF(S_diffuse_bool) //alpha = hueShift Mask (dont shift)
	{
		ColorBaseDiffuse = tex2D(S_diffuse_map, IO_uv0).rgba;	//Base Diffuse + alpha
		ColorBaseDiffuse.rgb = mul(inCOLORMATRIX_EYE, ColorBaseDiffuse.rgb).rgb * S_diffusestr;
	}
	CONST half3 diffnorm = ColorBaseDiffuse.rgb;
	
	
	INPUT_NTB_TWOSIDED()
	
	float3 Normal = vec3(0);
	STANDARD_NORMAL_DETAIL_MAP(Normal)
	
	
	// Shadow value, Ohoh we just have shadow calced for the main light so we only need to darken the light we have for the first global ? (does this always match?)
	float Shadow = 1.0f;
	_IF(B_shadow)
	{
		Shadow = GetShadow();
		// for now shadows only apply to solid geometry
		//		Shadow = saturate(Shadow + (1.0 - F_alphascale)); // TODO: Bug -> last 20% dont work correctly we have a offset 0.1->0.2 somewhere
	}

	vec3 ColorGlow = vec3(0.1f)* fresnel(VertexToEye, Normal, 3.0f) * ((1.0 + 2.0f*SmoothnessVal) / 3.0)*ColorBaseDiffuse.rgb;
	
#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
	float SubsurfaceVal = 0.9;
	ColorBaseDiffuse.rgb = bit_pack_albedo_normal(ColorBaseDiffuse.rgb, normalize(mix(Normal, IO_normal, SubsurfaceVal)), SubsurfaceVal);
	GENERAL_OUTPUT_SUBSURFACE(Normal, ColorBaseDiffuse.rgb, MetalnessVal, SubsurfaceVal, SmoothnessVal, ColorGlow);
#else	
	GENERAL_OUTPUT(Normal, ColorBaseDiffuse.rgb, MetalnessVal, SmoothnessVal, ColorGlow);
#endif		 
}
