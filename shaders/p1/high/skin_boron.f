#include <common.fh>


// Lighting
USE_TEXTURE_LIGHTING
//USE_SHADOW_MAP
DEF_LIGHT_AMBIENT(1)
DEF_LIGHT_DIR(1)
DEF_LIGHT_DIR(2)
DEF_LIGHT_DIR(3)

float PHI = 1.61803398874989484820459;  //  = Golden Ratio   

float gold_noise(in vec2 xy, in float seed) {
	return fract(tan(distance(xy * PHI, xy) * seed) * xy.x);
}

void main()
{
#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
	float SubsurfaceVal = 0.95;	
#endif	
	float hue = U_base_hue_shift;
	float contrast = U_base_contrast_shift;
	float seed = float(U_seed);

	float offsethue = sin((1.0 / (U_shiftduration + 0.00001f)) * 3.14 * F_time) * U_shiftscale;
	hue = mod(hue + offsethue, 360.0);
	contrast = 1.0;

	if (U_randomhue > 0)
	{
		const vec2 subseed = vec2(1, 0);
		//float offsethue = sin(mod(F_time, (U_shiftduration * 3.14))))*U_shiftscale;
		offsethue = sin((1.0/(U_shiftduration+0.00001f))*3.14*F_time)* U_shiftscale;
		hue = mod(lerp(U_shiftscale+0.1, 359.9f-U_shiftscale, gold_noise(subseed, seed)) + offsethue,360.0);
		contrast = lerp(0.8f, 1.2f, gold_noise(subseed, seed));
	}
	CONST mat3x3 inCOLORMATRIX_BASE = mat3x3(make_ColorMatrix(U_base_brightness_shift, contrast, U_base_saturation_shift, hue));
	CONST mat3x3 inCOLORMATRIX_PAINT = mat3x3(make_ColorMatrix(U_paint_brightness_shift, U_paint_contrast_shift, U_paint_saturation_shift, U_paint_hue_shift));
	
	CONST half3 VertexToEye = normalize(IO_VertexToEye.xyz);	// V

	half4 ColorBaseDiffuse = half4(TO_linearRGB(S_diffuse_color.rgb), 0.0);
	half4 ColorBaseDiffuseSub = half4(1.0,1.0,1.0,0.0);

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
	#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING	
		MetalnessVal = max(0.0, MetalnessVal * 2.0 - 1.75);//clean that mess up int he textuyres later
		SubsurfaceVal *= (1.0 - min(1.0, MetalnessVal * 256));
	#endif	


	_IF(S_diffuse_bool) //alpha = hueShift Mask (dont shift)
	{
		ColorBaseDiffuse			= tex2D(S_diffuse_map, IO_uv0).rgba;	//Base Diffuse + alpha
		ColorBaseDiffuse.rgb		= saturate(blendAlpha(ColorBaseDiffuse.rgb, mul(ColorBaseDiffuse.rgb, inCOLORMATRIX_BASE), ColorBaseDiffuse.a));
	}
	INPUT_NTB_TWOSIDED()
	
	float3 Normal = vec3(0);
	STANDARD_NORMAL_MAP(Normal)
	#ifdef JON_MOD_ENABLE_SUBSURFACE_BIAS_BLUR_TRICK
		vec3 wv = GetFragViewDir();// * mat3(M_view);
		float SubsurfaceBlur = pow2(dot(wv, normalize(mix(IO_normal, Normal, SubsurfaceVal))) * 0.5 + 0.5) * 3.0;	
		_IF(S_diffuse_bool) //alpha = hueShift Mask (dont shift)
		{
			//poor mans view dependant subsurface scattering aproximation, brighter spots == less  absorption == more seethrough.
			//we could improve with faint parallax
			SubsurfaceBlur				*= (1.0 - exp(-dot(ColorBaseDiffuse.rgb, vec3(0.2126, 0.7152, 0.0722)) * SubsurfaceVal)) * 3.0;
			ColorBaseDiffuse			= texture(S_diffuse_map, IO_uv0, SubsurfaceBlur).rgba;	//Base Diffuse + alpha
			ColorBaseDiffuse.rgb		= saturate(blendAlpha(ColorBaseDiffuse.rgb, mul(ColorBaseDiffuse.rgb, inCOLORMATRIX_BASE), ColorBaseDiffuse.a));
		}		
	#endif	
	CONST half3 diffnorm = ColorBaseDiffuse.rgb;

	half3 ColorGlow = S_color_glow_color.rgb * U_mat_dynamicglow;;
	_IF(S_color_glow_bool)
	{
		
		half4 val = S_color_glowstr * tex2D(S_color_glow_map, IO_uv0);
		ColorGlow = val.rgb;
		CONST mat3x3 inCOLORMATRIX_GLOW = mat3x3(make_ColorMatrix(1.0, 1.0, 1.0, U_glow_hue_shift));
		ColorGlow.rgb = saturate(mul(ColorGlow.rgb, inCOLORMATRIX_GLOW));	//apply Paint matrix

		ColorGlow *= 1 + val.a * (10 - 1);		//boost multiplier 1-10x (TODO @Timon @Markus decide range)
		ColorGlow *= lerp(0.8, 1.0, (1.0 + sin((1.0 / U_shiftduration) * 3.14 * F_time)) / 2.0);
		ColorGlow *= U_mat_dynamicglow;
	}
/*	
	#ifdef JON_MOD_BORON_SUBSURFACE_GLOW
		float GlowMask = max(0.0, 1.0 - dot(LUM_ITU601, ColorGlow));
		for(int i = 1; i < 4; i++)
		{
			half4 val = S_color_glowstr * texture(S_color_glow_map, IO_uv0, i);
			half3 ColorGlowLoop = val.rgb;
			CONST mat3x3 inCOLORMATRIX_GLOW = mat3x3(make_ColorMatrix(1.0, 1.0, 1.0, U_glow_hue_shift));
			ColorGlowLoop.rgb = saturate(mul(ColorGlowLoop.rgb, inCOLORMATRIX_GLOW));	//apply Paint matrix
	
			ColorGlowLoop *= 1 + val.a * (10 - 1);		//boost multiplier 1-10x (TODO @Timon @Markus decide range)
			ColorGlowLoop *= lerp(0.8, 1.0, (1.0 + sin((1.0 / U_shiftduration) * 3.14 * F_time)) / 2.0);
			ColorGlowLoop *= U_mat_dynamicglow * ColorBaseDiffuse.rgb;
			ColorGlow += ColorBaseDiffuse.rgb * ColorGlowLoop * GlowMask * 20.0;
		}
	#endif
*/
	//--------------------------------------------------------------------------------------
	// apply the paint layer
	//--------------------------------------------------------------------------------------
	//alpha blend paint layer with diffuse base color
	_IF(S_diffuse_paint_bool)
	{
		half4 ColorPaint		= S_diffuse_paintstr * tex2D(S_diffuse_paint_map, IO_uv0).rgba;
		ColorPaint.rgb 			= mul(ColorPaint.rgb, inCOLORMATRIX_PAINT);	//apply Paint matrix
		// PROBLEM: we have to apply it to both layers since we do seperate lighting, result is a bit oversaturated!
		ColorBaseDiffuse.rgb	= blendAlpha(ColorBaseDiffuse.rgb, ColorPaint.rgb, ColorPaint.a); // not overlay since we dont want to mix with skin! 
		ColorBaseDiffuseSub.rgb	= blendAlpha(ColorBaseDiffuseSub.rgb, ColorPaint.rgb, ColorPaint.a); // not overlay since we dont want to mix with skin! 
	}
	
	
	
	// Shadow value, Ohoh we just have shadow calced for the main light so we only need to darken the light we have for the first global ? (does this always match?)
	float Shadow = 1.0f;
	_IF(B_shadow)
	{
		Shadow = GetShadow();
		// for now shadows only apply to solid geometry
//		Shadow = saturate(Shadow + (1.0 - F_alphascale)); // TODO: Bug -> last 20% dont work correctly we have a offset 0.1->0.2 somewhere
	}
		
//--------------------------------------------------------------------------------------
//				normals
//--------------------------------------------------------------------------------------	
	//TODO @timon verify inversion
// 	Normal.xyz *= sign(-in_vFace); //why we have to inverse it for max?
	

	// DEFERRED_HACK
	// Normal.xyz = mat3(M_view) * Normal.xyz; // view space normal
	// float smoothness = SmoothnessVal;
	// smoothness = 0.55;
	// GENERAL_OUTPUT(Normal.xyz, ColorBaseDiffuse.rgb, vec3(0), MetalnessVal, smoothness);

	//vec3 ColorGlow = vec3(0.0f);
	float GlowStr = 0.0f;
	float cc = 0.0f;
	//SmoothnessVal = 0.6f;
	//MetalnessVal = 0.0f;
	// DEFERRED_OUTPUT(Normal.xyz, vec3(0, 0, -1), cc, ColorBaseDiffuse.rgb, ColorGlow, GlowStr, MetalnessVal, SmoothnessVal);
//	if(SubsurfaceVal > 0)
//		ColorBaseDiffuse.rgb = vec3(0.0, 0.5, 0.0);
#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
	ColorBaseDiffuse.rgb = bit_pack_albedo_normal(ColorBaseDiffuse.rgb, normalize(IO_normal), SubsurfaceVal);
	GENERAL_OUTPUT_SUBSURFACE(Normal, ColorBaseDiffuse.rgb, MetalnessVal, SubsurfaceVal, SmoothnessVal, ColorGlow);
#else	
	GENERAL_OUTPUT(Normal, ColorBaseDiffuse.rgb, MetalnessVal, SmoothnessVal, ColorGlow );
#endif		   
	//OUT_Color = ColorBaseDiffuse.rgba;
	//OUT_Color = half4(RimLight,RimLight,RimLight, 1.0f);
}
