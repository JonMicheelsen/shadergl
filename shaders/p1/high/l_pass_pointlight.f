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
	
	float n_dot_l = saturate(dot(l, Normal));
	if (n_dot_l <= 0.0f) {
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}

	vec3 Albedo;
	float Metalness;
	float Smoothness;
	RI_GBUFFER_BASECOLOR(Albedo);
	RI_GBUFFER_METAL_SMOOTH(Metalness, Smoothness);
	
	float Roughness = smooth2rough(Smoothness);
	
	vec3 v = normalize(-view_pos);
	
	vec3 cspec = vec3(0);
	vec3 cdiff = vec3(0);
	#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
		float Subsurface = 0.0;
		UnpackMetalSubsurface(Metalness, Subsurface);
	#endif
	get_colors(Albedo, Metalness, cspec, cdiff);
	#ifndef LOCALSPEC
		cspec *= 0.0f;
	#endif

	float radius = IO_radius*0.9;
	float a = pow(saturate(1.0f-pow(LightDistance/radius,4.0f)), 2.0f);
	float b = 1.0/pow(LightDistance, 2.0f) + 1.0f;
	float PSquareDistanceAtt = saturate(a/b);
	
	float4 finalColor;
	#ifdef JON_MOD_DEBUG_DEBUG_LIGHT_TYPES
		vec3 lightcolor = vec3(0.0, 1.0, 0.0);
	#else	
		vec3 lightcolor = IO_lightcolor.rgb;
	#endif
	
	//TODO @Timon this is all so wrong, but historical reasons... 
#ifdef LOCALSPEC
	finalColor.rgb = EvalBRDF(cspec, cdiff, Roughness, l, v, Normal, vec2(1, IO_SpecularIntensity)) * lightcolor * n_dot_l;
#else
	finalColor.rgb = EvalBRDF(cspec, cdiff, Roughness, l, v, Normal, vec2(1,0)) * lightcolor * n_dot_l;
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
#ifdef LPASS_COUNT
	OUT_Color *= FLOAT_SMALL_NUMBER;

	if (IO_Intensity == 0.0) {
		discard ;
	}
	OUT_Color.rgb += 1.0f / LPASS_COUNT;
#endif
}
