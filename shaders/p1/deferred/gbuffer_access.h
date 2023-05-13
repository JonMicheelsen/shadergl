#include <jon_mod_buffer_encoding_functions.h>
// #define USE24BITNORMALCOMPRESSION

//Lambert Azimuthal Equal-Area Projection
vec2 EncodeNormalLA(vec3 n)
{
	float p = sqrt(-n.z * 8 + 8);
	return n.xy / p + 0.5;
}
vec3 DecodeNormalLA(vec2 n)
{
	vec2 fenc = n * 4 - 2;
	float f = dot(fenc,fenc);
	float g = sqrt(1 - f/4);
	return vec3(fenc * g, f/2 - 1);
}

//Stereographic Projection
const float Normal_Stereographic_Scale = 0.3;	//TODO @Timon optimize for quality, keep in mind it affects normal blending for complex_projection*
//WARNING: if these are changed ffx_cacao_bindings.hlsl needs to be adjusted as well
float2 EncodeNormalSG(float3 n)
{
	float2 ret = n.xy / (1 - n.z);
	ret /= Normal_Stereographic_Scale;
//	return ret / 2 + 0.5;
	return ret;
}
float3 DecodeNormalSG(float2 n)
{
//	float3 ret = float3(n * 2 * Normal_Stereographic_Scale - Normal_Stereographic_Scale, 1);
	float3 ret = float3(n * Normal_Stereographic_Scale, 1);
	float g = 2.0 / dot(ret, ret);
	ret.xy *= g;
	ret.z = g - 1;
	ret.z = -ret.z;
	return ret;
}

#if 0

vec2 pack16(float value){
    float f = clamp(value, 0.0, 1.0)*255.0;
    float digitLow = fract(f);
    float digitHigh = floor(f)/255.0;
    return vec2(digitHigh, digitLow);
}       
    
float unpack16(vec2 value){
    return value.x+value.y/255.0;
}

vec4 packNormal32(in vec3 n) {
    vec2 spheremapped = encode(n);
	//return vec4(n, 1);
	return vec4(spheremapped, 0, 0);
    // return vec4(pack16(spheremapped.x), pack16(spheremapped.y));
}
vec3 unpackNormal32(in vec4 data) {
	//return data.xyz;
	return normalize(decode(data.x, data.y));
    // return normalize(decode(unpack16(data.xy), unpack16(data.zw)));
}

// Crytek BFN
//vec3 packBestFitNormal(in vec3 n) {
//    vec3 np = n.xyz;
//    // vec3 np = n.xyz*2-1;
//    np = normalize(np);
//    vec3 nu = abs(np);
//    float maxNU = max(nu.z, max(nu.x, nu.y));
//    vec2 uv = nu.z < maxNU ? (nu.y < maxNU ? nu.yz : nu.xz) : nu.xy; 
//    uv = uv.x < uv.y ? uv.yx : uv.xy;
//    uv.y /= uv.x;
//    np /= maxNU;
//    // float scale = pow(texture(T_normalfittex, uv).r, 1.0f/2);
//     //uv.y = 1- uv.y;
//    // float scale = texture(T_normalfittex, uv.xy + vec2(1.0f/256.0f)).r;
//    float scale = textureLod(T_normalfittex, uv.xy, 0).r;
//    np *= scale;
//    // return np;
//    np = np * 0.5 + 0.5;
//
//    // np = TO_linearRGB(vec4(np, 0)).xyz;
//
//    return np;
//    // return np * 0.5 + 0.5; // store unsigned
//}
//vec3 unpackBestFitNormal(in vec3 n) {
//	return normalize(n * 2 - 1);
//}
// octahedral normal encoding (http://jcgt.org/published/0003/02/01/paper.pdf)
float signNotZero(in float k) {
	return k >= 0.0 ? 1.0 : -1.0;
}
vec2 signNotZero(in vec2 v) {
	return vec2(signNotZero(v.x), signNotZero(v.y));
}
vec2 octEncode(in vec3 v) {
	float l1norm = abs(v.x) + abs(v.y) + abs(v.z);
	vec2 result = v.xy * (1.0 / l1norm);
	if (v.z < 0.0) {
		result = (1.0 - abs(result.yx)) * signNotZero(result.xy);
	}
	return result;
}

vec3 twoNorm12sEncodedAs3Unorm8sInVec3Format(vec2 s) {
	vec3 u;
	u.x = s.x * (1.0 / 16.0);
	float t = floor(s.y*(1.0 / 256));
	u.y = (frac(u.x) * 256) + t;
	u.z = s.y - (t * 256);
	// Instead of a floor, you could just add vec3(-0.5) to u, 
	// and the hardware will take care of the flooring for you on save to an RGB8 texture
	return floor(u) * (1.0 / 255.0);
}

float packSnorm12Float(float f) {
	return round(clamp(f + 1.0, 0.0, 2.0) * float(2047));
}
vec3 vec2To2Snorm12sEncodedAs3Unorm8sInVec3Format(vec2 v) {
	vec2 s = vec2(packSnorm12Float(v.x), packSnorm12Float(v.y));
	return twoNorm12sEncodedAs3Unorm8sInVec3Format(s);
}
vec3 encodeOct(in vec3 v) {
#ifndef USE24BITNORMALCOMPRESSION
	return v;
#endif
	return vec2To2Snorm12sEncodedAs3Unorm8sInVec3Format(octEncode(v));
}

// octahedral normal decoding
vec3 finalDecode(float x, float y) {
	vec3 v = vec3(x, y, 1.0 - abs(x) - abs(y));
	if (v.z < 0) {
		v.xy = (1.0 - abs(v.yx)) * signNotZero(v.xy);
	}
	return normalize(v);
}
vec2 twoNorm12sEncodedAsUVec3InVec3FormatToPackedVec2(vec3 v) {
	vec2 s;
	// Roll the (*255s) in during the quasi bit shifting. This causes two of the three multiplications to happen at compile time
	float temp = v.y * (255.0 / 16.0);
	s.x = v.x * (255.0*16.0) + floor(temp);
	s.y = fract(temp) * (16 * 256) + (v.z * 255.0);
	return s;
}

float unpackSnorm12(float f) {
	return clamp((float(f) / float(2047)) - 1.0, -1.0, 1.0);
}
float unpackSnorm12(uint u) {
	return unpackSnorm12(float(u));
}
vec2 twoSnorm12sEncodedAsUVec3InVec3FormatToVec2(vec3 v) {
	vec2 s = twoNorm12sEncodedAsUVec3InVec3FormatToPackedVec2(v);
	return vec2(unpackSnorm12(s.x), unpackSnorm12(s.y));
}
vec3 decodeOct(in vec3 p) {
#ifndef USE24BITNORMALCOMPRESSION
	p = normalize(p);	// the normals often aren't normal enough
	return p;
#endif
	vec2 v = twoSnorm12sEncodedAsUVec3InVec3FormatToVec2(p);
	return finalDecode(v.x, v.y);
}

// Most precise compression, only used for debug
vec2 octPEncode(in vec3 v) {
    float l1norm = abs(v.x) + abs(v.y) + abs(v.z);
    vec2 result = v.xy * (1.0/l1norm);
    if (v.z < 0.0) {
        result = (1.0 - abs(result.yx)) * signNotZero(result.xy);
    }
    return result;
}
vec2 encodeIntoSnorm12sStoredAsVec2(vec3 v) {
    vec3 normv = normalize(v);
    vec2 s = octPEncode(normv);
    s = floor(clamp(s, -1.0, 1.0) * 2047 ) * ( 1.0 / 2047 );

    // Prime the loop
    vec2 bestRepresentation = s;
    float highestCosine = dot(finalDecode(s.x, s.y), normv);
    for (int i = 0; i < 2; ++i) {
            for (int j = 0; j < 2; ++j) {
                // This branch will be evaluated at compile time
                if ( (i != 0) || (j != 0) ) {
                    vec2 candidate = vec2(i,j) * (1.0 / 2047 ) + s;
                    vec3 roundTrip = finalDecode(candidate.x, candidate.y);

                    float cosine = dot(roundTrip, normv);
                    if (cosine > highestCosine) {
                        bestRepresentation = candidate;
                        highestCosine      = cosine;
                    }
                }
            }
    }
    return bestRepresentation;
}
vec3 encodeOct2(in vec3 v) {
    return vec2To2Snorm12sEncodedAs3Unorm8sInVec3Format(encodeIntoSnorm12sStoredAsVec2(v));
}

#endif

//WARNING: if these are changed ffx_cacao_bindings.hlsl needs to be adjusted as well
void UniWriteNormal(out vec4 col, vec3 normal)
{
	normal = mat3(M_view) * normal;
	col.xyz = normal;
//	col.xy = EncodeNormalLA(normal);
	col.xy = EncodeNormalSG(normal);
// 	col.z = 0;
}
void UniReadNormal(vec4 col, out vec3 normal)
{
	normal = col.xyz;
// 	normal = NormalReZ(normal);
//	normal = DecodeNormalLA(col.xy);
	normal = DecodeNormalSG(col.xy);
//	normal = mat3(M_view) * col.xyz;
}

void UniReadNormalRaw(vec4 col, out vec3 normal)
{
	normal = col.xyz;
// 	normal = NormalReZ(normal);
//	normal = DecodeNormalLA(col.xy);
	normal = DecodeNormalSG(col.xy);
	normal = mat3(M_viewinverse) * normal;
}

/************************************************************************
    Position from zbuffer
************************************************************************/

void RetrieveZBufferViewPos(out vec3 view_pos, in vec2 uv)
{
    // todo: somehow make sure that this is nooped when z writes are enabled
    if(!B_deferred_draw)
	{
#ifdef OVERRIDE_DEPTH
        vec4 p = M_invprojection * vec4(uv*2-1, RTResolve(OVERRIDE_DEPTH, uv).r, 1);
#else
        vec4 p = M_invprojection * vec4(uv*2-1, RTResolve(T_zdepth, uv).r, 1);
#endif
        view_pos = p.xyz / p.w;
    }
}

void RetrieveZBufferViewPos(out vec3 view_pos)
{
//	RetrieveZBufferViewPos(view_pos, gl_FragCoord.xy / V_viewportpixelsize.xy);
	//TODO @Timon the above doesn't work when rendering with a smaller viewport (most RenderTargets),
	//iirc the above is only used by ssao so maybe refactor to use a generic version with an offset? or something
	if(!B_deferred_draw) {
#ifdef OVERRIDE_DEPTH
		vec4 p = M_invprojection * vec4(gl_FragCoord.xy / V_viewportpixelsize.xy*2 - 1, RTResolve(OVERRIDE_DEPTH).r, 1);
#else
		vec4 p = M_invprojection * vec4(gl_FragCoord.xy / V_viewportpixelsize.xy*2 - 1, RTResolve(T_zdepth).r, 1);
#endif
		view_pos = p.xyz / p.w;
	}
}

/************************************************************************
	GBUFFER access
************************************************************************/

// full gbuffer read, mainly for ssr
#define RETRIEVE_GBUFFER(NORMAL, BASECOLOR, METAL, SMOOTH) \
{ \
	RETRIEVE_GBUFFER_NORMAL0(NORMAL); \
	RETRIEVE_GBUFFER_BASECOLOR(BASECOLOR); \
	RETRIEVE_GBUFFER_METAL_SMOOTH(METAL, SMOOTH); \
}

#define RETRIEVE_GBUFFER_NORMAL0(NORMAL0) \
{ \
	vec4 data0 = RTResolve(T_gbuffer3); \
	UniReadNormal(data0, NORMAL0);	\
}

#define RETRIEVE_GBUFFER_BASECOLOR(BASECOLOR) \
{ \
	vec4 data1 =  RTResolve(T_gbuffer2); \
	BASECOLOR.rgb = data1.rgb; \
}
#define RETRIEVE_GBUFFER_METAL_SMOOTH(METAL, SMOOTH) \
{ \
	vec4 data =  RTResolve(T_gbuffer4); \
	SMOOTH = data.r; \
	METAL = data.g; \
}

#define RETRIEVE_GBUFFER_UV_NORMAL0(UV, NORMAL0) \
{ \
	vec4 data = RTResolve(T_gbuffer3, UV); \
	UniReadNormal(data, NORMAL0);	\
}

#define RETRIEVE_GBUFFER_UV_SMOOTH(UV, SMOOTH) \
{ \
	vec4 data = RTResolve(T_gbuffer4, UV); \
	SMOOTH = data.r; \
}

#define RETRIEVE_GBUFFER_UV_NORMAL0_SMOOTH(UV, NORMAL0, SMOOTH) \
{ \
	vec2 _uv = (UV);			\
	RETRIEVE_GBUFFER_UV_NORMAL0(_uv, NORMAL0)	\
	RETRIEVE_GBUFFER_UV_SMOOTH(_uv, SMOOTH)	\
}


/************************************************************************
	legacy gbuffer access
************************************************************************/
// depending on final gbuffer layout, cherry picked access

void RetrieveGBufferNormal(out vec3 normal, in vec2 uv) {
	normal = vec3(0,0,1);
    if(!B_deferred_draw) {
		RETRIEVE_GBUFFER_UV_NORMAL0(uv, normal);
    }
}

// mainly for compability with code using old gbuffer layout
void RetrieveGBufferNormalViewZ(out vec3 normal, out float view_z, in vec2 uv) {
	normal = vec3(0,0,1);
	view_z = 0;
    // deferred draws are not allowed to read g/zbuffer
    if(!B_deferred_draw) {
        vec3 view_pos;
        RetrieveZBufferViewPos(view_pos, uv);
        view_z = view_pos.z;
		RETRIEVE_GBUFFER_UV_NORMAL0(uv, normal);
    }
}

// mainly for compability with code using old gbuffer layout
void RetrieveGBufferViewZ(out float view_z) {
    view_z = 0;
    // todo: check if this is problematic for transparent draws with z write
    // maybe use downsampled depth?
    if(!B_deferred_draw) {
        vec3 view_pos;
        RetrieveZBufferViewPos(view_pos);
        view_z = view_pos.z;
    }
}

/************************************************************************
	Renderpass input gbuffer access
************************************************************************/

#ifdef MAIN_MSAA
vec4 RI_SubpassLoad(in subpassInputMS inputattachment)
{
	#ifdef PER_SAMPLE
	return subpassLoad(inputattachment, gl_SampleID);
	#else
	return subpassLoad(inputattachment, 0);
	#endif
}
#else
vec4 RI_SubpassLoad(in subpassInput inputattachment)
{
	return subpassLoad(inputattachment);
}
#endif

#define RI_GBUFFER(NORMAL, BASECOLOR, METAL, SMOOTH) \
{ \
	RI_GBUFFER_NORMAL0(NORMAL); \
	RI_GBUFFER_BASECOLOR(BASECOLOR); \
	RI_GBUFFER_METAL_SMOOTH(METAL, SMOOTH);	\
}

#define RI_GBUFFER_RAW(NORMAL, BASECOLOR, METAL, SMOOTH) \
{ \
	RI_GBUFFER_NORMAL0_RAW(NORMAL); \
	RI_GBUFFER_BASECOLOR(BASECOLOR); \
	RI_GBUFFER_METAL_SMOOTH(METAL, SMOOTH);	\
}

#define RI_GBUFFER_NORMAL0(NORMAL0) \
{ \
	vec4 data0 = RI_SubpassLoad(Input_gbuffer3); \
	UniReadNormal(data0, NORMAL0);	\
}

#define RI_GBUFFER_NORMAL0_RAW(NORMAL0) \
{ \
	vec4 data0 = RI_SubpassLoad(Input_gbuffer3); \
	UniReadNormalRaw(data0, NORMAL0);	\
}

#define RI_GBUFFER_BASECOLOR(BASECOLOR) \
{ \
	vec4 data1 = RI_SubpassLoad(Input_gbuffer2); \
	BASECOLOR.rgb = data1.rgb; \
}

#define RI_GBUFFER_METAL_SMOOTH(METAL, SMOOTH) \
{ \
	vec2 data = RI_SubpassLoad(Input_gbuffer4).rg; \
	SMOOTH = data.r; \
	METAL = data.g; \
}

#define RI_GBUFFER_NORMAL_Z(DATA) RI_GBufferNormalViewZ(DATA.xyz, DATA.w);
void RI_GBufferNormalViewZ(out vec3 normal, out float view_z) {
	normal = vec3(0, 0, 1);
	view_z = 0;
	// deferred draws are not allowed to read g/zbuffer
	if (!B_deferred_draw) {
		vec3 view_pos;
		RetrieveZBufferViewPos(view_pos);
		view_z = view_pos.z;
		
		RI_GBUFFER_NORMAL0(normal);
	}
}

#define RI_GBUFFER_PBR(DATA) RI_GBufferPBR(DATA.x, DATA.y);
void RI_GBufferPBR(out float smoothness, out float metalness)
{
	RI_GBUFFER_METAL_SMOOTH(metalness, smoothness);
}

/************************************************************************
	OUTPUT thing
************************************************************************/
// let the engine choose between gbuffer output for full deferred lighting
// or simple mainlight lighting for non-deferred solids+transparents

#define STORE_GBUFFER(NORMAL, ALBEDO, METAL, SMOOTH, GLOW) \
{ \
	OUT_Color = vec4(GLOW, 1);				\
	OUT_Color1 = vec4(ALBEDO, 1);	\
	OUT_Color2 = vec4(0, 0, 0, 1);			\
	UniWriteNormal(OUT_Color2, NORMAL);		\
	OUT_Color3 = vec4(SMOOTH, METAL, 0, 1);			\
}

#define STORE_GBUFFERA(A, NORMAL, ALBEDO, METAL, SMOOTH, GLOW) \
{ \
	OUT_Color = vec4(GLOW, A);				\
	OUT_Color1 = vec4(ALBEDO, A);	\
	OUT_Color2 = vec4(0, 0, 0, A);			\
	UniWriteNormal(OUT_Color2, NORMAL);		\
	OUT_Color3 = vec4(SMOOTH, METAL, 0, A);	\
}

#define DEFERRED_OUTPUTA(A, N, ALBEDO, METAL, SMOOTH, GLOW) \
{ \
	STORE_GBUFFERA(A, N, ALBEDO, METAL, SMOOTH, GLOW); \
}

#define GENERAL_OUTPUTA(A, N, ALBEDO, METAL, SMOOTH, GLOW) \
{ \
 	MetalStrict(METAL);	\
	PackMetal(METAL);	\
	RoughnessRemapSmoothVersion(SMOOTH);	\
   if (B_deferred_draw) { \
		DEFERRED_OUTPUTA(A, N, ALBEDO, METAL, SMOOTH, GLOW);	\
	} \
	else { \
		OUT_Color.a = (A); \
		OUT_Color.rgb = (GLOW) + global_lights(N, GetFragView(), ALBEDO, METAL, smooth2rough(SMOOTH), false); \
	} \
}

#define GENERAL_OUTPUT(N, ALBEDO, METAL, SMOOTH, GLOW) GENERAL_OUTPUTA(ColorBaseDiffuse.a * F_alphascale, N, ALBEDO, METAL, SMOOTH, GLOW)


#define DEFERRED_OVERLAY_ALPHA8(A, N_pp, ALBEDO, METAL, SMOOTH, GLOW) \
{ \
	MetalStrict(METAL);	\
	PackMetal(METAL);	\
	RoughnessRemapSmoothVersion(SMOOTH);	\
	OUT_Color = vec4(GLOW, 0);					\
	OUT_Color1 = vec4(ALBEDO, A);		\
	OUT_Color2 = vec4(CalcViewNormalOffset(N_pp), 0, A);	\
	OUT_Color3 = vec4(SMOOTH, METAL, 0, A);	\
}

#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING

	#define GENERAL_OUTPUTA_SUBSURFACE(A, N, ALBEDO, METAL, SUBSURFACE, SMOOTH, GLOW) \
	{ \
		MetalStrict(METAL);	\
		PackMetalSubsurface(METAL, SUBSURFACE);	\
		RoughnessRemapSmoothVersion(SMOOTH);	\
		if (B_deferred_draw) { \
			DEFERRED_OUTPUTA(A, N, ALBEDO, METAL, SMOOTH, GLOW);	\
		} \
		else { \
			OUT_Color.a = (A); \
			OUT_Color.rgb = (GLOW) + global_lights(N, GetFragView(), ALBEDO, METAL, smooth2rough(SMOOTH), false); \
		} \
	}
	
	#define GENERAL_OUTPUT_SUBSURFACE(N, ALBEDO, METAL, SUBSURFACE, SMOOTH, GLOW) GENERAL_OUTPUTA_SUBSURFACE(ColorBaseDiffuse.a * F_alphascale, N, ALBEDO, METAL, SUBSURFACE, SMOOTH, GLOW)
	
#endif