#define P1_SHADERS
#include <common.fh>
 

USE_TEXTURE_LIGHTING

DEF_LIGHT_AMBIENT(1)
DEF_LIGHT_DIR(1)
DEF_LIGHT_DIR(2)


void main()
{
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

	half4 ColorBaseDiffuse = S_diffuse_color.rgba;
	_IF(S_diffuse_bool)
	{
		ColorBaseDiffuse.rgba = tex2D(S_diffuse_map, IO_uv0).rgba;
		if (S_diffuse_color.rgb != float3(1.0f, 1.0f, 1.0f))
		{
			ColorBaseDiffuse.rgba *= S_diffuse_color.rgba;
		}
	}


	//AlphaTest(ColorBaseDiffuse.a * F_alphascale);

	_IF(S_diffuse_detail_bool)
	{
		half4 DiffDetailv = tex2D(S_diffuse_detail_map, IO_uv0 * S_diffuse_detail_tiling).rgba * S_diffuse_detailstr;
		ColorBaseDiffuse.rgb = (ColorBaseDiffuse.rgb*DiffDetailv.rrr);
		SmoothnessVal = blendOverlay(SmoothnessVal, DiffDetailv.g);
		MetalnessVal = blendOverlay(MetalnessVal, DiffDetailv.b);
	}




	_IF(B_vertexdata0)
	{
		// NOTE: none blend areas need 128 grey!
		//ColorBaseDiffuse.rgb = blendOverlay(ColorBaseDiffuse.rgb, IO_colorRGB_specstrA.rgb);
		if (S_diffuse_color.rgb == float3(1.0f, 1.0f, 1.0f))
		{
			ColorBaseDiffuse.rgb = ColorBaseDiffuse.rgb* IO_colorRGB_specstrA.rgb;
		}
		//	SmoothnessVal *= IO_colorRGB_specstrA.a; //disabled, this causes some assets to loose smoothness!
		//TexSpecularStrPure = saturate(blendOverlay(TexSpecularStr.rgb,TO_linearRGB(IO_colorRGB_specstrA.rgb)));

	}
	CONST half3 diffnorm = ColorBaseDiffuse.rgb;

	_IF(S_diffuse_paint_bool) // after VertexColors
	{
		// blend in the paint layer
		CONST half4 ColorPaint = S_diffuse_paintstr * tex2D(S_diffuse_paint_map, IO_uv_paint).rgba;
		// we want to keep the black areas in the diffusemap so dont blend if luminance is low.
		ColorBaseDiffuse.rgb = blendAlpha(ColorBaseDiffuse.rgb, ColorPaint.rgb, ColorPaint.a);// * saturate(3.0 * luminance(ColorBaseDiffuse.rgb)));
																							  // reduce the specular on locations where we add paint.
																							  //test deactivated
		ColorBaseDiffuse.a = saturate(ColorBaseDiffuse.a+ColorPaint.a);
		CONST half specstrmod = lerp(1.0, 0.15, saturate(2.0 * ColorPaint.a));
		//	TexSpecularStr.rgb *= specstr;
		SmoothnessVal *= specstrmod;
		MetalnessVal *= specstrmod;
	}


	half3 ColorGlow = S_color_glow_color.rgb;
	_IF(S_color_glow_bool)
	{
		half4 val = S_color_glowstr * tex2D(S_color_glow_map, IO_uv0) * U_mat_dynamicglow;
		ColorGlow = val.rgb;
		ColorGlow *= 1 + val.a * (10 - 1);		//boost multiplier 1-10x (TODO @Timon @Markus decide range)
	}

	// apply the additional detail/structure layers	
	_IF(B_vertexdata1)
	{
		_IF(S_color_dirt_bool)
		{
			// blend in age layer, vertex need to be GREY on none apply areas
			CONST half4 ColorDirt = tex2D(S_color_dirt_map, IO_uv0 * S_color_dirt_tiling).rgba;
			CONST half3 ColorBaseDirt = blendMultiply(ColorBaseDiffuse.rgb, ColorDirt.rgb);
			CONST float dirtFactor = IO_damage_detail_age.b*S_color_dirtstr;
			ColorBaseDiffuse.rgb = blendAlpha(ColorBaseDiffuse.rgb, ColorBaseDirt.rgb, dirtFactor);
			ColorBaseDiffuse.a = saturate(ColorBaseDiffuse.a+ColorDirt.a* dirtFactor);
			//MetalnessVal = blendMultiply(MetalnessVal, min((ColorDirt.a* IO_damage_detail_age.b*S_color_dirtstr),1.0f));
			SmoothnessVal -= blendMultiply(SmoothnessVal, (1.0f - ColorDirt.a)*dirtFactor);
		}
	}
	/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	Combining 2 normal maps
	Artists wanted detail normal maps
	Blending 2 normal maps just flattens both
	Want to get results as if blending 2 heightmaps
	Warp 2nd normal map
	using normals from the 1st normal map:
	float3x3 nBasis = float3x3(
	float3 (n1.z, n1.x,-n1.y),
	float3 (n1.x, n1.z,-n1.y),
	float3 (n1.x, n1.y, n1.z ));
	n = normalize (n2.x*nBasis[0] + n2.y*nBasis[1] + n2.z*nBasis[2]);!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

	INPUT_NTB_TWOSIDED()
	
	float3 Normal = vec3(0);
	STANDARD_NORMAL_DETAIL_MAP(Normal)
	
	
	float backfaceFactor = 1.0f;
	if (gl_FrontFacing) {
		backfaceFactor = (0.8f - min(pow(ColorBaseDiffuse.a, 0.40f), 0.80f));
	}
	CONST half3 VertexToEye = normalize(IO_VertexToEye.xyz).xyz;

	float specShadow = 1.0f;
	float envShadow = 1.0f;
	_IF(B_shadow)
	{
		float n_dot_l = max(0.0f, dot(V_direction1.xyz, Normal.xyz));
		specShadow = GetShadow(n_dot_l);
		envShadow = (specShadow + 0.50f) / 1.50f; // Boost shadow values for envmap influence due to it being more like an ambient effect.
	}

	float Roughness = smooth2rough(SmoothnessVal);
	half3 ColorEnvi = S_environmentstr * global_envmap_resolve_glass(Normal, VertexToEye, Roughness, envShadow).rgb;

	//float fresnel(CONST float3 V, CONST float3 N, CONST half Power, CONST half Str, CONST half minRange)
/*	float fresnel_fac = fresnel(VertexToEye, Normal, 2.0, 1.0, 0.20);
	ColorEnvi.rgb *= vec3(fresnel_fac);
	*/

	//change the reflectivity based on light direction
	//also change the fresnel based on light direction??

	float ndl = max(0.0f, dot((V_direction1.xyz), Normal.xyz));
	//float ndl = max(0.0f, dot(Normal.xyz, normalize(V_direction1.xyz)));
	//ColorEnvi.rgb *= vec3(max(0.025, (0.5+ndl)/1.5));
	ColorEnvi.rgb = ColorEnvi.rgb*(1.0-U_env_dir_influence) + ColorEnvi.rgb*vec3(max(0.025, (U_dir_min + ndl) / (1.0-U_dir_min)))*U_env_dir_influence;
	//float fresnel_fac = fresnel(VertexToEye, Normal, (0.50+(1.0-ndl))/1.5, 1.0, 0.00);
	float fresnel_fac = fresnel(VertexToEye, Normal, U_fresnel_power, 1.0, U_fresnel_min);
	
	ColorEnvi.rgb = ColorEnvi.rgb*(1.0-U_fresnel_influence)+ColorEnvi.rgb*vec3(fresnel_fac)* U_fresnel_influence;
	
/*	if (luminance(ColorEnvi.rgb) > 0.051) {
		ColorEnvi.rgb *= max(0.0,1.0- luminance(ColorEnvi.rgb)*4.0);// normalize(ColorEnvi.rgb);
	}*/

	
//	OUT_Color.a = 0.8f;
//	OUT_Color.rgb = ColorEnvi;	return;
// 	OUT_Color.rgb = abs(GetFragWorld() / 5000);		return;
// 	OUT_Color.rgb = abs(inverse(M_envmapprobe_world[0]) * vec4(GetFragWorld(), 1)).xyz;		return;

	_IF(S_envi_light_bool)
	{
		ColorEnvi.rgb += envShadow * S_envi_lightstr * texture(S_envi_light_map, reflect(-VertexToEye, Normal)).rgb;
	}
	if (gl_FrontFacing)
	{
		ColorEnvi.rgb *= backfaceFactor;
	}

	//------------------------------
	
	OBJECTRENDERMODE_SOLID()

	CONST float light_radius = V_deferred_lightparams.x * 10; // dbg scale

	vec3 cspec = vec3(0);
	vec3 cdiff = vec3(0);
	vec3 Albedo = ColorBaseDiffuse.rgb;
	float Metalness = MetalnessVal;



	float3 ldir =  normalize(V_direction1.xyz);
	float3 lcolor = XR_TO_linearRGB(V_lightcolor1.rgb) * F_globallightscale;// todo: slightly refactor the following
	
	//float3 lcolor = normalize(V_lightcolor1.rgb * F_globallightscale);// todo: slightly refactor the following
	
	float direct_occlusion = saturate(dot(ldir, Normal));
	float direct_occlusion2 = saturate(dot(-ldir, Normal));
//	vec3 view_pos;
//	RetrieveZBufferViewPos(view_pos);

	//vec3 v = normalize(-view_pos);
	vec3 v = normalize(VertexToEye);
	vec3 R = reflect(v, Normal);

	
	vec3 L;
	vec3 L2;
	vec3 E_sph = direct_occlusion * lcolor * EvalSphereLight(light_radius, ldir * 1000, v, Normal, R, Roughness, L);// +simple_light(lcolor, ldir, Normal.xyz, v, Albedo, Metalness, Roughness);
	vec3 E_sph2 = direct_occlusion2 * lcolor * EvalSphereLight(light_radius, -ldir * 1000, v, Normal, R, Roughness, L2);// +simple_light(lcolor, ldir, Normal.xyz, v, Albedo, Metalness, Roughness);
	//E_sph *= PI; // diffuse normalization
	L = normalize(L);
	L2 = normalize(L2);
	vec3 light_accum = ColorBaseDiffuse.rgb;// -ColorBaseDiffuse.rgb;// vec3(0);


	get_colors(Albedo, Metalness, cspec, cdiff);
	if (gl_FrontFacing)
	{
		cspec *= backfaceFactor;
	}

	//light_accum += ColorBaseDiffuse.rgb*(ColorBaseDiffuse.a) + EvalBRDF(cspec, cdiff, Roughness, L, v, Normal, vec2(ColorBaseDiffuse.a, 1)) *E_sph*ColorBaseDiffuse.a +ColorEnvi.rgb; // specular
	light_accum += specShadow * EvalBRDF(cspec, cdiff, Roughness, L, v, Normal, vec2(ColorBaseDiffuse.a, 1)) * E_sph * ColorBaseDiffuse.a;  // specular
	light_accum += specShadow * EvalBRDF(cspec, cdiff, Roughness, L2, v, Normal, vec2(ColorBaseDiffuse.a, 1)) * E_sph2 * ColorBaseDiffuse.a; // specular 2
	light_accum += ColorEnvi.rgb;
	//light_accum += ColorBaseDiffuse.rgb*(ColorBaseDiffuse.a) + EvalBRDF(cspec*ColorBaseDiffuse.a, cdiff*ColorBaseDiffuse.a, Roughness, L, v, Normal, vec2(ColorBaseDiffuse.a, 1)) *E_sph +ColorEnvi.rgb; // specular

	float t = dot(ldir, -VertexToEye) * U_backlitfactor;
	float cutoff = 0.95f;
	if (t > cutoff )
	{
		float vt = pow((t - cutoff) / (1.0f - cutoff), 2.0f);
		vec3 newCol = lerp(ColorBaseDiffuse.rgb * 0.0, ColorBaseDiffuse.rgb * 10.0, vt);
		light_accum += newCol;//*max( length(newCol.xyz) ,1.0);
		ColorBaseDiffuse.a += min(vt*4.0f*ColorBaseDiffuse.a,0.1f);
		ColorBaseDiffuse.a = saturate(ColorBaseDiffuse.a);
	}
	
	
	OUT_Color = float4(light_accum.xyz, saturate(ColorBaseDiffuse.a + min( length(light_accum.xyz) ,0.1)));// + saturate(1.0f - pow(dot(Normal, VertexToEye), 0.1f))*0.25f));
	//OUT_Color = float4(ColorBaseDiffuse.rgb, 1);
	//OUT_Color = float4(light_accum.xyz, ColorBaseDiffuse.a);
	//OUT_Color = float4(light_accum.xyz, saturate((ColorBaseDiffuse.a + length(light_accum.xyz)*0.25f) + saturate(1.0f - pow(dot(Normal, VertexToEye), 0.1f))*0.25f));
	//float a = saturate(1.0f - pow(dot(Normal, VertexToEye), 0.02f));
	//OUT_Color = float4(a,a,a,1);
	//OUT_Color = float4(E_sph.xyz,1.0f);
	//OUT_Color = float4(1, 0, 0, 1);
}

