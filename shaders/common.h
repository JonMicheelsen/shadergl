
//#extension GL_ARB_shading_language_420pack : enable // not supported on OSX (10.10.4)

/*useful pragmas for nvidia
#pragma optionNV(fastmath on)
#pragma optionNV(fastprecision on)
#pragma optionNV(ifcvt none)
#pragma optionNV(inline all)
#pragma optionNV(strict on)
#pragma optionNV(unroll all)
#pragma optionNV(inline all)
*/

#define D_DYNAMIC 1
#define D_STATIC 2
#define D_SPECIAL 3

#define X_CONCAT(a,b) a##b

// #define centroid /*centroid*/	//workaround for RADV:/


	#define VK_BLOCK(name,block)			\
		layout(set = ENUM_BUFFER_##name, binding = 0, std140) uniform BUFFER_##name			\
		{			\
			block			\
		};


#ifdef XIMGUI
	#define I_HATE_MACROS			\
		uniform mat4 DEBUG_Matrix0;			\
		uniform mat4 DEBUG_Matrix1;			\
		uniform vec4 DEBUG_Vector0;			\
		uniform vec4 DEBUG_Vector1;			\
		uniform vec4 DEBUG_Vector2;			\
		uniform vec4 DEBUG_Vector3;			\
		uniform float DEBUG_Float0;			\
		uniform float DEBUG_Float1;			\
		uniform float DEBUG_Float2;			\
		uniform float DEBUG_Float3;			\
		uniform int DEBUG_Int0;				\
		uniform int DEBUG_Int1;				\
		uniform int DEBUG_Int2;				\
		uniform int DEBUG_Int3;
#else
	#define I_HATE_MACROS
#endif
	
VK_BLOCK(CAMERA,
	uniform mat4 M_view;
	uniform mat4 M_projection;
	uniform mat4 M_invprojection;
	uniform mat4 M_viewprojection;
	uniform mat4 M_viewinverse;
	
	uniform mat4 M_shadowCSM0Clip;
	uniform mat4 M_shadowCSM1Clip;
	
	uniform vec4 V_viewportpixelsize/* = vec4(1024, 768, 3, 5000000)*/;
	uniform vec4 V_cameraposition;
	
	uniform vec4 V_ambient1;

	uniform vec4 V_direction1;
	uniform vec4 V_lightcolor1;
	uniform vec4 V_direction2;
	uniform vec4 V_lightcolor2;
	uniform vec4 V_direction3;
	uniform vec4 V_lightcolor3;

	uniform vec4 V_light_direction_view[3];
	
	uniform vec4 V_tintcolor;			//for tinted_glass: DEF_AUTO_PARA(BlendColor	, TINTCOLOR				, float3	, {1.0, 1.0, 1.0})

	uniform vec4 V_csmthresholds;
	
	
	uniform vec4 V_volume_range;
	uniform vec4 V_volume_size;
	
	uniform vec4 V_volume_scatter_power[GFX_MAX_VOLUME_TYPES];
	uniform vec4 V_volume_sigma_extinction[GFX_MAX_VOLUME_TYPES];
	
	uniform vec4 V_volume_phase0_param[GFX_MAX_VOLUME_TYPES];
	uniform vec4 V_volume_phase1_param[GFX_MAX_VOLUME_TYPES];
	uniform vec4 V_volume_phase2_param[GFX_MAX_VOLUME_TYPES];
	
	uniform ivec4 I_volume_phases[GFX_MAX_VOLUME_TYPES];
/*	uniform int I_volume_phase_num[GFX_MAX_VOLUME_TYPES];
	uniform int I_volume_phase0[GFX_MAX_VOLUME_TYPES];
	uniform int I_volume_phase1[GFX_MAX_VOLUME_TYPES];
	uniform int I_volume_phase2[GFX_MAX_VOLUME_TYPES];*/
	
/*	uniform vec4 V_volume_type0_scatter_power;
	uniform vec4 V_volume_type0_sigma_extinction;
	
	uniform vec4 V_volume_type0_phase0_param;
	uniform vec4 V_volume_type0_phase1_param;
	uniform vec4 V_volume_type0_phase2_param;
	
	uniform vec4 V_volume_type1_scatter_power;
	uniform vec4 V_volume_type1_sigma_extinction;
	
	uniform vec4 V_volume_type1_phase0_param;
	uniform vec4 V_volume_type1_phase1_param;
	uniform vec4 V_volume_type1_phase2_param;
	
	uniform vec4 V_volume_type2_scatter_power;
	uniform vec4 V_volume_type2_sigma_extinction;
	
	uniform vec4 V_volume_type2_phase0_param;
	uniform vec4 V_volume_type2_phase1_param;
	uniform vec4 V_volume_type2_phase2_param;*/
	
	uniform float F_globallightscale;
	uniform float F_locallightscale;
	uniform float F_time;
	uniform float F_framedeltatime;
	uniform float F_exposure;			//DEF_AUTO_PARA(Exposure, EXPOSURE, float, (0.5))
	uniform float F_ibl_maxvalidlevel;

	uniform float F_csm_blendstrength;
	uniform float F_shadowmapsize; // used for kernel width adjustment
	uniform float F_shadowmaxdistance;		//DEF_AUTO_PARA(ShadowMaxDist	, SHADOWMAXDISTANCE			, float		, {5000.0})
	//I think F_shadowbias, F_shadowtexelbias, F_shadowmaxdistance is never set,
	// and F_shadowmapsize is never used...
	// F_shadowmaxdistance is set according to videoparameters
	uniform bool B_csmpcfenabled;
	uniform float F_texturefactorCSM0;
	uniform float F_texturefactorCSM1;
	uniform float F_texturefactorCSM2;
	uniform float F_texturefactorCSM3;
	uniform float F_texturefactorCSM4;

	uniform bool B_ssao_enabled;
	uniform bool B_lighting;
	
	uniform bool B_csmdebugcolor;
	
	uniform bool B_shadow;
	
	uniform float F_volume_off;
	uniform float F_volume_scale;

	uniform bool B_pom_enabled;
	uniform float F_pom_minlayers;
	uniform float F_pom_maxlayers;
	
	I_HATE_MACROS
)

#undef I_HATE_MACROS

#ifdef GFX_VULKAN
	layout(constant_id = 2) const bool B_deferred_draw = false;
	layout(constant_id = 3) const int I_instancetype = VERTEXTYPE_ENUMSIZE;
	
#ifdef GFX_EXTENDEDVDATA
	VK_BLOCK(WORLD,
		uniform mat4 M_worldviewprojection;
		uniform mat4 M_world;
		
		uniform mat4 M_shadowCSM0; // is also used in shadow generation pass
		uniform mat4 M_shadowCSM1; // is also used in shadow generation (for skinning)
		uniform mat4 M_shadowCSM2;
		uniform mat4 M_shadowCSM3;
		uniform mat4 M_shadowCSM4;
		
		uniform vec4 V_blendcolor;
		uniform float F_alphascale;
		uniform bool B_packedtangentframe;
		uniform bool B_vertexdata0;
		uniform bool B_vertexdata1;
		uniform bool B_vertexdata2;
		uniform bool B_useskinning;				//DEF_SWITCH(bUseSkinning			, USESKINNING			, b4,false, use skinning)
	)
#else
	VK_BLOCK(WORLD,
		uniform mat4 M_worldviewprojection;
		uniform mat4 M_world;

		uniform mat4 M_shadowCSM0; // is also used in shadow generation pass
		uniform mat4 M_shadowCSM1; // is also used in shadow generation (for skinning)
		uniform mat4 M_shadowCSM2;
		uniform mat4 M_shadowCSM3;
		uniform mat4 M_shadowCSM4;

		uniform vec4 V_blendcolor;
		uniform float F_alphascale;
		uniform bool B_packedtangentframe;
		uniform bool B_vertexdata0;
		uniform bool B_vertexdata1;
		uniform bool B_useskinning;				//DEF_SWITCH(bUseSkinning			, USESKINNING			, b4,false, use skinning)
	)
#endif

/*	layout(push_constant) uniform BUFFER_PC
	{
		mat4 worldviewprojection;
		mat4 world;
	}PC;
	#define M_worldviewprojection PC.worldviewprojection
	#define M_world PC.world*/
#else
	uniform mat4 M_worldviewprojection;
	uniform mat4 M_world;
	
	uniform mat4 M_shadowCSM0; // is also used in shadow generation pass
	uniform mat4 M_shadowCSM1; // is also used in shadow generation (for skinning)
	uniform mat4 M_shadowCSM2;
	uniform mat4 M_shadowCSM3;
	uniform mat4 M_shadowCSM4;
	
	// uniform mat4 M_worldview; // these two will be needed for proper view space lighting
	// uniform mat4 M_worldviewinversetranspose;
	uniform vec4 V_blendcolor;
	uniform float F_alphascale;
	uniform bool B_packedtangentframe;
	uniform bool B_vertexdata0;
	uniform bool B_vertexdata1;
#ifdef GFX_EXTENDEDVDATA
	uniform bool B_vertexdata2;
#endif
	uniform bool B_useskinning;				//DEF_SWITCH(bUseSkinning			, USESKINNING			, b4,false, use skinning)

	uniform bool B_deferred_draw;			// set whenever a deferred shader is called in a deferred way
	
	uniform int I_instancetype = VERTEXTYPE_ENUMSIZE;//TODO @Timon if we ever implement it in OGL it should be specialized
	
	D_shadow_QUAL bool B_shadow = D_shadow_VALUE;
	
	#if D_alpha_test == D_DYNAMIC
	uniform bool B_alpha_test = false;		//for alpha-testing
	#elif D_alpha_test == D_SPECIAL
	const bool B_alpha_test = D_alpha_test_VALUE;
	//#define B_alpha_test D_alpha_test_VALUE
#endif

#endif

layout(set = ENUM_BUFFER_DYNAMIC, binding = 0, std140) uniform BUFFER_DYNAMIC
{
uniform mat4 M_texturematrix0;
uniform mat4 M_texturematrix1;
uniform mat4 M_texturematrix2;
uniform mat4 M_texturematrix3;
uniform bool B_textureanimation;

#define B_vertexcolorsrgb true

//for luminance
uniform float F_eyeadaptionspeed;	// DEF_AUTO_PARA(EyeAdaptionSpeed, EYEADAPTIONSPEED, float, 0.9)


//for SSAO
uniform vec4 V_frustumsize;			//DEF_AUTO_PARA(FrustumSize		, FRUSTUMSIZE		, float4	, {1.0, 1.0, 0.0, 0.0})

//for tonemap
//DEF_AUTO_PARA(ScreenLuminance, LUMINANCE, float4, (0,0,0,0))
uniform bool B_srgbout;			//DEF_AUTO_PARA(SRGBOut, SRGBOUT, bool, false)
uniform vec4 V_textureviews;	//DEF_AUTO_PARA(TextureViews, TEXTUREVIEWS, float4, {1280.0, 720.0, 1280.0, 720.0})

//#ifdef PROJECT_XR
uniform float F_lutblend;		//DEF_AUTO_PARA(ColorLUTBlend, DIFFUSE_SCALE, float, (0.0))
//#endif

#if SHADERFLAGS & SHADERFLAG_FORWARD_ENVMAP_PROBES
uniform vec4 V_envmapprobe_shape[GFX_MAX_FORWARD_ENVMAP_PROBES];
uniform vec4 V_envmapprobe_color[GFX_MAX_FORWARD_ENVMAP_PROBES];
uniform mat4 M_envmapprobe_world[GFX_MAX_FORWARD_ENVMAP_PROBES];
uniform mat4 M_envmapprobe_world_rot[GFX_MAX_FORWARD_ENVMAP_PROBES];
uniform vec4 V_envmapprobe_volumeoffset[GFX_MAX_FORWARD_ENVMAP_PROBES];
uniform vec4 V_envmapprobe_fadein[GFX_MAX_FORWARD_ENVMAP_PROBES];
#else
uniform mat4 M_envmapprobe_world;
uniform mat4 M_envmapprobe_world_rot;
uniform vec4 V_envmapprobe_volumeoffset;
uniform vec4 V_envmapprobe_shape;
#endif

DPREDEF_BUFFER_DYNAMIC

#if defined(CHROMATIC_ABERRATION) && defined(GFX_CHROMA_SAMPLES)
	uniform vec4 V_color[GFX_CHROMA_SAMPLES];
#endif

#ifdef BONE_MATRICES
	//TODO @Timon/Florian this and actually most of these should be refactored to .ogl if/when possible
	//although given how many and common they are, it seems necessary to also extend .ogl handling to allow including files or something
	// (to group common param sets into separate files)
	uniform mat4 M_boneworld[50];		//float4x4 mBone0[50] : BONEWORLD0;
	// TODO: P1 specific stuff
#endif
	
#ifdef VOLUME_POINT
	#define VOLUME_POINT_NUM 32	//ALSO defined in renderframe.cpp
// 	uniform vec4 V_point_pos[VOLUME_POINT_NUM];
	uniform mat4 M_offset[VOLUME_POINT_NUM];
	uniform vec4 V_scale[VOLUME_POINT_NUM];
	uniform int I_index[VOLUME_POINT_NUM];
	#ifndef VOLUME_POINT_FULL
	uniform int I_point_num;
	#endif
#endif
	
};


#ifdef GFX_VULKAN
layout(set = ENUM_BUFFER_MATERIAL, binding = 0, std140) uniform BUFFER_MATERIAL
#else
/*layout(binding = ENUM_BUFFER_EXTRA)*/ uniform BUF_material
#endif
{
#ifdef OCULUS_SHADER
	#define MAX_LAYER_COUNT 8

	vec4 baseColor;
	int baseMaskType;
	vec4 baseMaskParameters;
	vec4 baseMaskAxis;
	vec4 alphaMaskScaleOffset;
	vec4 normalMapScaleOffset;
	vec4 parallaxMapScaleOffset;
	vec4 roughnessMapScaleOffset;

	mat4 projectorInv;

//	bool useAlpha;
//	bool useNormalMap;
//	bool useRoughnessMap;
	bool useProjector;
	float elapsedSeconds;

	int layerCount;

	int layerSamplerModes[MAX_LAYER_COUNT];
	int layerBlendModes[MAX_LAYER_COUNT];
	int layerMaskTypes[MAX_LAYER_COUNT];
	vec4 layerColors[MAX_LAYER_COUNT];
	vec4 layerSurfaceScaleOffsets[MAX_LAYER_COUNT];
	vec4 layerSampleParameters[MAX_LAYER_COUNT];
	vec4 layerMaskParameters[MAX_LAYER_COUNT];
	vec4 layerMaskAxes[MAX_LAYER_COUNT];
	
/*	sampler2D alphaMask;
	sampler2D normalMap;
	sampler2D parallaxMap;
	sampler2D roughnessMap;
	sampler2D layerSurfaces[MAX_LAYER_COUNT];*/
#endif
	DPREDEF_BUFFER_MATERIAL
};

float epsilon = 0.000001f;

//TODO @Timon especially with AA we get NaNs at edges of transparent draws (mostly simple_hdr_out, lightcone) this seems to be mostly due to TO_linearRGB calls
//#define pow(x,y)	pow(max((x),0) + HALF3_SMALL_NUMBER, (y))


#define BGDIST (2000000.0f)
#define BGZ (1.0f / BGDIST)

#define PI (3.141592654f)
#define EUL (2.718281828459f)

#define mul(a,b) ((b) * (a))

vec2 SIGNED(vec2 v)
{
	return (v * 2.0) - 1.0;
}
vec3 SIGNED(vec3 v)
{
	return (v * 2.0) - 1.0;
}
/*
vec4 UNSIGNED(vec4 v)
{
	return (v * 0.5) + 0.5;
*/
vec4 SIGNED(vec4 v)
{
	return (v * 2.0) - 1.0;
}
#define SIGNED_pp SIGNED

float clip2uv(float v)
{
	v += 1;
	v /= 2;
	return v;
}
float uv2clip(float v)
{
	v *= 2;
	v -= 1;
	return v;
}
vec2 clip2uv(vec2 v)
{
	v += vec2(1);
	v /= vec2(2);
	return v;
}
vec2 uv2clip(vec2 v)
{
	v *= vec2(2);
	v -= vec2(1);
	return v;
}
vec3 clip2uv(vec3 v)
{
	v += vec3(1);
	v /= vec3(2);
	return v;
}
vec3 uv2clip(vec3 v)
{
	v *= vec3(2);
	v -= vec3(1);
	return v;
}

vec3 clipZ2uv(vec3 v)
{
	v.xy += vec2(1);
	v.xy /= vec2(2);
	return v;
}
vec3 uv2clipZ(vec3 v)
{
	v.xy *= vec2(2);
	v.xy -= vec2(1);
	return v;
}

vec3 clip2view(vec3 cs)
{
	vec4 p = M_invprojection * vec4(cs, 1);
	return p.xyz / p.w;
}

#ifdef GFX_OGL
	#define DEFAULT_TES_WINDING ccw
#else
	#define DEFAULT_TES_WINDING cw
#endif

/*
Unfortunately there are issues with const:
- glsl < 4.2 has different meaning for const
- amd-vulkan crashes weirdly,	e.g.
	scaleMat(const) is fine
	make_ColorMatrix(any param const) crashes
*/
#define CONST /*const*/
#define _IF if

#define tex2D texture
#define tex1D texture
#define tex2Dproj textureProj
#define tex2Dlod textureLod
#define tex3D texture
#define float2 vec2
#define float3 vec3
#define float4 vec4

#define half float
#define half2 vec2
#define half3 vec3
#define half4 vec4

#define float3x3 mat3
#define float4x4 mat4

float saturate(float v) {
	return clamp(v, 0, 1);
}
float2 saturate(float2 v) {
	return clamp(v, 0, 1);
}
float3 saturate(float3 v) {
	return clamp(v, 0, 1);
}
float4 saturate(float4 v) {
	return clamp(v, 0, 1);
}

float saturate0(float v)	{ return max(v, 0); }
vec2 saturate0(vec2 v)		{ return max(v, 0); }
vec3 saturate0(vec3 v)		{ return max(v, 0); }
vec4 saturate0(vec4 v)		{ return max(v, 0); }

float maxvec(vec2 v)
{
	return max(v.r, v.g);
}
float maxvec(vec3 v)
{
	return max(maxvec(v.rg), v.b);
}
float maxvec(vec4 v)
{
	return max(maxvec(v.rgb), v.a);
}

#define lerp(x,y,s)	mix(x,y,s)
#define frac fract

#define pow2(val) ((val) * (val))
#define dotself(val) dot((val), (val))

#define HALF_SMALL_NUMBER (0.00001)
#define HALF3_SMALL_NUMBER half3(HALF_SMALL_NUMBER, HALF_SMALL_NUMBER, HALF_SMALL_NUMBER)

#define FLOAT_SMALL_NUMBER (0.000000001)

// simple sRGB color conversion with 2.2f NOTE: preserve alpha
half3 TO_sRGB(CONST half3 inColor)
{
	return half3(pow(inColor.rgb + HALF3_SMALL_NUMBER, half3(1.0/2.2)));
}

half4 TO_sRGB(CONST half4 inColor)
{
	return half4(pow(inColor.rgb + HALF3_SMALL_NUMBER, half3(1.0/2.2)), inColor.a);
}

half TO_linearRGB(CONST half inColor)
{
	return pow(inColor + HALF_SMALL_NUMBER, 2.2);
}

half3 TO_linearRGB(CONST half3 inColor)
{
	return half3(pow(inColor.rgb + HALF3_SMALL_NUMBER, vec3(2.2)));
}

half4 TO_linearRGB(CONST half4 inColor)
{
	return half4(pow(inColor.rgb + HALF3_SMALL_NUMBER, vec3(2.2)), inColor.a);
}

half3 D3DCOLOR_X_TO_linearRGB_HDR(CONST half4 inColor)
{
	//return half3(pow(inColor.rgb + HALF3_SMALL_NUMBER, 2.2) * inColor.a * LIGHTINTENSITY_SCALE);
	return half3(pow(inColor.rgb + HALF3_SMALL_NUMBER, half3(2.2)) );
}

float fresnel(CONST float3 V, CONST float3 N, CONST half Power)
{
	return (pow(1-abs(dot(V, N)), Power));    // note: abs() makes 2-sided materials work
}

//--- Color Correction matrix math ---

float4x4 scaleMat(CONST float s)
{
	return float4x4(
		s, 0, 0, 0,
		0, s, 0, 0,
		0, 0, s, 0,
		0, 0, 0, 1);
}
float4x4 scaleMat(CONST vec3 s)
{
	return float4x4(
		s.x, 0, 0, 0,
		0, s.y, 0, 0,
		0, 0, s.z, 0,
		0, 0, 0, 1);
}

float4x4 translateMat(CONST float3 t)
{
	return float4x4(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		t, 1);
}

float4x4 saturationMat(CONST float s)
{ 
	CONST float rwgt = 0.3086;
	CONST float gwgt = 0.6094;
	CONST float bwgt = 0.0820;

	return float4x4(
		(1.0-s)*rwgt + s,	(1.0-s)*rwgt,  		(1.0-s)*rwgt,		0,
		(1.0-s)*gwgt, 		(1.0-s)*gwgt + s, 	(1.0-s)*gwgt,		0,
		(1.0-s)*bwgt,    	(1.0-s)*bwgt, 		(1.0-s)*bwgt + s,	0,
		0.0, 0.0, 0.0, 1.0);
}

float4x4 rotateMat(float3 d, CONST float ang)
{
	float s = sin(ang);
	float c = cos(ang);
	d = normalize(d);
	return float4x4(
		d.x*d.x*(1 - c) + c,		d.x*d.y*(1 - c) - d.z*s,	d.x*d.z*(1 - c) + d.y*s,	0,
		d.x*d.y*(1 - c) + d.z*s,	d.y*d.y*(1 - c) + c,		d.y*d.z*(1 - c) - d.x*s,	0, 
		d.x*d.z*(1 - c) - d.y*s,	d.y*d.z*(1 - c) + d.x*s,	d.z*d.z*(1 - c) + c,		0, 
		0, 0, 0, 1 );
}

mat4x3 make_ColorMatrix(CONST float inBrightness,CONST float inContrast,CONST float inSaturation,CONST float inHue)
{
	// construct color matrix

	// brightness - scale around (0.0, 0.0, 0.0)
	float4x4 brightnessMatrix = scaleMat(inBrightness);

	// contrast - scale around (0.5, 0.5, 0.5)
	float4x4 contrastMatrix = translateMat(vec3(-0.5));
	contrastMatrix = mul(contrastMatrix, scaleMat(inContrast) );
	contrastMatrix = mul(contrastMatrix, translateMat(vec3(0.5)) );

	// saturation
	float4x4 saturationMatrix = saturationMat(inSaturation);

	// hue - rotate around (1, 1, 1)
	float4x4 hueMatrix = rotateMat(float3(1, 1, 1), radians(inHue));

	// composite together matrices
	float4x4 m;
	m = brightnessMatrix;
	m = mul(m, contrastMatrix);
	m = mul(m, saturationMatrix);
	m = mul(m, hueMatrix);

	return mat4x3(m);
}

vec3 GetRGBBox(vec3 ray)
{
	ray = normalize(ray);
	vec3 mag = abs(ray);
	if (mag.r > mag.g && mag.r > mag.b) {
		if (ray.r >= 0)
			return vec3(1, 0, 0);
		else
			return vec3(0, 1, 1);
	}
	if (mag.g > mag.r && mag.g > mag.b) {
		if (ray.g >= 0)
			return vec3(0, 1, 0);
		else
			return vec3(1, 0, 1);
	}
	if (mag.b > mag.r && mag.b > mag.g) {
		if (ray.b >= 0)
			return vec3(0, 0, 1);
		else
			return vec3(1, 1, 0);
	}
	return vec3(0);
}


float random( float2 p )
{
  // We need irrationals for pseudo randomness.
  // Most (all?) known transcendental numbers will (generally) work.
  CONST float2 r = float2(
    23.1406926327792690,  // e^pi (Gelfond's constant)
     2.6651441426902251); // 2^sqrt(2) (Gelfond?Schneider constant)
  return frac( cos( /*f*/mod( 123456789., 1e-7 + 256. * dot(p,r) ) ) );  //was 256.
}

float square(in float val)
{
	return val*val;
}

bool IsOutsideUV(float uv)
{
	return uv < 0 || uv > 1;
}

bool IsInsideUV(vec2 uv)
{
	return all(greaterThanEqual(uv, vec2(0))) && all(lessThanEqual(uv, vec2(1)));
}
bool IsOutsideUV(vec2 uv)
{
	return any(lessThan(uv, vec2(0))) || any(greaterThan(uv, vec2(1)));
}

vec4 Project(in vec4 val)
{
	val = M_projection * val;
	return val / val.w;
}
vec4 UnProject(in vec4 val)
{
	val = M_invprojection * val;
	return val / val.w;
}

vec3 Project(in vec3 val)
{
	vec4 tmp = M_projection * vec4(val, 1);
	return tmp.xyz / tmp.w;
}
vec3 UnProject(in vec3 val)
{
	vec4 tmp = M_invprojection * vec4(val, 1);
	return tmp.xyz / tmp.w;
}

vec3 view2world(in vec3 val)
{
	return (M_viewinverse * vec4(val, 1)).xyz;
// 	vec4 tmp = M_viewinverse * vec4(val, 1);
//	return tmp.xyz / tmp.w;
}
vec3 view2world_rot(in vec3 val)
{
	return mat3(M_viewinverse) * val;
}

vec3 world2view(in vec3 val)
{
	return (M_view * vec4(val, 1)).xyz;
}
vec3 world2view_rot(in vec3 val)
{
	return mat3(M_view) * val;
}


vec3 pix2volume(ivec3 pix)
{
	return pix / (V_volume_size.xyz - 1);
}
ivec3 volume2pix(vec3 uv)
{
	return ivec3(uv * (V_volume_size.xyz - 1));
}

/*
vec3 proj2volume(vec3 cs)
{
	cs.z -= F_volume_off;
	cs.z /= F_volume_scale;
// 	cs.z *= cs.z;
// 	cs.z = sqrt(cs.z);
	vec3 uv = clipZ2uv(cs);
// 	uv = saturate(uv);
	return uv;
}
vec3 volume2proj(vec3 uv)
{
	vec3 cs = uv2clipZ(uv);
// 	cs.z = 1 - cs.z;//flip for intuition
// 	cs.z *= 0.5;
// 	cs.z *= cs.z;
// 	cs.z = sqrt(cs.z);
// 	cs.z = pow(cs.z, 2);
	cs.z *= F_volume_scale;
	cs.z += F_volume_off;
	return cs;
}*/

const float volume_near_scale = 1.0f;
const float volume_dist_scale = 1000.0f;

#define VOLUME_DIST_GODRAYS_LAYERS 1

const float volume_fom_min = 6000.0f;
// const float volume_fom_min = 0.0f;
const float volume_fom_max = 60000.0f;

#ifdef VOLUME_SHAD

#define VOLUME_SHAD_MARGIN /*def or ndef*/
#ifdef VOLUME_SHAD_MARGIN
	const float shvol_margin = 0.01;
#endif

const int shvol_offsets_num = 5;
const float shvol_offsets[shvol_offsets_num] = { 0, 0.63, 0.1, 0.32, 0.85 };

/*vec3 volume2shvol(vec3 uv)
{
	uv.xy += shvol_margin;
	uv.xy /= 1 + 2 * shvol_margin;
	return uv;
}
vec3 shvol2volume(vec3 uv)
{
	uv.xy *= 1 + 2 * shvol_margin;
	uv.xy -= shvol_margin;
	return uv;
}*/

float shvol_zoffset(ivec3 pix, int idx)
{
	if (idx >= 0 /*&& uv.z >= 1.0f / V_volume_size.z/**/) {
// 		idx /= 7;
// 		idx += pix.x + pix.y;
// 		idx += pix.x + int(V_volume_size.x) * pix.y;
// 		idx += pix.y + int(V_volume_size.y) * pix.x;
// 		idx = int(random(vec2(idx)) * shvol_offsets_num);
// 		idx = int(random(vec2(idx) + vec2(pix.xy)) * shvol_offsets_num);
// 		idx = int(random(vec2(idx) / 7 + vec2(pix.xy)) * (shvol_offsets_num - 1));
		idx %= shvol_offsets_num;
		return shvol_offsets[idx] / V_volume_size.z;
	}
	return 0;
}

vec3 volume2shvol(vec3 uv, ivec3 pix, int idx)
{
#ifdef VOLUME_SHAD_MARGIN
	uv.xy += shvol_margin;
	uv.xy /= 1 + 2 * shvol_margin;
#endif
	uv.z += shvol_zoffset(pix, idx);
	return uv;
}
vec3 volume2shvol(vec3 uv, ivec3 pix)
{
	return volume2shvol(uv, pix, U_offset);
}
vec3 volume2shvolPrev(vec3 uv, ivec3 pix)
{
	return volume2shvol(uv, pix, U_offset - 1);
}

vec3 shvol2volume(vec3 uv, ivec3 pix)
{
// 	return uv;
#ifdef VOLUME_SHAD_MARGIN
	uv.xy *= 1 + 2 * shvol_margin;
	uv.xy -= shvol_margin;
#endif
	uv.z -= shvol_zoffset(pix, U_offset);
	return uv;
}
#endif

float view2volume(float z)
{
	z = 0.1f / z; //TODO @Timon camera near-dist
	z -= F_volume_off;
	z /= F_volume_scale;
	z = sqrt(z);
	return z;
}
float volume2view(float z)
{
	z *= z;
	z *= F_volume_scale;
	z += F_volume_off;
	z = 0.1f / z; //TODO @Timon camera near-dist
	return z;
}


vec3 view2volume(vec3 vp)
{
	vec3 cs = Project(vp);
	cs.z -= F_volume_off;
	cs.z /= F_volume_scale;
// 	cs.z *= cs.z;
	cs.z = sqrt((cs.z));
// 	cs.z = sqrt(abs(cs.z));
// 	cs.z = pow(cs.z, 1.0f/2.0f);
// 	cs.z = pow(cs.z, 1.0f/4.0f);
	vec3 uv = clipZ2uv(cs);
// 	uv = saturate(uv);
	return uv;
}
vec3 volume2view(vec3 uv)
{
	vec3 cs = uv2clipZ(uv);
// 	cs.z = 1 - cs.z;//flip for intuition
// 	cs.z *= 0.5;
	cs.z *= cs.z;
// 	cs.z = sqrt(cs.z);
// 	cs.z = pow(cs.z, 2.0f);
// 	cs.z = pow(cs.z, 4.0f);
	cs.z *= F_volume_scale;
	cs.z += F_volume_off;
	vec3 view = UnProject(cs);
	return view;
}

vec3 view2volume_linear(vec3 vp)
{
	vec3 cs = Project(vp);
	cs.z -= F_volume_off;
	cs.z /= F_volume_scale;
// 	cs.z *= cs.z;
	cs.z = sqrt((cs.z));
// 	cs.z = sqrt(abs(cs.z));
// 	cs.z = pow(cs.z, 1.0f/2.0f);
// 	cs.z = pow(cs.z, 1.0f/4.0f);
	
	cs.xy -= cs.xy * vec2(1.0f / V_volume_size.xy);//compensate for difference to between texel addressing and linear texture filtering
	cs.z -= uv2clip(cs.z) * 0.5f / V_volume_size.z;
	
	vec3 uv = clipZ2uv(cs);
// 	uv = saturate(uv);
	return uv;
}

vec3 volume_cellsize(vec3 uv)//TODO @Timon optimize, if needed with a precomputed matrix or something
{
	vec3 v0 = volume2view(uv);
	uv.xy += 1.0f / V_volume_size.xy;
	uv.z -= 1.0f / V_volume_size.z;
	vec3 v1 = volume2view(uv);
	return v1 - v0;
}

float cellsize_fadefactor(vec3 cellsize, float size)
{
// 	float fade = saturate(size * 0.5f - length(cellsize));
	float fade = saturate(size * 0.5f - cellsize.z);
	return fade;
}

float volume_getfadefactor(float viewz, float size)
{
/*	z = 0.1f / z; //TODO @Timon camera near-dist
	z -= F_volume_off;
	z /= F_volume_scale;
	z = sqrt(z);
	
	z -= 1.0f / V_volume_size.z;
	
	z *= z;
	z *= F_volume_scale;
	z += F_volume_off;
	z = 0.1f / z; //TODO @Timon camera near-dist
	/**/
// 	return 0.0;
	float n = 800 * size / 200;
	float f = 1400 * size / 200;
	n = min(n, V_volume_range[1] - min(size, V_volume_range[1] / 4));
	f = min(f, V_volume_range[1]);
	return smoothstep(n, f, viewz);
	
// 	float step = V_volume_range[1] - V_volume_range[0];
// 	step /= V_volume_size.z;
// 	float far = size;
// 	return smoothstep(, viewz);
/*	float volz = view2volume(viewz);
	volz -= 1.0f / V_volume_size.z;
	float nviewz = volume2view(volz);
	
	float dist = 0.1 / (0.1 / viewz + F_volume_scale / pow2(V_volume_size.z));	return saturate(size * 0.5 - abs(dist));
	
	return saturate(size * 0.5 - abs(nviewz - viewz));/**/
// 	return fade;
}

//-------------------------------------------------------------------------------
// Lighting/Shadow defines ( used in vertex + pixel shaders )
//-------------------------------------------------------------------------------

#define USE_TEXTURE_LIGHTING /**/
#define DEF_LIGHT_AMBIENT(_NR) /**/
#define DEF_LIGHT_DIR(_NR) /**/

#define B_material_override false
#define B_globallight_tonemap true
#define V_matparams vec4(0.5f)
#define V_deferred_lightparams vec4(1)
#define F_arealightcutoff 0.001f

#ifdef PROJECT_XR
	#define XR_TO_linearRGB(val)	TO_linearRGB(val)
#else
	#define XR_TO_linearRGB(val)	(val)
#endif

#include <jon_mod_defines.h>
#include <jon_mod_util_functions.h>