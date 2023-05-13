////////////////// JON MOD LIGHTING FUNCTIONS //////////////////
//Included right before global_lights() in common.fh, that is included in all lighting code
// as well as in the start of lighting_common.h

#ifndef _JON_MOD_LIGHTING_FUNCTIONS_
//L we have to trasnform to view space
float ScreenSpaceShadows(	in vec3 light_ray, 
							in vec2 cascade_blend, 
							inout vec3 debug)	
{
	float step_size = 1.0 / float(JON_MOD_SSSHADOWS_MAX_STEPS);
	
	// Compute ray step
	vec3 ray_step = light_ray * step_size * max(JON_MOD_SSSHADOWS_RAY_MAX_DISTANCE_NEAR, JON_MOD_SSSHADOWS_RAY_MAX_DISTANCE * cascade_blend.y);
	
	// Ray march towards the light
	float shadow = 0.0;
	vec2 ray_uv = vec2(0.0);
	vec2 fade = vec2(0.0);

	vec3 ray_pos = GetViewPos();
	#if defined(AAMODE_SSAA_2X)	
		float2 aspect = float2(0.5, -1.0 * V_viewportpixelsize.x / V_viewportpixelsize.y);
	#else
		float2 aspect = float2(0.5, -0.5 * V_viewportpixelsize.x / V_viewportpixelsize.y);
	#endif
	//different ways of getting what we need
	//debug = fract(vec3(1.0 / vec2(GetDepth(GetFragUV()), GetDepth()), GetViewPos().z * 10.0));//why 10?
	//works too
	//debug = fract(vec3(1.0 / vec2(GetDepth((ray_pos.xy / ray_pos.z) * aspect + 0.5), GetDepth()), GetViewPos().z * 10.0));//why 10?
	
	float depth = (ray_pos.z * 10.0);
	vec2 dither = hash22(gl_FragCoord.xy);
	vec2 texel_size = (1.0 / V_viewportpixelsize.xy);
	float thickness_threshold = max(JON_MOD_SSSHADOWS_MAX_THICKNESS_NEAR, JON_MOD_SSSHADOWS_MAX_THICKNESS * ceil(cascade_blend.y));
	float depth_bias = max(JON_MOD_SSSHADOWS_BIAS_NEAR * (1.0 + depth * 0.1), JON_MOD_SSSHADOWS_BIAS * ceil(cascade_blend.y));
	float attenuation = ceil(cascade_blend.x) * step_size * JON_MOD_SSSHADOWS_ATTENUATION_NEAR;
	
	for (uint i = 0; i < JON_MOD_SSSHADOWS_MAX_STEPS; i++)
	{
		// Step the ray
		ray_pos -= ray_step;
		ray_uv = ray_pos.xy / ray_pos.z;

		fade = abs(ray_uv);
		
		// Ensure the UV coordinates are inside the screen
		if(max(fade.x, fade.y) > 1.0)
			break;
		
		float depth_step = 1.0 / GetDepth(ray_uv * aspect + 0.5 + uv2clip(fract(dither)) * texel_size);
		dither += step_size;
		float depth_delta = ray_pos.z * 10.0 - depth_step - depth_bias;
		
		if(depth_delta > 0.0 && depth_delta <  thickness_threshold)
		{
			// Fade out as we approach the edges of the screen
			fade				= 1.0 - saturate(fade * 100.0 - 99.0);
			shadow				= min(fade.x, fade.y);
			shadow				= 1 - attenuation * i;
			break;
		}

	}
	#ifdef JON_MOD_SSSHADOWS_DEBUG_MODE
		debug.g = shadow;
	#endif
	
	return 1.0 - shadow * (cascade_blend.x + cascade_blend.y);
}

// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
// Similar to UE4/5 but with actual luminance, since that's a nice touch, rather than just cspec.g
vec3 schlick_f(vec3 cspec, float v_dot_h)
{
	float f = pow5(1.0 - v_dot_h);
	#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
		if(GetViewPos().x < 0.0)
			return f + (1-f) * cspec;
	#endif	
	return min(50.0 * dot(LUM_ITU601, cspec), 1.0) * f + (1.0 - f) * cspec;
}
// https://advances.realtimerendering.com/s2018/index.htm
// It has been extended here to fade out retro reflectivity contribution from area light in order to avoid visual artefacts.
vec3 chan_diff(vec3 cdiff, float a2, float n_dot_v, float n_dot_l, float v_dot_h, float n_dot_h, float arealight_weight, vec3 cspec)
{
	float g = saturate((1.0 / 18.0) * log2(2.0 / a2 - 1.0));
	
	float f0 = (v_dot_h + pow5(1.0 - v_dot_h));
	float fdv = (1.0 - 0.75 * pow5(1.0 - n_dot_v));
	float fdl = (1.0 - 0.75 * pow5(1.0 - n_dot_l));

	// Rough (f0) to smooth (fdv * fdv) response interpolation
	float fd = mix(f0, fdv * fdl, saturate(2.2 * g - 0.5));
	
	// Retro reflectivity contribution.
	float fb = ((34.5 * g - 59.0) * g + 24.5) * v_dot_h * exp2(-max(73.2 * g - 21.2, 8.9) * sqrt(n_dot_h));
	
	// It fades out when lights become area lights in order to avoid visual artefacts.
	fb *= arealight_weight;
	
	#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
		if(GetViewPos().x < 0.0)
			return cdiff * (1.0 / PI) * saturate(1.0f - dot(LUM_ITU601, cspec));
	#endif
		
	return cdiff * (INVPI * (fd + fb));
	
}
// https://iryoku.com/downloads/Practical-Realtime-Strategies-for-Accurate-Indirect-Occlusion.pdf
vec3 muli_bounce_ambient_occlusion(vec3 cdiff, float ambient_occlusion)
{

	vec3 a = 2.0404 * cdiff - 0.3324;
	vec3 b = -4.7951 * cdiff + 0.6417;
	vec3 c = 2.7552 * cdiff + 0.6903;
	return max(vec3(ambient_occlusion), ((ambient_occlusion * a + b) * ambient_occlusion + c) * ambient_occlusion);
}
// Point lobe in off-specular peak direction and specular occlusion from Unreal - but they got it from somwhere else, forgotten where, think I first encountered it in a Marmoset IBL article, that heavily quated the Frostbite PBR paper...?
vec3 off_specular_peak(vec3 normal, vec3 reflection, float roughness_sr)
{
	return mix(normal, reflection, (1.0 - roughness_sr) * (sqrt(1.0 - roughness_sr) + roughness_sr));	
}
float get_specular_occlusion(float n_dot_v, float roughness_sr, float ambient_occlusion)
{
	return clamp(pow(n_dot_v + ambient_occlusion, roughness_sr) - 1.0 + ambient_occlusion, 0.0, 1.0);
}

int max_spec_level_less_strict(samplerCube filtered_env_map)
{
	return textureQueryLevels(filtered_env_map) - 3;//Egosoft, You had -2 in yours, that's 4x4 pixels. I would not recommend at least 8x8
}


vec3 combined_ambient_brdf(samplerCube filtered_env_map, vec3 cspec, vec3 cdiff, vec3 normal, vec3 view, float roughness, float ambient_occlusion, vec4 ssr, vec3 flat_diffuse_addition)
{
	int lowest_mip = max_spec_level_less_strict(filtered_env_map);
	float n_dot_v = dot(normal, view);
	vec3 reflection = view - 2.0 * normal * n_dot_v;//view and normal are both normalized, so we don't need to too.
	n_dot_v = max(0.0, n_dot_v);
	//chan_diffuse is now baked into to T_preintegrated_GGX b channel
	vec3 env_brdfs = textureLod(T_preintegrated_GGX, vec2(roughness, n_dot_v), 0).xyz;
	
	float roughness_sr = roughness * roughness;
	#ifdef JON_MOD_USE_AMBIENT_SPECULAR_TRICKS
		reflection = off_specular_peak(normal, reflection, roughness_sr);
	#endif
	vec4 specular_ibl = textureLod(filtered_env_map, reflection, lowest_mip * sqrt(roughness));
	#ifdef JON_MOD_DEBUG_WHITE_FURNACE_AMBIENT
		specular_ibl.rgb = vec3(1.0);
	#endif
	
	//why was the SSR missing a PI in inensity to match!? Nah, seemed to intense
	vec3 ambient_specular = mix(specular_ibl.rgb, ssr.rgb, ssr.a);

	ambient_specular *= (cspec * env_brdfs.x + min(dot(LUM_ITU601, cspec) * 50.0, 1.0) * env_brdfs.y);
	#ifdef JON_MOD_USE_AMBIENT_SPECULAR_TRICKS
		ambient_specular *= get_specular_occlusion(n_dot_v, roughness_sr, ambient_occlusion);
	#else
		ambient_specular *= ambient_occlusion;
	#endif
	
	vec3 ambient_diffuse = textureLod(filtered_env_map, normal, lowest_mip).rgb + flat_diffuse_addition;
	#ifdef JON_MOD_DEBUG_WHITE_FURNACE_AMBIENT
		ambient_diffuse = vec3(1.0);
	#endif
	#ifdef JON_MOD_USE_AMBIENT_SPECULAR_TRICKS
		ambient_diffuse *= (cdiff * muli_bounce_ambient_occlusion(cdiff, ambient_occlusion)) * env_brdfs.b;	
	#else
		ambient_diffuse *= ambient_occlusion;
	#endif
#ifdef JON_MOD_DEBUG_DISABLE_AMBIENT_LIGHT
	return vec3(0.0);
#endif	
	
	return ambient_specular + ambient_diffuse;
}

//l_pass_envmap_probe.f version
vec4 combined_ambient_probe_brdf(samplerCube filtered_env_map, vec3 cspec, vec3 cdiff, vec3 normal, vec3 view, vec3 reflection, float roughness, float ambient_occlusion, float ssr_alpha)
{
	int lowest_mip = max_spec_level_less_strict(filtered_env_map);
	float n_dot_v = dot(normal, view);

	n_dot_v = max(0.0, n_dot_v);
	//chan_diffuse is now baked into to T_preintegrated_GGX b channel
	vec3 env_brdfs = textureLod(T_preintegrated_GGX, vec2(roughness, n_dot_v), 0).xyz;
	
	float roughness_sr = roughness * roughness;
		
	#ifdef JON_MOD_USE_AMBIENT_SPECULAR_TRICKS_PROBE_VERSION
		reflection = off_specular_peak(normal, reflection, roughness_sr);
	#endif
	vec4 ambient_specular = textureLod(filtered_env_map, reflection, lowest_mip * sqrt(roughness));

	ambient_specular.rgb *= (1.0 - ssr_alpha);
	ambient_specular.rgb *= (cspec * env_brdfs.x + min(dot(LUM_ITU601, cspec) * 50.0, 1.0) * env_brdfs.y);
	
	#ifdef JON_MOD_USE_AMBIENT_SPECULAR_TRICKS
		ambient_specular.rgb *= get_specular_occlusion(n_dot_v, roughness_sr, ambient_occlusion);
	#else
		ambient_specular.rgb *= ambient_occlusion;
	#endif

	vec3 ambient_diffuse = textureLod(filtered_env_map, normal, lowest_mip).rgb;
	#ifdef JON_MOD_USE_AMBIENT_SPECULAR_TRICKS
		ambient_diffuse *= (cdiff * muli_bounce_ambient_occlusion(cdiff, ambient_occlusion)) * env_brdfs.b;	
	#else
		ambient_diffuse *= ambient_occlusion;
	#endif
#ifdef JON_MOD_DEBUG_DISABLE_AMBIENT_LIGHT
	return vec4(0.0);
#endif	
	return vec4(ambient_specular.rgb + ambient_diffuse, ambient_specular.a);

}

#define _JON_MOD_LIGHTING_FUNCTIONS_
#endif
