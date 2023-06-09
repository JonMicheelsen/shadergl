#include <common.fh>


// Lighting
USE_TEXTURE_LIGHTING
//USE_SHADOW_MAP
DEF_LIGHT_AMBIENT(1)
DEF_LIGHT_DIR(1)
DEF_LIGHT_DIR(2)
DEF_LIGHT_DIR(3)

void main()
{
#ifdef JM_ENABLE_SUBSURFACE_GBUFFER_PACKING
	float SubsurfaceVal = 0.5;//
#endif	
	CONST mat3x3 inCOLORMATRIX_BASE = mat3x3(make_ColorMatrix(U_base_brightness_shift, U_base_contrast_shift, U_base_saturation_shift, U_base_hue_shift));
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
#ifdef JM_ENABLE_SUBSURFACE_GBUFFER_PACKING	
	MetalnessVal = max(0.0, MetalnessVal * 2.0 - 1.75);//clean that mess up int he textuyres later
	SubsurfaceVal *= (1.0 - min(1.0, MetalnessVal * 256));
#endif	
	float max = U_ethnicity_european + U_ethnicity_african + U_ethnicity_asian;
	float3 E = float3(U_ethnicity_european / max, U_ethnicity_african / max, U_ethnicity_asian / max);


	INPUT_NTB_TWOSIDED()
	
	float3 Normal = vec3(0);
	//STANDARD_NORMAL_MAP(Normal)


	Normal = IO_normal;			
#ifdef JM_ENABLE_FULL_ANGLE_CORRECTED_CHARACTER_NORMAL_COMPOSITING		
		//unreal derives these automatically in every single "Normal" sampler node, this should really not be a problem to do proper per texture
		vec3 texnorm 		= NormalReZ(vec3(TEXTURE_NORMAL_XY(normal,  IO_uv0) * E.x, 0.0));
		vec3 texnorm2 		= NormalReZ(vec3(TEXTURE_NORMAL_XY(normal2, IO_uv0) * E.y, 0.0));
		vec3 texnorm3 		= NormalReZ(vec3(TEXTURE_NORMAL_XY(normal3, IO_uv0) * E.z, 0.0));
		vec3 NormalAge_pp 	= NormalReZ(vec3(TEXTURE_NORMAL_XY(normal4, IO_uv0) * U_age, 0.0));
	
		// maximum detail preserving quality angle blend
		Normal = CalcWorldNormal(blend_reoriented_normals(blend_reoriented_normals(texnorm, texnorm2), blend_reoriented_normals(texnorm3, NormalAge_pp)));
#else	
		vec3 texnorm = TEXTURE_NORMAL(normal, IO_uv0);
		vec2 texnorm2 = TEXTURE_NORMAL_XY(normal2, IO_uv0);
		vec2 texnorm3 = TEXTURE_NORMAL_XY(normal3, IO_uv0);
	
		half3 NormalAge_pp = TEXTURE_NORMAL(normal4, IO_uv0).xyz;
	
		
		texnorm.xy = texnorm.xy * E.x + texnorm2 * E.y + texnorm3 * E.z + NormalAge_pp.xy * U_age;
		
		texnorm = normalize(texnorm);
		
		Normal = CalcWorldNormal(texnorm);			
#endif	

		_IF(S_diffuse_bool) //alpha = hueShift Mask (dont shift)
		{
			//ColorBaseDiffuse			= tex2D(S_diffuse_map, IO_uv0).rgba;	//Base Diffuse + alpha
			
			ColorBaseDiffuse = tex2D(S_diffuse_map, IO_uv0).rgba * E.x + tex2D(S_diffuse2_map, IO_uv0).rgba * E.y + tex2D(S_diffuse3_map, IO_uv0).rgba * E.z;
			ColorBaseDiffuse.rgb = ColorBaseDiffuse.rgb * (1.0 - U_age) + ColorBaseDiffuse.rgb*tex2D(S_diffuse4_map, IO_uv0).rgb * U_age;
			
			ColorBaseDiffuse.rgb		= blendAlpha(ColorBaseDiffuse.rgb, mul(ColorBaseDiffuse.rgb, inCOLORMATRIX_BASE), ColorBaseDiffuse.a);
		}
		
#ifdef JM_ENABLE_SUBSURFACE_BIAS_BLUR_TRICK
		vec3 wv = GetFragViewDir();// * mat3(M_view);
		float SubsurfaceBlur = pow2(dot(wv, normalize(mix(IO_normal, Normal, SubsurfaceVal))) * 0.5 + 0.5) * 3.0;	
		_IF(S_diffuse_bool) //alpha = hueShift Mask (dont shift)
		{
			//poor mans view dependant subsurface scattering aproximation, brighter spots == less  absorption == more seethrough.
			//we could improve with faint parallax
			SubsurfaceBlur				*= (1.0 - exp(-dot(ColorBaseDiffuse.rgb, vec3(0.2126, 0.7152, 0.0722)) * SubsurfaceVal)) * 3.0;
			ColorBaseDiffuse			= texture(S_diffuse_map, IO_uv0, SubsurfaceBlur).rgba*E.x + texture(S_diffuse2_map, IO_uv0, SubsurfaceBlur).rgba*E.y+ texture(S_diffuse3_map, IO_uv0, SubsurfaceBlur).rgba*E.z;
			ColorBaseDiffuse.rgb		= ColorBaseDiffuse.rgb*(1.0 - U_age) + ColorBaseDiffuse.rgb*texture(S_diffuse4_map, IO_uv0, SubsurfaceBlur).rgb*U_age;		
			ColorBaseDiffuse.rgb		= blendAlpha(ColorBaseDiffuse.rgb, mul(ColorBaseDiffuse.rgb, inCOLORMATRIX_BASE), ColorBaseDiffuse.a);
		}
			
#endif	
	CONST half3 diffnorm = ColorBaseDiffuse.rgb;

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
	
	vec3 ColorGlow = vec3(0.0f);
/*	half RimLight = fresnel(VertexToEye, Normal, U_fresnel_power/2) * ((1.0 + 2.0f*SmoothnessVal) / 3.0);  // apply occl to mask out hair/ear/sheek fresnel
	//half3 FresnelColor_Lin = TO_linearRGB(U_fresnel_color.rgb) * U_fresnel_strength*0.20;
	half3 FresnelColor_Lin = U_fresnel_color.rgb * U_fresnel_strength*0.05;

	ColorGlow += fresnel(VertexToEye, Normal, U_face_rim_power*2)*ColorBaseDiffuse.rgb*U_face_rim_strength*4.0;
	ColorGlow += (RimLight * FresnelColor_Lin.rrr);
	ColorGlow *= (Shadow + 1.0f) / 2.0f;
	ColorGlow = vec3(0.0f);*/
	
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
	// GENERAL_OUTPUT(Normal.xyz, vec3(0, 0, -1), cc, ColorBaseDiffuse.rgb, ColorGlow, GlowStr, MetalnessVal, SmoothnessVal);


#ifdef JM_ENABLE_SUBSURFACE_GBUFFER_PACKING
	ColorBaseDiffuse.rgb = bit_pack_albedo_normal(ColorBaseDiffuse.rgb, normalize(IO_normal), SubsurfaceVal);
	GENERAL_OUTPUT_SUBSURFACE(Normal, ColorBaseDiffuse.rgb, MetalnessVal, SubsurfaceVal, SmoothnessVal, ColorGlow);
#else	
	GENERAL_OUTPUT(Normal, ColorBaseDiffuse.rgb, MetalnessVal, SmoothnessVal, ColorGlow);
#endif	 	   
	//OUT_Color = ColorBaseDiffuse.rgba;
	//OUT_Color = half4(RimLight,RimLight,RimLight, 1.0f);
}
