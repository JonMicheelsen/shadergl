#define P1_SHADERS
#include <common.fh>

in float IO_radius;
in vec3 IO_center;
in vec4 IO_worldviewpos;

#ifdef LPASS_BLEND_DEBUG
in vec4 IO_lightcolor;
#endif

void main()
{
	OUT_Color = vec4(0);
	OUT_Color.a = 1;
	
	vec3 view_pos;
	RetrieveZBufferViewPos(view_pos);

	if (view_pos.z > BGDIST) {
	//	OUT_Color.r = 1;	return;
		discard;
	}

	vec4 finalColor = vec4(0);

	vec3 wn;
	vec3 Albedo;
	float Metalness;
	float Smoothness;
	RI_GBUFFER_RAW(wn, Albedo, Metalness, Smoothness);
	float Roughness = smooth2rough(Smoothness);

	vec3 cspec = vec3(0);
	vec3 cdiff = vec3(0);
	get_colors(Albedo, Metalness, cspec, cdiff);

	float ambient_occlusion = GetSSAO();//TODO @Timon/Florian maybe it'd just be better to go back to the traditional subtract later in the frame...

	// PositionWS: vector from camera to pixel in world-space
// 	vec3 PositionWS = view_pos * mat3(M_view);
// 	PositionWS += V_cameraposition.xyz;
	vec3 PositionWS = view2world(view_pos);
	float3 PositionLS = EnvMapMulMatrix(M_envmapprobe_world, PositionWS);
// 	DebugStore(PositionLS); 	return;

	float blend = EnvMapFading(PositionLS);

	// apply lod fade-out
	blend *= U_fade_lod;

	// wv: direction from from pixel to camera in world-space
	vec3 wv = normalize(-view_pos) * mat3(M_view);
	float v_dot_n = saturate(dot(wv, wn));
	// smaller cone at edges to highlight fresnel
	
	//Jon Note, this is not a good idea, the energy intensity that you think you're simulating should already be covered in the fresnel term.
	#ifdef JON_MOD_DISABLE_EGOSOFT_SMOOTHER_GRAZING_ANGLE
		float ambRoughness = Roughness;
	#else
		// smaller cone at edges to highlight fresnel
		float ambRoughness = mix(Roughness*0.3, Roughness, pow(v_dot_n, 1.0/3.0));
		//ambRoughness = Roughness; // deactivated, effect too strong
	#endif	

	float ssr = 0;
	if (U_pass) {
		//Jon comment, I've seen worse :P
		ssr = SSR_GetHit(RTResolveSoft(T_ssr).a); // this seems like the least stupid way to get proper diffuse envmap probes while keeping specular SSR?:/
	}

	{
		vec3 R = reflect(-wv, wn);
		R = EnvMapAdjust(PositionWS, R);
		#ifdef JON_MOD_USE_RETROREFLECTIVE_DIFFUSE_MODEL
			#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
				if(GetViewPos().x > 0.0)
				{
					finalColor = combined_ambient_probe_brdf(S_input_rt, cspec, cdiff, wn, wv, R, ambRoughness, ambient_occlusion, ssr);
				}
				else
				{	
					float n_dot_v = saturate(dot(wn, wv));
					vec4 spec_amb = spec_brdf_ibl4(S_input_rt, cspec, ambRoughness, R, n_dot_v);
					spec_amb.rgb *= saturate(1 - ssr);//ssr takes priority over envmap probe specular, however the diffuse and alpha shouldn't be affected so that globallight can accurately mix everything together
					vec3 diff_amb = cdiff * get_irradiance(S_input_rt, wn);
			
					finalColor.rgb = (spec_amb.rgb + diff_amb) * ambient_occlusion;
					finalColor.a = spec_amb.a;
					finalColor.a = saturate(finalColor.a);
				}
			#else
				finalColor = combined_ambient_probe_brdf(S_input_rt, cspec, cdiff, wn, wv, R, ambRoughness, ambient_occlusion, ssr);
			#endif
		#else	
			float n_dot_v = saturate(dot(wn, wv));
			vec4 spec_amb = spec_brdf_ibl4(S_input_rt, cspec, ambRoughness, R, n_dot_v);
			spec_amb.rgb *= saturate(1 - ssr);//ssr takes priority over envmap probe specular, however the diffuse and alpha shouldn't be affected so that globallight can accurately mix everything together
			vec3 diff_amb = cdiff * get_irradiance(S_input_rt, wn);
	
			finalColor.rgb = (spec_amb.rgb + diff_amb) * ambient_occlusion;
			finalColor.a = spec_amb.a;
			finalColor.a = saturate(finalColor.a);
		#endif
	}
#ifdef LPASS_BLEND_DEBUG
	OUT_Color.rgb = IO_lightcolor.rgb;
	OUT_Color.a = 1;
	OUT_Color *= saturate(1 - ssr);	//arguable whether we want to know how ssr behaves?
#else
	OUT_Color.rgb = finalColor.rgb;
	OUT_Color.a = finalColor.a;
#endif
	OUT_Color *= blend;
}
