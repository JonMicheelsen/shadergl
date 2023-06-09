#define P1_SHADERS
#include <common.fh>


// HACK TO BOOS LOCAL SPEC!
#define SPEC_BOOST 2.0
#define DIFF_BOOST 1.0
#define SPEC_POWER 1.0 // 15.0

//gl_Position				// Pos						: POSITION;
in vec3 IO_lightcolor;		// LightColor / TEXCOORD1
in vec3 IO_direction;		// Direction				: TEXCOORD2;
in vec3 IO_apex;			// Apex	: TEXCOORD3;
in vec3 IO_range_radius_index;	// Range_Radius				: TEXCOORD4;
in float IO_SpecularIntensity;
in float IO_Intensity;

/*
float getPhysicalAtt(in vec3 lraw) {
	// CONST float invSqScale = 1.0/5.0; // better color behavior over large distances
	CONST float invSqScale = 1.0; // no scaling
								  // return 1.0 / ( 1 + dot(lraw, lraw)); // "inverse square" attenuation
	float dst = max(0.0f, length(lraw) - IO_range_radius_index.x) * invSqScale;
	//float dstFromSurfaceSq = max(0.0f, dot(invSqScale*lraw, invSqScale*lraw));
	//float dstFromSurfaceSq = dot(invSqScale*lraw, invSqScale*lraw);
	//dstFromSurfaceSq = 
	return 1.0 / (1 + dst*dst); // "inverse square" attenuation
								//return 1.0 / (1 + dstFromSurfaceSq); // "inverse square" attenuation
}
*/
void main()
{
	#ifdef JM_DEBUG_DEBUG_LIGHT_TYPES
		float level = dot(LUM_ITU601, IO_lightcolor.rgb);
		vec3 lightcolor = JM_SPOT * level;
	#else	
		vec3 lightcolor = IO_lightcolor.rgb * JM_SPOT;
	#endif
	
	OUT_Color = vec4(0);
	
	float index = IO_range_radius_index.z;
	
	vec3 view_pos;
	RetrieveZBufferViewPos(view_pos);
	
	// Calculate the frustum ray using the view-space position.
	CONST float3 PositionWV = (IO_worldview_pos.xyz / IO_worldview_pos.z) * view_pos.z; // scale back to z = 1.0 and scale to stored Z

	CONST float3 d = PositionWV - IO_apex;
	CONST float LightDistance = length(d);

	if (LightDistance > IO_range_radius_index.x) {
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}
	
	CONST float LinearDistanceAtt = pow(smoothstep(0.9f* IO_range_radius_index.x, 0.0f, LightDistance), 2.0f);// square falloff

	CONST half DistanceNorm2 = IO_range_radius_index.x / LightDistance;
	//CONST half PSquareDistanceAtt = saturate( 1.0 - 1.0/ pow(DistanceNorm2,2.0));

	float a = pow(saturate(1.0f - pow(LightDistance / IO_range_radius_index.x, 4.0f)), 2.0f);
	float b = 1.0 / pow(LightDistance, 2.0f) + 1.0f; //1.0f / pow(LightDistance, 2.0f) + 1.0f;
	float PSquareDistanceAtt = a / b;

	PSquareDistanceAtt = max(0.0f, (1.0f - 1.0f / ((pow(IO_range_radius_index.x / LightDistance, 0.20f)))) *(pow(IO_range_radius_index.x / LightDistance, 1.40f)));

	CONST float RadialDistance = length(cross(PositionWV - IO_apex, PositionWV - (IO_apex + IO_direction*10000.0f))) / length((IO_apex + IO_direction*10000.0f) - IO_apex);
	CONST float3 proj = float3(dot(IO_apex - PositionWV, (IO_direction*10000.0f) / length(IO_direction*10000.0f)));
	CONST float maxradialDist = sqrt(pow(LightDistance, 2.0) - pow(length(proj), 2.0));
	CONST float lightToSurfaceAngle = degrees(acos(dot(normalize(d), IO_direction)));
	//float RadialDistanceAtt = pow(smoothstep(IO_range_radius_index.y*0.95f,IO_range_radius_index.y*0.75f,lightToSurfaceAngle),1.0f/2.0f); //version restricted to fallof only on the outer cone!
	float RadialDistanceAtt = pow(smoothstep(IO_range_radius_index.y*0.95f, 0.0f, lightToSurfaceAngle), 1.0f / 2.0f);

	if (index > 1.0) {
		RadialDistanceAtt *= tex2D(S_diffuse_map, float2(1.0f - RadialDistanceAtt, 0.03125f + (index - 1.0f)*0.0625f)).r;
	}
	if (RadialDistanceAtt <= 0) {
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}
	
	vec3 Normal;
	RI_GBUFFER_NORMAL0(Normal);
	float Metalness;
	float Smoothness;
	RI_GBUFFER_METAL_SMOOTH(Metalness, Smoothness);
	
	float3 L = d.xyz - Normal * LightDistance * 0.5f;
	
	vec3 l;// = normalize(IO_apex - view_pos);
	l = normalize(-L);
	float n_dot_l = dot(Normal, l);
	#ifdef JM_ENABLE_SUBSURFACE_GBUFFER_PACKING	
		float SubsurfaceMask = max(0.0, ceil(0.5 - Metalness));
		if (n_dot_l + SubsurfaceMask <= 0.0)	{
	#else
		if (n_dot_l <= 0.0)	{
	#endif
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}
	vec3 v = normalize(-view_pos);
	
	vec3 Albedo;
	RI_GBUFFER_BASECOLOR(Albedo);
	
	float Roughness = smooth2rough(Smoothness);

	vec3 cspec = vec3(0);
	vec3 cdiff = vec3(0);
	#ifdef JM_ENABLE_SUBSURFACE_GBUFFER_PACKING
	vec3 csub = vec3(0);
	vec3 SubsurfaceNormal = Normal;
	float Subsurface = 0;
	float RoughnessEpidermal = 0.5;
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

	float n_dot_l_sss = sss_wrap_dot(l, SubsurfaceNormal, Subsurface);

//	vec3 clight = lightcolor;
	float diffuse_occlusion = 1.0f;
	if (B_ssao_enabled) {
		float ambient_occlusion = GetSSAO();
		diffuse_occlusion = saturate(ambient_occlusion);
	}
	else {//TODO @Timon without this the attenuation breaks with vulkan nvidia-381.22 geforce 650ti on linux
		  //looks like either glslang or nvidia-driver bug, or I'm not aware of some detail of the spec
		diffuse_occlusion = 1.0f;
	}
//	diffuse_occlusion = soft_micro_shadow(diffuse_occlusion, abs(n_dot_l));
	n_dot_l = saturate(n_dot_l);
	float3 light;
//	#if 0
//		#ifdef LOCALSPEC
//			light = EvalBRDF(cspec, cdiff, Roughness, l, v, Normal, vec2(1, IO_SpecularIntensity)) * lightcolor * n_dot_l;
//		#else
//			light = EvalBRDF(cspec, cdiff, Roughness, l, v, Normal, vec2(1, 0)) * lightcolor * n_dot_l;
//		#endif
//	#else
//		#ifdef LOCALSPEC
			light = EvalBRDF(cspec, cdiff, Roughness, l, v, Normal, vec3(n_dot_l, 0.0, n_dot_l_sss * SubsurfaceMask), Subsurface, RoughnessEpidermal, csub, SubsurfaceNormal, false) * lightcolor;
//		#else
//			light = EvalBRDF(cspec, cdiff, Roughness, l, v, Normal, vec3(n_dot_l, 0, n_dot_l * SubsurfaceMask), Subsurface, RoughnessEpidermal, csub, false) * lightcolor;
//		#endif
//	#endif
	
	float4 finalColor;
	finalColor.rgb = light;

	vec3 Ispec = lightcolor * (IO_SpecularIntensity * n_dot_l);

	finalColor.rgb += EvalBRDFSimpleSpec(cspec, Roughness, l, v, Normal) * Ispec;

	float atten = RadialDistanceAtt*PSquareDistanceAtt;
	finalColor.rgb *= atten;
	finalColor.a = 1;



	finalColor = DEFERRED_HACK_TO_sRGB(finalColor);
	
			
	#ifdef JM_OVERWRITE_VANILLA_LIGHT_INTENSITY_CLAMPS
		finalColor.rgb = clamp(finalColor.rgb, vec3(0.0), vec3(JM_OVERWRITE_VANILLA_LIGHT_INTENSITY_CLAMPS)); // safety
	#else	
//		finalColor.rgb = clamp(finalColor.rgb, vec2(0.0), vec3(10.0)); // safety
		finalColor.rgb = clamp(finalColor.rgb, vec3(0.0), vec3(2.0)); // reduce flares
	#endif

	OUT_Color.rgb = finalColor.rgb;
	OUT_Color.a = 0;
	
	LPASS_SHAPE_FINAL_ATTEN(atten)
#ifdef JM_DEBUG_DEBUG_LIGHT_TYPES_REACH
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
