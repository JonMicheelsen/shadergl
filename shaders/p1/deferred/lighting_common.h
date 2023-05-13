/************************************************************************
    Lighting things
************************************************************************/

#define DEFERRED_HACK_TO_linearRGB(val)	(val)
#define DEFERRED_HACK_TO_sRGB(val)		(val)

#include <common_light.h>
#include <jon_mod_lighting_functions.h>

int IrradianceLevel()
{
	return int(F_ibl_maxvalidlevel);
}

int IrradianceLevel(samplerCube filtered_env_map)
{
	return textureQueryLevels(filtered_env_map) - 1;
}

float smooth2rough(in float smoothness) {
	return saturate(1.01f - smoothness);
	return 0.0001f + (1-smoothness) * (1-smoothness);
}

// redirect reflection based on roughness
float3 get_lobe_dominant_dir(float3 N, float3 R, float roughness) {
	float smoothness = saturate(1 - roughness);
	float lerpFactor = smoothness * (sqrt(smoothness) + roughness);
	return lerp(N, R, lerpFactor);
}

// DFG term approx
float3 DFGAnalytic( float3 cspec, float gloss, float n_dot_v ) {
    float x = gloss;
    float y = n_dot_v;

    float b1 = -0.1688;
    float b2 = 1.895;
    float b3 = 0.9903;
    float b4 = -4.853;
    float b5 = 8.404;
    float b6 = -5.069;
    float bias = saturate( min( b1 * x + b2 * x * x, b3 + b4 * y + b5 * y * y + b6 * y * y * y ) );

    float d0 = 0.6045;
    float d1 = 1.699;
    float d2 = -0.5228;
    float d3 = -3.603;
    float d4 = 1.404;
    float d5 = 0.1939;
    float d6 = 2.661;
    float delta = saturate( d0 + d1 * x + d2 * y + d3 * x * x + d4 * x * y + d5 * y * y + d6 * x * x * x );
    float scale = delta - bias;

    bias *= saturate( 50.0 * cspec.y );
    return cspec * scale + bias;
}

// simple tonemapping
float A = 0.15;
float B = 0.50;
float C = 0.10;
float D = 0.20;
float E = 0.02;
float F = 0.30;
float W = 11.2;

// uncharted2/naughty dog tonemap
// (cmp. http://filmicgames.com/archives/75 https://mynameismjp.wordpress.com/2010/04/30/a-closer-look-at-tone-mapping/)
float3 u2Tonemap(float3 x)
{
	return ((x*(A*x + C*B) + D*E) / (x*(A*x + B) + D*F)) - E / F;
}


/************************************************************************
    IBL + sampling
************************************************************************/
float G_Schlick_GGX(float k, float n_dot_v)
{
	return n_dot_v / (n_dot_v * (1.0f - k) + k);
} 
float G_Smith(float k, float n_dot_v, float n_dot_l)
{
	return G_Schlick_GGX(k, n_dot_v) * G_Schlick_GGX(k, n_dot_l);
}


/************************************************************************
    BRDF
************************************************************************/
vec3 EvalBRDF(in vec3 cspec, in vec3 cdiff, in float roughness, in vec3 l, in vec3 v, in vec3 n, in vec2 mask) {
	
#ifdef JON_MOD_USE_STRICTER_N_DOT_V
    CONST float e = 0.0001f;
	float n_dot_v = abs(dot(n, v)) * (1.0 - e) + e;//the n and v are normalized, we shouldn't need the clamp
#else	
    CONST float e = 0.00000001f;
	float n_dot_v = saturate(abs(dot(n, v))+e);
	// float n_dot_v = max(e, dot(n, v));
#endif
	vec3 h = normalize(v+l);
	float n_dot_l = saturate(dot(n, l));
	float n_dot_h = saturate(dot(n, h));
	// float l_dot_h = saturate(dot(l, h));
	float v_dot_h = saturate(dot(v, h));
	
	float a = roughness*roughness;
	// a = roughness; // test
	float a2 = a*a;
	float k = a/2;
	
	float d = (n_dot_h * a2 - n_dot_h) * n_dot_h +1;
	float D = (a2 / ( PI*d*d) );
	// float D = (a2 / max(e, PI*d*d) );
	
	//course_notes_moving_frostbite_to_pbr_v32
// 	float V = 0.5 * 1.0/( n_dot_l * ( n_dot_v * (1-a)+a) + n_dot_v * ( n_dot_l * (1-a)+a));
	float V = 0.5 * 1.0/max(e, n_dot_l * ( n_dot_v * (1-a)+a) + n_dot_v * ( n_dot_l * (1-a)+a));//happens with MSAA on mesh edges, there are other ways to catch it (e.g. early per-light if (n_dot_l <= 0) discard) but this seems the most universal at first glance? although it could result in more pronounced highlights at edges? TODO @Timon/Markus test
	
#ifdef JON_MOD_USE_LUMINANCE_FRESNEL
	vec3 F = schlick_f(cspec, v_dot_h);
#else
	float f = pow(1-v_dot_h, 5);
	// https://cdn2.unrealengine.com/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf
// 	float f = exp2( ( -5.55473 * v_dot_h - 6.98316 ) * v_dot_h );
	vec3 F = f + (1-f) * cspec;
#endif
	float f_diff = pow(1-n_dot_v, 5);
	// 	vec3 diff = f_diff + (1-f_diff) * cdiff;
	// energy conservation using reflectance luminance
	// vec3 albedo = cdiff * saturate( 1.0f - dot(LUM_ITU601, cspec));
#ifdef JON_MOD_USE_RETROREFLECTIVE_DIFFUSE_MODEL
	float arealight_weight = 1.0;
	cdiff = chan_diff(cdiff, a2, n_dot_v, n_dot_l, v_dot_h, n_dot_h, arealight_weight, cspec);
#else
	cdiff = cdiff * saturate(1.0f - dot(LUM_ITU601, cspec));
	cdiff *= (1.0 / PI);
#endif	
	// return vec3(v_dot_h);
	// return (cdiff/PI);
	return cdiff*mask.x + (D*V*F)*mask.y;

}
vec3 EvalBRDF(in vec3 cspec, in vec3 cdiff, in float roughness, in vec3 l, in vec3 v, in vec3 n) {
	return EvalBRDF(cspec, cdiff, roughness, l, v, n, vec2(1));
}

// simplified cook torrance
vec3 EvalBRDFSimple(in vec3 cspec, in vec3 cdiff, in float roughness, in vec3 l, in vec3 v, in vec3 n) {
	
	vec3 h = normalize(v+l);
	float n_dot_l = saturate(dot(n, l));
	float n_dot_h = saturate(dot(n, h));
	
	float a = roughness*roughness;
	float a2 = a*a;
	float k = a/2;
	
	float d = (n_dot_h * a2 - n_dot_h) * n_dot_h +1;
	float D = (a2 / ( PI*d*d) );
	float V = 0.25;
	vec3 F = cspec;
	return (cdiff/PI) + (D*V*F);
}
// simplified cook torrance returning specular color only
vec3 EvalBRDFSimpleSpec(in vec3 cspec, in float roughness, in vec3 l, in vec3 v, in vec3 n) {

	CONST vec3 h = normalize(v + l);
	CONST float n_dot_h = saturate(dot(n, h));

	//float a = roughness*roughness;
	CONST float a2 = roughness*roughness*roughness*roughness;
	

	CONST float d = (n_dot_h * a2 - n_dot_h) * n_dot_h + 1;
	CONST float D = (a2 / (PI*d*d));
	CONST float V = 0.25;
	CONST vec3 F = cspec;
	return (D*V*F);
}

/************************************************************************
    Area lights
************************************************************************/
// area local lights, modify light direction + energy
float EvalSphereLight(float radius, vec3 center, vec3 v, vec3 n, vec3 R, float roughness, out vec3 L) {

	float m = roughness*roughness;
	// m = roughness; // test, needed?
	float invdistance = 1 / sqrt(dot(center, center));
	
	// representative point method for area specular
	float3 centertoray = dot( center, R ) * R - center; // vector from sphere center to closest point on ray
	float3 pointsurface = center + centertoray * saturate( radius / sqrt( max(0.0001f, dot( centertoray, centertoray ) ) )); // closest point on sphere surface
	L = (pointsurface);
	// L = normalize(pointsurface);
	
	// sphere energy normalization
	float sphereangle = saturate( radius * invdistance );
	float spherenorm = m / saturate( m + 0.5 * sphereangle );
	// other spherenorm
	spherenorm = 1.0 / (1.0 + (1.0 / (PI * max(0.001f, m)))*sphereangle);
	return spherenorm;
	return spherenorm * spherenorm;
}

float EvalTubeLight(float radius, vec3 l0, vec3 l1, vec3 v, vec3 n, vec3 R, float roughness, out vec3 L) {
	float m = roughness*roughness;
	 m = roughness; // test
	float tube_length = length(l1 - l0);
	vec3 tubecenter = (l0+l1)/2;
	float invdistance = 1 / sqrt(dot(tubecenter, tubecenter));

	// closest point on line
	float3 L01 = l1 - l0; // tube line
	float a = pow( tube_length , 2);
	float b = dot( R, L01 );
	float t = saturate( dot( l0, b*R - L01 ) / (a - b*b) );
	vec3 linepoint = l0 + t * L01; // closest point on tube

	float tubenorm = m / saturate(m + 0.5 * saturate(tube_length * invdistance));

	// apply sphere approx
	return tubenorm * EvalSphereLight(radius, linepoint, v, n, R, roughness, L);
}

/************************************************************************
    Image based lighting
************************************************************************/

vec4 spec_first_sum_ibl(samplerCube filtered_env_map, float roughness, vec3 normal, vec3 view)
{
	vec3 R = reflect(-view, normal);

	// R = mix( R, get_lobe_dominant_dir(normal, R, rm),rm*rm);
	// R = get_lobe_dominant_dir(normal, R, rm);

	// sqrt to compensate for precision shift
	float sqrtrough = (roughness); //sqrt(roughness);
	//TODO @Timon/Florian/Markus that sqrt was important for correctness, we should look into un-fuck-up-ing it
	return textureLod(filtered_env_map, R, MaxSpecularLevel(filtered_env_map) * sqrtrough);
}

vec4 spec_first_sum_ibl(samplerCube filtered_env_map, float roughness, vec3 reflectdir)
{
	// sqrt to compensate for precision shift
	float sqrtrough = (roughness); //sqrt(roughness);
	//TODO @Timon/Florian/Markus that sqrt was important for correctness, we should look into un-fuck-up-ing it

	return textureLod(filtered_env_map, reflectdir, MaxSpecularLevel(filtered_env_map) * sqrtrough);
}

vec3 spec_brdf(vec3 first_sum, vec3 spec_color, float roughness, float n_dot_v)
{
	//float fslum = length(first_sum);
	//first_sum = pow(first_sum, vec3(3)) * 4;
	//first_sum = pow(first_sum, vec3(3))*2 ;
	//return first_sum;

	vec2 env_brdf = textureLod(T_preintegrated_GGX, vec2(roughness, n_dot_v), 0).xy;
	return first_sum * (spec_color * env_brdf.x + env_brdf.y);
}

vec4 spec_brdf_ibl4(samplerCube filtered_env_map, vec3 spec_color, float roughness, vec3 reflectdir, float n_dot_v)
{
	vec4 first_sum = spec_first_sum_ibl(filtered_env_map, roughness, reflectdir);
	return vec4(spec_brdf(first_sum.rgb, spec_color, roughness, n_dot_v), first_sum.a);
}

vec3 spec_brdf_ibl(samplerCube filtered_env_map, vec4 refl_override, vec3 amblight, vec3 spec_color, float roughness, vec3 normal, vec3 view)
{
	float n_dot_v = saturate(dot(normal, view));

	vec3 first_sum = mix(spec_first_sum_ibl(filtered_env_map, roughness, normal, view).rgb, refl_override.rgb, refl_override.a);
	first_sum += amblight;

	return spec_brdf(first_sum, spec_color, roughness, n_dot_v);
}

vec3 spec_brdf_ibl(vec4 refl_override, vec3 amblight, vec3 spec_color, float roughness, vec3 normal, vec3 view)
{
	return spec_brdf_ibl(T_ibl_envmap, refl_override, amblight, spec_color, roughness, normal, view);
}

vec3 simple_spec_brdf_ibl(samplerCube filtered_env_map, vec3 spec_color, float roughness, vec3 normal, vec3 view) {

	float n_dot_v = saturate(dot(normal, view));
	vec3 R = reflect(-view, normal);

	// sqrt to compensate for precision shift
	float sqrtrough = sqrt(roughness);
	vec3 first_sum = textureLod(filtered_env_map, R, MaxSpecularLevel(filtered_env_map) * sqrtrough).rgb;

	first_sum = DEFERRED_HACK_TO_linearRGB(first_sum);
	
	//return DFGAnalytic(spec_color, 1-roughness, n_dot_v);
	return first_sum * DFGAnalytic(spec_color, 1-roughness, n_dot_v);
}

vec3 get_irradiance(samplerCube filtered_env_map, in vec3 n) {
	vec3 irradiance = textureLod(filtered_env_map, n, IrradianceLevel(filtered_env_map)).rgb;
	irradiance = DEFERRED_HACK_TO_linearRGB(irradiance);
	return irradiance;
}

void get_colors(in vec3 albedo, in float metalness, out vec3 cspec, out vec3 cdiff) {
	#ifdef JON_MOD_DEBUG_GREY_WORLD
		albedo = vec3(0.5);
	#endif
    cdiff = albedo * (1.0-metalness);
    cspec = mix(vec3(0.04), albedo, metalness);
	cdiff = cdiff * saturate(1.0f - dot(LUM_ITU601, cspec)); // cheap luminance energy conservation
}

// simplified forward lighting, no ssao, no shadows
vec3 simple_light(in vec3 clight, in vec3 l, in vec3 n, in vec3 v, in vec3 albedo, in float metalness, in float roughness)
{
    vec3 cspec;
    vec3 cdiff;
/*
	//include is not included here, and simple_light is not used by Egosoft
	#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
		float Subsurface = 0.0;
		UnpackMetalSubsurface(metalness, Subsurface);
	#endif
*/	

   get_colors(albedo, metalness, cspec, cdiff);
	float n_dot_l = saturate(dot(n, l));
    
    vec3 result = vec3(0);
    result += EvalBRDF(cspec, cdiff, roughness, l, v, n) * clight * n_dot_l;

	vec3 wv = v * mat3(M_view);
	vec3 wn = n * mat3(M_view);
	wv = v;
	wn = n;

    vec3 spec_amb = simple_spec_brdf_ibl(T_ibl_envmap, cspec, roughness, wn, wv);
	vec3 diff_amb = cdiff * get_irradiance(T_ibl_envmap, wn);

	vec3 ambientlight = spec_amb + diff_amb;

    result += ambientlight;
	// result = cdiff;
	result.rgb = DEFERRED_HACK_TO_sRGB(result);
    return result;
}

float GetSSAO()
{
	if (B_ssao_enabled) {
		return RTResolveSoft(T_occlusionresolve_swap).r;
	}
	return 1.0;
}
