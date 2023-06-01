////////////////// JON MOD HOLODECK //////////////////
//Included in the very end of common.h, that is included most anywhere
/*
	Comment out to enable or disable. Change variable after define if relevant to tweak. 
	Indented #defines means the top non indeted one need to be one for them to work
	Have fun!
*/
//TODO!
//#include <../../extensions/X4FoundationShaderMod/shadergl/shaders/jon_mod_util_functions.h>
//#include <../../extensions/X4FoundationShaderMod/shadergl/shaders/jon_mod_defines.h>

//#define JON_MOD_SPECULAR_OVERSHOOT_FIX //default on, fixes geometric light white bright artefact
#define JON_MOD_DISABLE_EGOSOFT_SMOOTHER_GRAZING_ANGLE //default on
#define JON_MOD_FIX_TUBELIGHT_ATTENUATION//no more hard curtoffs

#define JON_MOD_ROUGHNESS_REMAP // default on. Disney trick, since artists has a tendency to overuse the lower end of the roughness and neglect nuances in the high end, this one does a gentle remap improving both!
#define JON_MOD_ROUGHNESS_REMAP_PRE_SQUARE_RANGE 0.4142f//default 0.4142f, at this point 0.5 = 0.5, 0 = 0.17 1=1

// Human skin lowest index of refraction(IOR)1.35 = 0.28 in unreal dieletric specular, or #47, rgb71, 28%brightness, as linear color
// Human skin highest index of refraction(IOR)1.55 = 0.58 in unreal dieletric specular, or #94, rgb148, 58%brightness, as linear color
// Human hair(and nails technically too) highest index of refraction(IOR)1.55 = 0.58 in unreal specular, or #94, rgb148,
// Specular scale is 0.08, so (0.28 * 0.08) = 0.0224 (0.58 * 0.08) = 0.0464 , etc...

#define JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
	#define JON_MOD_ENABLE_SUBSURFACE_BIAS_BLUR_TRICK
	#define JON_MOD_SUBSURFACE_SUBDERMAL_ROUGHNESS 0.5
	#define JON_MOD_SUBSURFACE_EPIDERMAL_ROUGHNESS 0.0
	#define JON_MOD_SUBSURFACE_EPIDERMAL_TINT vec3(0.968750, 0.833764, 0.483325) //vec3(0.910580, 0.338275, 0.271800) vec3(1.000000,0.088964,0.072095)
	#define JON_MOD_SUBSURFACE_EPIDERMAL_F0 0.0224f	//se notes above
	#define JON_MOD_SUBSURFACE_SUBDERMAL_SPEC_CAP 0.95	
	#define JON_MOD_SUBSURFACE_WRAP_SCALE 0.1//default 0.25, 
	#define JON_MOD_SUBSURFACE_SQUARED_NDX //much more energetic but perhaps more natural looking 
	#define JON_MOD_SUBSURFACE_SCATTER_RADIUS_HUMAN 		vec3(1.0	,0.627	,0.447) // Human, just this for now... TODO implement the rest
	#define JON_MOD_SUBSURFACE_SCATTER_RADIUS_TELADI 		vec3(0.749	,0.569	,0.267) // losely based on berber skink
	#define JON_MOD_SUBSURFACE_SCATTER_RADIUS_BORON 		vec3(0.263	,0.882	,0.859) // blue greenish laguna like
	#define JON_MOD_SUBSURFACE_SCATTER_RADIUS_PARANID 		vec3(0.31	,0.247	,0.792) // losely based on blue blooded horse shoe and purple blooded red rock crabs
	#define JON_MOD_SUBSURFACE_SCATTER_RADIUS_FOLIAGE 		vec3(0.6	,1.0	,0.06) // spring leaves ish, good baseline
	#define JON_MOD_SUBSURFACE_SCATTER_RADIUS_ICE_ASTEROID 	vec3(0.357	,0.78	,1.0) //water ice
//	#define JON_MOD_BORON_SUBSURFACE_GLOW //disabled in the code, needs more polish!
#define JON_MOD_ENABLE_FULL_ANGLE_CORRECTED_CHARACTER_NORMAL_COMPOSITING

#define JON_MOD_USE_RETROREFLECTIVE_DIFFUSE_MODEL//This upgrades EvalBRDF() to include this https://advances.realtimerendering.com/s2018/MaterialAdvancesInWWII-course_notes.pdf Which UE5 also uses.
	#define JON_MOD_USE_AMBIENT_DIFFUSE_TRICKS
	#define JON_MOD_USE_AMBIENT_SPECULAR_TRICKS
	#define JON_MOD_USE_AMBIENT_SPECULAR_TRICKS_PROBE_VERSION //don't know if this needs it since it already parallax corrects. Now it can be turned off seperately.

#define JON_MOD_USE_LUMINANCE_FRESNEL
	#define JON_MOD_USE_STRICTER_N_DOT_V
#define JON_MOD_SSR_WIDER_ROUGH_SCATTER
//#define JON_MOD_SSR_ANGLES_SHARPEN_POW5
#define JON_MOD_SSR_DISCARD_BAD_NORMAL_MAPPING
#define JON_MOD_USE_DISCARD_AREALIGHT_MORE
#define JON_MOD_SSSHADOWS //default on
	//near and far
	//#define JON_MOD_SSSHADOWS_SUPPORT_BOTH_PRIMARY_LIGHTS //default on
	#define JON_MOD_SSSHADOWS_MAX_STEPS 32 //default 64, it's pretty rare to ever go this high be aware this is a times 2
	#define JON_MOD_SSSHADOWS_DITHER 0.0 //default 4.0
	//far
	#define JON_MOD_SSSHADOWS_FADE_DISTANCE 5000.0 //not all PCF shadows have the same distance, so some lods will still shadow pop if we just use that, so with this we can enforce a max distance where everything will use Screenspace Shadows
	#define JON_MOD_SSSHADOWS_RAY_MAX_DISTANCE 100.0 //default 100.0 = 100.0m distance. I think 1 is about 10cm, so a hundred meters is 10000
	#define JON_MOD_SSSHADOWS_BIAS 1.0 //default 10.0 = 1.0m
	#define JON_MOD_SSSHADOWS_MAX_THICKNESS 1000.0 //default 1000.0 = 100.0m shadows thicker than this from the camera are ignored, so as to things near ain't casting shadows on things far
	//near
	#define JON_MOD_SSSHADOWS_FADE_DISTANCE_NEAR 20.0 
	#define JON_MOD_SSSHADOWS_RAY_MAX_DISTANCE_NEAR 0.20
	#define JON_MOD_SSSHADOWS_BIAS_NEAR 0.05
	#define JON_MOD_SSSHADOWS_MAX_THICKNESS_NEAR 0.20 
	#define JON_MOD_SSSHADOWS_ATTENUATION_NEAR 1.0 //optional soft fade near shadows
	//filtering
	#define JON_MOD_SSSHADOWS_FILTER // filters with screenspace derivatives, might give very different result at different resolution
//	#define JON_MOD_SSSHADOWS_DEBUG_MODE
//		#define JON_MOD_SSSHADOWS_LIGHT_TO_DEBUG 0 //options are 0 or 1 only!

/// these should all be 1 always, but it allows you to preview each in their isolation by setting the others to 0
#define JON_MOD_GLOBAL_DIFFUSE_INTENSITY 1.0
#define JON_MOD_GLOBAL_SPECULAR_INTENSITY 1.0
#define JON_MOD_GLOBAL_SUBSURFACE_INTENSITY 1.0
	
//#define JON_MOD_DEBUG_SUBSURFACE_NORMALS
//#define JON_MOD_DEBUG_BASE_NORMALS
//#define JON_MOD_DEBUG_GREY_WORLD
//#define JON_MOD_DEBUG_WHITE_FURNACE_AMBIENT
//#define JON_MOD_DEBUG_DEBUG_LIGHT_TYPES
// orange = l_pass_arealight_gen.f
// teal = l_pass_arealight.f
// blue = l_pass_boxlight.f
// green = l_pass_pointlight.f
// magenta = l_pass_spotlight.f
// red = l_star_light1.
// aqua = l_star_light2.
// yellow = l_pass_envmap_probe.f
//#define JON_MOD_DEBUG_DEBUG_LIGHT_TYPES_REACH
//#define JON_MOD_DEBUG_DISABLE_AMBIENT_LIGHT
//#define JON_MOD_DEBUG_SUBSURFACE
//debugs

//#define JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN

#define INVPI (0.318309886f)
