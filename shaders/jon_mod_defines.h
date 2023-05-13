////////////////// JON MOD HOLODECK //////////////////
//Included in the very end of common.h, that is included most anywhere
/*
	Comment out to enable or disable. Change variable after define if relevant to tweak. 
	Indented #defines means the top non indeted one need to be one for them to work
	Have fun!
*/

//#define JON_MOD_SPECULAR_OVERSHOOT_FIX //default on, fixes geometric light white bright artefact
#define JON_MOD_DISABLE_EGOSOFT_SMOOTHER_GRAZING_ANGLE //default on

#define JON_MOD_ROUGHNESS_REMAP // default on. Disney trick, since artists has a tendency to overuse the lower end of the roughness and neglect nuances in the high end, this one does a gentle remap improving both!
#define JON_MOD_ROUGHNESS_REMAP_PRE_SQUARE_RANGE 0.4142f//default 0.4142f, at this point 0.5 = 0.5, 0 = 0.17 1=1

// Human skin lowest index of refraction(IOR)1.35 = 0.28 in unreal specular, or #47, rgb71, 28%brightness, as linear color
// Human skin highest index of refraction(IOR)1.55 = 0.58 in unreal specular, or #94, rgb148, 58%brightness, as linear color
// Human hair(and nails technically too) highest index of refraction(IOR)1.55 = 0.58 in unreal specular, or #94, rgb148,
// Specular scale is 0.08, so (0.28 * 0.08), etc...
//#define JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
//	#define JON_MOD_SUBSURFACE_SUBDERMAL_ROUGHNESS 0.5
//	#define JON_MOD_SUBSURFACE_EPIDERMAL_ROUGHNESS -0.1
//	#define JON_MOD_SUBSURFACE_EPIDERMAL_F0 0.0224f

#define JON_MOD_USE_RETROREFLECTIVE_DIFFUSE_MODEL//This upgrades EvalBRDF() to include this https://advances.realtimerendering.com/s2018/MaterialAdvancesInWWII-course_notes.pdf Which UE5 also uses.
	#define JON_MOD_USE_AMBIENT_DIFFUSE_TRICKS
	#define JON_MOD_USE_AMBIENT_SPECULAR_TRICKS
	#define JON_MOD_USE_AMBIENT_SPECULAR_TRICKS_PROBE_VERSION //don't know if this needs it since it already parallax corrects. Now it can be turned off seperately.

#define JON_MOD_USE_LUMINANCE_FRESNEL
	#define JON_MOD_USE_STRICTER_N_DOT_V
#define JON_MOD_SSR_WIDER_ROUGH_SCATTER
#define JON_MOD_SSR_ANGLES_SHARPEN_POW5
#define JON_MOD_SSR_DISCARD_BAD_NORMAL_MAPPING

#define JON_MOD_SSSHADOWS //default on
	//near and far
	//#define JON_MOD_SSSHADOWS_SUPPORT_BOTH_PRIMARY_LIGHTS //default on
	#define JON_MOD_SSSHADOWS_MAX_STEPS 32 //default 64, it's pretty rare to ever go this high be aware this is a times 2
	//far
	#define JON_MOD_SSSHADOWS_FADE_DISTANCE 5000.0 //not all PCF shadows have the same distance, so some lods will still shadow pop if we just use that, so with this we can enforce a max distance where everything will use Screenspace Shadows
	#define JON_MOD_SSSHADOWS_DITHER 8.0 //default 1
	#define JON_MOD_SSSHADOWS_RAY_MAX_DISTANCE 100.0 //default 100.0 = 100.0m distance. I think 1 is about 10cm, so a hundred meters is 10000
	#define JON_MOD_SSSHADOWS_BIAS 1.0 //default 10.0 = 1.0m
	#define JON_MOD_SSSHADOWS_MAX_THICKNESS 1000.0 //default 1000.0 = 100.0m shadows thicker than this from the camera are ignored, so as to things near ain't casting shadows on things far
	//near
	#define JON_MOD_SSSHADOWS_RAY_MAX_DISTANCE_NEAR 0.25 //default 25cm
	#define JON_MOD_SSSHADOWS_BIAS_NEAR 0.1 //1.0cm
	#define JON_MOD_SSSHADOWS_MAX_THICKNESS_NEAR 0.5 //5cm
	#define JON_MOD_SSSHADOWS_FADE_DISTANCE_NEAR 25.0 // 25.0m
	#define JON_MOD_SSSHADOWS_ATTENUATION_NEAR 0.1 //optional soft fade near shadows
	//filtering
//	#define JON_MOD_SSSHADOWS_FILTER // filters with screenspace derivatives, might give very different result at different resolution
//	#define JON_MOD_SSSHADOWS_DEBUG_MODE
//		#define JON_MOD_SSSHADOWS_LIGHT_TO_DEBUG 0 //options are 0 or 1 only!

//#define JON_MOD_DEBUG_GREY_WORLD
//#define JON_MOD_DEBUG_WHITE_FURNACE_AMBIENT
//#define JON_MOD_DEBUG_DEBUG_LIGHT_TYPES
// aqua = l_pass_arealight_gen.f
// yellow = l_pass_arealight.f
// magenta = l_pass_boxlight.f
// green = l_pass_pointlight.f
// blue = l_pass_spotlight.f
// red = l_star_light1.
//#define JON_MOD_DEBUG_DISABLE_AMBIENT_LIGHT
//debugs

//#define JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN

#define INVPI (0.318309886f)
