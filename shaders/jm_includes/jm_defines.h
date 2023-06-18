////////////////// JON MOD HOLODECK //////////////////
//Included in the very end of common.h, that is included most anywhere
/*
	Comment out to enable or disable. Change variable after define if relevant to tweak. 
	Indented #defines means the top non indeted one need to be one for them to work
	Have fun!
*/
//safeguard for double includes. #pragma once is not always safe to use, so let's do it manually
#ifndef _JM_DEFINES_SET_
	#define JM_DISABLE_EGOSOFT_SMOOTHER_GRAZING_ANGLE //default on
	//#define JM_FIX_TUBELIGHT_ATTENUATION// PENDING, NOT DONE YET! no more hard curtoffs
	//#define JM_SPECULAR_OVERSHOOT_FIX // Fixed in other ways, cleanup later! Fixes geometric light white bright artefact

	#define JM_ROUGHNESS_REMAP // default on. Disney trick, since artists has a tendency to overuse the lower end of the roughness and neglect nuances in the high end, this one does a gentle remap improving both!
	#define JM_ROUGHNESS_REMAP_PRE_SQUARE_RANGE 0.4142f//default 0.4142f, at this point 0.5 = 0.5, 0 = 0.17 1=1
	#define JM_SSR_UNHARDEN //Vanilla SSR appears to be visually too smooth in it's roughness response compared to all other specular - per design, this mitigates this
	
	#define JM_SSAO_RANGE_BOOST 1.0 //vanilla is 1
	#define JM_SSAO_POW_BOOST 2.0 //vanilla is 2
	#define JM_SSAO_DARKEST_POINT 0.25 //vanilla is 0, but reaching pure 0 doesn't look great!
	//Trick that makes it look like lights are casting soft area shadows using wide SSAO, so needs a little SSAO boosting for best effect!
	#define JM_SOFT_MICRO_SHADOWS //approximation of soft shadows, that needs SSAO to be on to do anything!

	// Human skin lowest index of refraction(IOR)1.35 = 0.28 in unreal dieletric specular, or #47, rgb71, 28%brightness, as linear color
	// Human skin highest index of refraction(IOR)1.55 = 0.58 in unreal dieletric specular, or #94, rgb148, 58%brightness, as linear color
	// Human hair(and nails technically too) highest index of refraction(IOR)1.55 = 0.58 in unreal specular, or #94, rgb148,
	// Specular scale is 0.08, so (0.28 * 0.08) = 0.0224 (0.58 * 0.08) = 0.0464 , etc...
	//#define JM_USE_FAST_25TAP_CACSCADE_FILTER // Cant be activated currently, needs a sampler state change to work and I haven't yet figures out if that is even possible.
	#define JM_ENABLE_SUBSURFACE_GBUFFER_PACKING
		#define JM_ENABLE_SUBSURFACE_BIAS_BLUR_TRICK
		#define JM_SUBSURFACE_SUBDERMAL_ROUGHNESS 0.5
		#define JM_SUBSURFACE_EPIDERMAL_ROUGHNESS 0.0
		#define JM_SUBSURFACE_EPIDERMAL_TINT vec3(0.968750, 0.833764, 0.483325) //vec3(0.910580, 0.338275, 0.271800) vec3(1.000000,0.088964,0.072095)
		#define JM_SUBSURFACE_EPIDERMAL_F0 0.0224f	//se notes above
		#define JM_SUBSURFACE_SUBDERMAL_SPEC_CAP 0.95	
		#define JM_SUBSURFACE_WRAP_SCALE 0.0//default 0.25, 
		#define JM_SUBSURFACE_SQUARED_NDX //much more energetic but perhaps more natural looking 
		#define JM_SUBSURFACE_ID_COUNT 8
																							// 0 default no SSS
		#define JM_SUBSURFACE_SCATTER_RADIUS_HUMAN 			vec3(1.0	,0.627	,0.447) // 1 Human, just this for now... TODO implement the rest
		#define JM_SUBSURFACE_SCATTER_RADIUS_TELADI 		vec3(0.749	,0.569	,0.267) // 2 losely based on berber skink
		#define JM_SUBSURFACE_SCATTER_RADIUS_BORON 			vec3(0.263	,0.882	,0.859) // 3 blue greenish laguna like
		#define JM_SUBSURFACE_SCATTER_RADIUS_PARANID 		vec3(0.31	,0.247	,0.792) // 4 losely based on blue blooded horse shoe and purple blooded red rock crabs
		#define JM_SUBSURFACE_SCATTER_RADIUS_FOLIAGE 		vec3(0.6	,1.0	,0.060) // 5 spring leaves ish, good baseline
		#define JM_SUBSURFACE_SCATTER_RADIUS_ICE_ASTEROID 	vec3(0.357	,0.78	,1.000) // 6 water ice
		#define JM_SUBSURFACE_SCATTER_EYE					vec3(1.0	,0.627	,0.447) // 7 eyes probably pretty generic?
	//	#define JM_BORON_SUBSURFACE_GLOW //disabled in the code, needs more polish!
	#define JM_ENABLE_FULL_ANGLE_CORRECTED_CHARACTER_NORMAL_COMPOSITING

	#define JM_USE_RETROREFLECTIVE_DIFFUSE_MODEL//This upgrades EvalBRDF() to include this https://advances.realtimerendering.com/s2018/MaterialAdvancesInWWII-course_notes.pdf Which UE5 also uses.
		#define JM_USE_AMBIENT_DIFFUSE_TRICKS
		#define JM_USE_AMBIENT_SPECULAR_TRICKS
		#define JM_USE_AMBIENT_SPECULAR_TRICKS_PROBE_VERSION //don't know if this needs it since it already parallax corrects. Now it can be turned off seperately.

	#define JM_USE_LUMINANCE_FRESNEL
		#define JM_USE_STRICTER_N_DOT_V
	#define JM_SSR_WIDER_ROUGH_SCATTER
	//#define JM_SSR_ANGLES_SHARPEN_POW5
	#define JM_SSR_DISCARD_BAD_NORMAL_MAPPING
	#define JM_USE_DISCARD_AREALIGHT_MORE
	#define JM_SSSHADOWS //default on
		//near and far
		//#define JM_SSSHADOWS_SUPPORT_BOTH_PRIMARY_LIGHTS //default on
		#define JM_SSSHADOWS_MAX_STEPS 32 //default
		//#define JM_SSSHADOWS_DITHER 4.0
		//#define JM_SSSHADOWS_SHARPNESS 1.0
		//far
		#define JM_SSSHADOWS_FADE_DISTANCE 5000.0 //not all PCF shadows have the same distance, so some lods will still shadow pop if we just use that, so with this we can enforce a max distance where everything will use Screenspace Shadows
		#define JM_SSSHADOWS_RAY_MAX_DISTANCE 1000.0 //default 1000.0 = 100.0m distance. I think 1 is about 10cm, so a hundred meters is 10000
		#define JM_SSSHADOWS_BIAS 1.0 //default 10.0 = 1.0m
		#define JM_SSSHADOWS_MAX_THICKNESS 250.0 //default 250.0 = 25.0m shadows thicker than this from the camera are ignored, so as to things near ain't casting shadows on things far
		//near
		#define JM_SSSHADOWS_FADE_DISTANCE_NEAR 10.0 
		#define JM_SSSHADOWS_RAY_MAX_DISTANCE_NEAR 0.1//10cm
		#define JM_SSSHADOWS_BIAS_NEAR 0.005
		#define JM_SSSHADOWS_MAX_THICKNESS_NEAR 0.025//2.5cm
//		#define JM_SSSHADOWS_ATTENUATION_NEAR 1.0 //optional soft fade near shadows
		//filtering
		#define JM_SSSHADOWS_FORCE_TEXELFETCH //cheaper and no subpixel edge artefacts
		#define JM_SSSHADOWS_FILTER // filters with screenspace derivatives, might give very different result at different resolution
	//	#define JM_SSSHADOWS_DEBUG_MODE
	//		#define JM_SSSHADOWS_LIGHT_TO_DEBUG 0 //options are 0 or 1 only!
	
	/// these should all be 1 always, but it allows you to preview each in their isolation by setting the others to 0
	#define JM_GLOBAL_DIFFUSE_INTENSITY 1.0
	#define JM_GLOBAL_SPECULAR_INTENSITY 1.0
	#define JM_GLOBAL_SUBSURFACE_INTENSITY 1.0
	#define JM_OVERWRITE_VANILLA_LIGHT_INTENSITY_CLAMPS 10.0 //default is 2.0
	//enabling this tonemaps all existing glows to 0-1 range, so the JM_GLOWS has a more uniform effect
	#define JM_GLOWS_LEVELLED 0.9//0-1 range blend of levelled part
	//increase to boost globally!
	#define JM_GLOWS	vec3(11.0, 11.0, 11.0)	
	//#define JM_DEBUG_DEBUG_LIGHT_TYPES_REACH
	//#define JM_DEBUG_DISABLE_AMBIENT_LIGHT
	//#define JM_DEBUG_DEBUG_LIGHT_TYPES
	//Don't comment out the below defined or all lights will break
	#ifdef JM_DEBUG_DEBUG_LIGHT_TYPES
		#define JM_AREA 	vec3(0.50, 0.00, 1.00) * 1.0	//l_pass_arealight.f	    purple
		#define JM_AREA_GEN vec3(1.00, 0.33, 0.00) * 1.0 	//l_pass_arealight_gen.f	orange +
		#define JM_BOX 		vec3(0.00, 0.50, 1.00) * 0.05	//l_pass_boxlight.f	        blue +
		#define JM_POINT 	vec3(0.00, 1.00, 0.00) * 1.0	//l_pass_pointlight.f	    green +
		#define JM_SPOT 	vec3(1.00, 0.00, 1.00) * 1.0	//l_pass_spotlight.f	    magenta
		#define JM_STAR1 	vec3(1.00, 0.00, 0.00) * 1.0	//common.fh	            	red
		#define JM_STAR2 	vec3(1.00, 1.00, 0.00) * 1.0	//common.fh	            	yellow//this one is probably not used!
		#define JM_PROBE 	vec3(0.00, 1.00, 0.33) * 1.0	//l_pass_envmap_probe.f	    teal
	#else
		#define JM_AREA 	vec3(1.0) * 1.0			        //increase to boost globally!
		#define JM_AREA_GEN vec3(1.0) * 1.0				    //increase to boost globally!
		#define JM_BOX 		vec3(1.0) * 1.0				    //increase to boost globally!
		#define JM_POINT 	vec3(1.0) * 1.0			        //increase to boost globally!
		#define JM_SPOT 	vec3(1.0) * 1.0			        //increase to boost globally!
		#define JM_STAR1 	vec3(1.0) * 1.0			        //increase to boost globally!
		#define JM_STAR2 	vec3(1.0) * 1.0			        //increase to boost globally!
		#define JM_PROBE 	vec3(1.0) * 1.0			        //increase to boost globally!
	#endif

	//#define JM_DEBUG_SUBSURFACE_NORMALS
	//#define JM_DEBUG_BASE_NORMALS
	//#define JM_DEBUG_GREY_WORLD
	//#define JM_DEBUG_WHITE_FURNACE_AMBIENT
	//#define JM_DEBUG_SUBSURFACE
	//debugs

	//#define JM_COMPARE_VANILLA_SPLIT_SCREEN

	#define INVPI (0.318309886f)
	#define _JM_DEFINES_SET_	
#endif	