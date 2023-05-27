#define P1_SHADERS
#include <common.fh>


// HACK TO BOOS LOCAL SPEC!
#define SPEC_BOOST 2.0
#define DIFF_BOOST 1.0
#define SPEC_POWER 1.0 // 15.0

in float IO_Intensity;
in vec3 IO_worldview_center;
in float IO_radius;
in float IO_SpecularIntensity;

in vec4 IO_worldviewpos;
in vec3 IO_lightcolor;

void main()
{
	OUT_Color = vec4(0);
	
	vec3 view_pos;
	RetrieveZBufferViewPos(view_pos);
	
	float3 L = IO_worldview_center - view_pos; // build L with light center and reconstructed Z pos
//	OUT_Color = vec4(IO_worldview_center.xyz/5000, 1);
	
 	float LightDistance = length(L);
//	OUT_Color = half4(LightDistance/IO_radius, 0, 0, 1);

	if (LightDistance > IO_radius) {
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}

	vec3 l = normalize(L);
	
	vec3 Normal;
	RI_GBUFFER_NORMAL0(Normal);
	
	float Metalness;
	float Smoothness;
	RI_GBUFFER_METAL_SMOOTH(Metalness, Smoothness);
	
	float n_dot_l = saturate(dot(l, Normal));
	float SubsurfaceMask = 0;
	#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING	
		SubsurfaceMask = max(0.0, ceil(0.5 - Metalness));
		if (n_dot_l + SubsurfaceMask <= 0.0)
	#else
		if (n_dot_l <= 0.0)
	#endif
	{
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}

	vec3 Albedo;
	RI_GBUFFER_BASECOLOR(Albedo);
	
	float Roughness = smooth2rough(Smoothness);
	
	vec3 v = normalize(-view_pos);
	
	vec3 cspec = vec3(0);
	vec3 cdiff = vec3(0);
	vec3 csub = vec3(0);
	vec3 SubsurfaceNormal = Normal;
	float Subsurface = 0;
	float RoughnessEpidermal = 0.5;
	
	#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
		get_colors(	Albedo, 
					Metalness, 
					Roughness, 
					cspec, 
					cdiff, 
					csub, 
					SubsurfaceNormal,
					Subsurface, 
					RoughnessEpidermal, 
					SubsurfaceMask);
	#else
		get_colors(Albedo, Metalness, cspec, cdiff);
	#endif

	#ifndef LOCALSPEC
		cspec *= 0.0f;
	#endif
	float n_dot_l_sss = sss_wrap_dot(l, SubsurfaceNormal, Subsurface);

	float radius = IO_radius*0.9;
	float a = pow(saturate(1.0f-pow(LightDistance/radius,4.0f)), 2.0f);
	float b = 1.0/pow(LightDistance, 2.0f) + 1.0f;
	float PSquareDistanceAtt = saturate(a/b);
	
	float4 finalColor;

//	finalColor.rgb = n_dot_l * lightcolor;
	
	#ifdef JON_MOD_DEBUG_DEBUG_LIGHT_TYPES
		vec3 lightcolor = vec3(0.0, 1.0, 0.0);
	#else	
		vec3 lightcolor = IO_lightcolor.rgb;
	#endif

	//TODO @Timon this is all so wrong, but historical reasons... 
#ifdef LOCALSPEC
	finalColor.rgb = EvalBRDF(cspec, cdiff, Roughness, l, v, Normal, vec3(n_dot_l, IO_SpecularIntensity * n_dot_l, n_dot_l_sss * SubsurfaceMask), Subsurface, RoughnessEpidermal, csub, SubsurfaceNormal, true) * lightcolor;
#else
	finalColor.rgb = EvalBRDF(cspec, cdiff, Roughness, l, v, Normal, vec3(n_dot_l, 0, n_dot_l_sss * SubsurfaceMask), Subsurface, RoughnessEpidermal, csub, SubsurfaceNormal, false) * lightcolor;
#endif

	float atten = PSquareDistanceAtt;
	finalColor.rgb *= atten;
	finalColor.a = 1;
	
	finalColor = DEFERRED_HACK_TO_sRGB(finalColor);
	
	float diffuse_occlusion = 1.0f;// AO used to attenuate diffuse component
	if (B_ssao_enabled) {
		float ambient_occlusion = GetSSAO();
		diffuse_occlusion = saturate(ambient_occlusion);
	}
	else {//TODO @Timon without this the attenuation breaks with vulkan nvidia-381.22 geforce 650ti on linux
		  //looks like either glslang or nvidia-driver bug, or I'm not aware of some detail of the spec
		diffuse_occlusion = 1.0f;
	}

	OUT_Color.rgb = finalColor.rgb*diffuse_occlusion;
	OUT_Color.a = 0;

	LPASS_SHAPE_FINAL_ATTEN(atten)

#ifdef JON_MOD_DEBUG_DEBUG_LIGHT_TYPES_REACH
	OUT_Color.rgb = lightcolor;
#endif
#ifdef LPASS_COUNT
	OUT_Color *= FLOAT_SMALL_NUMBER;

	if (IO_Intensity == 0.0) {
		discard ;
	}
	OUT_Color.rgb += 1.0f / LPASS_COUNT;
#endif
}
