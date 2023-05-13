#define P1_SHADERS
#include <common.fh>


//TODO
// wenn radius > 0.5*length, gibt es artefakte an den stirnflächen! 

// HACK TO BOOS LOCAL SPEC!
#define SPEC_BOOST 2.0
#define DIFF_BOOST 1.0
#define SPEC_POWER 1.0 // 15.0

in float IO_radius;
in float IO_SpecularIntensity;
in vec3 IO_l1;
in vec3 IO_l2;
in vec3 IO_center;
in vec4 IO_worldviewpos;
in vec3 IO_lightcolor;
in float IO_Intensity;

void main()
{
	OUT_Color = vec4(0);
	
	CONST half2 LightPower = half2(SPEC_POWER, 6.2); // We need power from light here

	vec3 view_pos;
	RetrieveZBufferViewPos(view_pos);

 	// Calculate the frustum ray using the view-space position.
    CONST float3 PositionWV = (IO_worldviewpos.xyz / IO_worldviewpos.z) * view_pos.z; // scale back to z = 1.0 and scale to stored Z
	
	float Ldist = length(IO_l2 - IO_l1);
	Ldist *=Ldist;
	float t = dot(IO_l1 - PositionWV, IO_l2 - IO_l1) / Ldist;
	t = saturate(-t);
 	float3 Lx = IO_l1 + (t * (IO_l2 - IO_l1));
 	
	// Start normal light calculations
	CONST float3 L = Lx.xyz - PositionWV.xyz; // build L with light center and reconstructed Z pos
	
	CONST float LightDistance = length(L);

	if (LightDistance > length(IO_l2 - IO_l1) + IO_radius) {
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}

	CONST half DistanceNorm2 = IO_radius*0.9/LightDistance;
	CONST half PSquareDistanceAtt = saturate( 1.0 - 1.0/ pow(DistanceNorm2,2.0));

	if (PSquareDistanceAtt <= 0) {
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}
	
	vec3 Normal;
	RI_GBUFFER_NORMAL0(Normal);
	
	float n_dot_l = saturate(dot(Normal, normalize(L)));
	if (n_dot_l <= 0.0f) {
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}
	
	vec4 finalColor = vec4(0);
	vec3 l0 = IO_l1 - view_pos;
	vec3 l1 = IO_l2 - view_pos;
	vec3 n = (Normal);
	vec3 v = normalize(-view_pos.xyz);
	
	vec3 Albedo;
	float Metalness;
	float Smoothness;
	RI_GBUFFER_BASECOLOR(Albedo);
	RI_GBUFFER_METAL_SMOOTH(Metalness, Smoothness);
	
	float Roughness = smooth2rough(Smoothness);

	vec3 cspec = vec3(0);
	vec3 cdiff = vec3(0);

	#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
		float Subsurface = 0.0;
		UnpackMetalSubsurface(Metalness, Subsurface);
	#endif

	get_colors(Albedo, Metalness, cspec, cdiff);
#ifndef LOCALSPEC
	cspec = cspec * 0.0f;
#endif
	#ifdef JON_MOD_DEBUG_DEBUG_LIGHT_TYPES
		vec3 lightcolor = vec3(1.0, 0.0, 1.0);
	#else	
		vec3 lightcolor = IO_lightcolor.rgb;
	#endif
	
	vec3 clight = lightcolor;

	float diffuse_occlusion = 1.0f;
	if (B_ssao_enabled) {
		float ambient_occlusion = GetSSAO();
		diffuse_occlusion = saturate(ambient_occlusion);
	}
	
#ifdef LOCALSPEC
	finalColor.rgb = EvalBRDF(cspec, cdiff, Roughness, normalize(L), v, n, vec2(1, IO_SpecularIntensity)) * clight * n_dot_l;
#else 
	finalColor.rgb = EvalBRDF(cspec, cdiff, Roughness, normalize(L), v, n, vec2(1, 0)) * clight * n_dot_l;
#endif
	float atten = PSquareDistanceAtt;
	finalColor.rgb *= atten;

	finalColor.rgb = DEFERRED_HACK_TO_sRGB(finalColor.rgb);

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
