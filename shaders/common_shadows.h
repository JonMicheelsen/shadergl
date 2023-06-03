
#define SHADOWMAP_SIZE 4096.0f
//#define SHADER_BIAS
float GetShadowSoft(sampler2D shadowmap, float4 coords)
{
	coords.xyz /= coords.w;
//	coords.y = 1.0 - coords.y;
	float2 coordfloor = floor(coords.xy * SHADOWMAP_SIZE) / SHADOWMAP_SIZE;
	float Shadow = 0.0f;
	int iterations =  7;
	float offset = 1.0f / 2048.0f;
	/*[unroll]*/ for (int i = -3; i <= 3; ++i)
	{
		/*[unroll]*/ for (int j = -3; j <= 3; ++j)
		{
			
			float2 coord = float2(i*offset,j*offset); 
			Shadow +=  tex2D(shadowmap, coordfloor.xy + coord).x < coords.z ? 0.0 : 1.0;
		}
	}
	Shadow /= float(iterations*iterations);
	return Shadow;
}

float GetShadowSimple(sampler2D shadowmap, float4 coords)
{
	CONST int OFFSET_COUNT = 4;
	CONST float RECIPROCAL_OFFSET_COUNT = 1.0 / OFFSET_COUNT;
#if 0//requires GL_ARB_shading_language_420pack
	float2 offsets[] = { float2(-0.5, -0.5), float2(0.5, -0.5), float2(-0.5, 0.5), float2(0.5, 0.5) };
#else
	float2 offsets[4];
	offsets[0] = float2(-0.5, -0.5);
	offsets[1] = float2(0.5, -0.5);
	offsets[2] = float2(-0.5, 0.5);
	offsets[3] = float2(0.5, 0.5);
#endif
	float4 results;
	
	float shadow = 1.0;
	
	coords.xyz /= coords.w;
//	coords.y = 1.0 - coords.y;

//	return tex2D(shadowmap, coords.xy).r < coords.z ? 0.0 : 1.0;
	
	float2 coordfloor = floor(coords.xy * SHADOWMAP_SIZE) / SHADOWMAP_SIZE;
	results.x = tex2D(shadowmap, coordfloor.xy).x < coords.z ? 0.0 : 1.0;
	results.y = tex2D(shadowmap, coordfloor.xy + float2(1.0, 0.0) / SHADOWMAP_SIZE).x < coords.z ? 0.0 : 1.0;
	results.z = tex2D(shadowmap, coordfloor.xy + float2(0.0, 1.0) / SHADOWMAP_SIZE).x < coords.z ? 0.0 : 1.0;
	results.w = tex2D(shadowmap, coordfloor.xy + float2(1.0, 1.0) / SHADOWMAP_SIZE).x < coords.z ? 0.0 : 1.0;

	float2 f = frac(coords.xy * SHADOWMAP_SIZE);
	float2 yinter = lerp(results.xz, results.yw, f.x);
	return lerp(yinter.x, yinter.y, f.y);
}


// no PCF, could be used for furthest cascades
float GetCSMSampleFast(sampler2DShadow shadowmap, vec3 coords)
{
	// float2 coordfloor = floor(coords.xy * F_shadowmapsize) / F_shadowmapsize;
	// return texture(shadowmap, coordfloor.xyz +vec3(coordfloor.xy, coords.z + CSM_BIAS));
	return texture(shadowmap, coords);
}

float GetCSMSampleHard(sampler2DShadow shadowmap, vec3 coords)
{
	return 1.0f-step(texture(shadowmap, coords), 0.0f);
	// return 1.0f-step(textureProj(shadowmap, vec4(coords.xy, coords.z + CSM_BIAS, coords.z)), 0.0f);
}

float GetCSMSample5Taps(sampler2DShadow shadowmap, vec3 coords)
{
#ifndef D_CSM_SOFT_SHADOWS
	return GetCSMSampleFast(shadowmap, coords);
#else
	// CONST float div = 1000;
	CONST float div = F_shadowmapsize;
	CONST vec2 offsets[] = vec2[](
		float2(-2, -2) / div,
		float2(-2, -1) / div,
		float2(-2,  0) / div,
		float2(-2,  1) / div,
		float2(-2,  2) / div,
		float2(-1, -2) / div,
		float2(-1, -1) / div,
		float2(-1,  0) / div,
		float2(-1,  1) / div,
		float2(-1,  2) / div,
		float2(0,  -2) / div,
		float2(0,  -1) / div,
		float2(0,   0) / div,
		float2(0,   1) / div,
		float2(0,   2) / div,
		float2(1,  -2) / div,
		float2(1,  -1) / div,
		float2(1,   0) / div,
		float2(1,   1) / div,
		float2(1,   2) / div,
		float2(2,  -2) / div,
		float2(2,  -1) / div,
		float2(2,   0) / div,
		float2(2,   1) / div,
		float2(2,   2) / div
	);
	
	float Shadow = 0.0f;
	
	
	for(int i=0; i<25; ++i)
	{
		Shadow += texture(shadowmap, coords + vec3(offsets[i], 0));
	}
	Shadow /= 25.0f;
	return Shadow;
#endif
}

float GetCSMSample3Taps(sampler2DShadow shadowmap, vec3 coords, float texturefactor)
{
#ifndef D_CSM_SOFT_SHADOWS
	return GetCSMSampleFast(shadowmap, coords);
#else
	CONST float kwidth = (1 / (F_shadowmapsize * texturefactor)); // want to stride samples by 2 texels
	CONST vec2 offsets[] = vec2[](
		float2(-1, -1) * kwidth,
		float2(-1,  0) * kwidth,
		float2(-1,  1) * kwidth,
		float2(0,  -1) * kwidth,
		float2(0,   0) * kwidth,
		float2(0,   1) * kwidth,
		float2(1,  -1) * kwidth,
		float2(1,   0) * kwidth,
		float2(1,   1) * kwidth
	);
	
	CONST float weights[] = float[](
		0.077847,
		0.123317,
		0.077847,
		0.123317,
		0.195346,
		0.123317,
		0.077847,
		0.123317,
		0.077847
	);
	
	
	float Shadow = 0.0f;
	
	for(int i=0; i<9; ++i)
	{
		// Shadow += (1.0f/9.0f) * texture(shadowmap, coords.xyz+ vec3(offsets[i], CSM_BIAS));
		Shadow += texture(shadowmap, coords + vec3(offsets[i], 0));
		// Shadow += weights[i] * texture(shadowmap, coords + vec3(offsets[i], 0));
		// Shadow += weights[i] * textureProj(shadowmap, vec4(coords.xyz+ vec3(offsets[i], CSM_BIAS), 1.0f));
	}
	// return Shadow;
	return Shadow / 9.0f;
#endif
}

float GetCSMSample2Taps(sampler2DShadow shadowmap, vec3 coords, float texturefactor)
{
#ifndef D_CSM_SOFT_SHADOWS
	return GetCSMSampleFast(shadowmap, coords);
#else
	CONST float kwidth = (1.0f / (F_shadowmapsize * texturefactor)); // want to stride samples by 2 texels
	
	CONST vec2 offsets[] = vec2[](
		float2(-1, -1) * kwidth,
		float2(-1,  1) * kwidth,
		float2(0,   0) * kwidth,
		float2(1,  -1) * kwidth,
		float2(1,   1) * kwidth
	);
	
	float Shadow = 0.0f;
	for(int i=0; i<5; ++i)
	{
		Shadow += texture(shadowmap, coords.xyz+ vec3(offsets[i], 0));
	}
	Shadow /= 5.0f;
	return Shadow;
#endif
}


float satElemMin3(in vec3 vec)
{
	return saturate(min(vec.x, min(vec.y, vec.z)));
}

struct CSMScaleBias
{
	float epsilon;
	float min;
	float max;
};

CSMScaleBias ScaleBiasCSM[5] = {
	CSMScaleBias(0.005f, 0, 0.0001f),
	CSMScaleBias(0.005f, 0, 0.0002f),
	CSMScaleBias(0.5f, 0, 0.0002f),
	CSMScaleBias(0.0005f, 0, 0.00003f),
	CSMScaleBias(0.00005f, 0, 0.001f),
};

float GetScaleBias(in CSMScaleBias bias, in float ndotl)
{
	float tmpbias;

	tmpbias = bias.epsilon * sqrt(1 - ndotl * ndotl) / ndotl;
	tmpbias = clamp(tmpbias, bias.min, bias.max);

	return tmpbias;
}

// empirical per cascade bias
CONST vec3 biasCSM[5] = {
	vec3(0, 0, -0.003f),
	vec3(0, 0, -0.002f),
	vec3(0, 0, -0.001f),
	vec3(0, 0, -0.0009f),
	vec3(0, 0, -0.0009f), // this one a bit broken
};

// computes per cascade weights based on interpolated tex coords
vec4 getCSMWeights(in vec4 coords[5], in float ndotl)
{
	float ndotle = max(epsilon, ndotl);

	float w = 80/(10.0001-(F_csm_blendstrength-1)*10);
	w = 100000.0f; // no blending for now
	w = 10;
	vec4 ret = vec4(0);//  
	ret[0] = satElemMin3(w*min(coords[0].xyz, -coords[0].xyz + 1));
	ret[1] = satElemMin3(w*min(coords[1].xyz, -coords[1].xyz + 1));
	ret[2] = satElemMin3(w*min(coords[2].xyz, -coords[2].xyz + 1));
	ret[3] = satElemMin3(w*min(coords[3].xyz, -coords[3].xyz + 1));

	for (int i = 0; i < 4; ++i) {
		float factor = 3;
#ifdef SHADER_BIAS
		vec3 coord = coords[i].xyz + biasCSM[i] / ndotle;
		// remap [0,1] to linear pyramid weight with max at f(0.5) = 1
#else
		vec3 coord = coords[i].xyz;
		if (i == 0) {
			coord -= GetScaleBias(ScaleBiasCSM[0], ndotl);
		}
#endif
		vec3 base_weight = 2 * min(coord, -coord + 1);
		vec3 weight;
		weight = factor * base_weight; // linear weight
		//weight = pow(base_weight, vec3(factor)); // exponential weight
		//weight = sqrt(weight);
		ret[i] = satElemMin3(weight);
	}

	//ret[0] = sqrt(ret[0]);
	//ret[1] = sqrt(ret[1]);
	//ret[2] = sqrt(ret[2]);
	//ret[3] = sqrt(ret[3]);
	//ret[0] = sqrt(ret[0]);
	//ret[1] = sqrt(ret[1]);
	//ret[2] = sqrt(ret[2]);
	//ret[3] = sqrt(ret[3]);
	//if(ret[0] > 0.0f) ret[0] = saturate(ret[0]+0.)

	//ret[0] = saturate(ret[0] + 0.95);
	
	// vec3 dir = normalize(IO_world_pos) * mat3(M_shadowCSM1);
	// float t = dot(dir, IO_texshadowCSM1.xyz);
	// if(t > 0.5)
	// ret[1] = 1;
	// ret[1] = satElemMin3(10000*min(IO_texshadowCSM1.xyz, -IO_texshadowCSM1.xyz + 1));
	// ret[1] = saturate(ret[1] + 0.6);
	// ret[1] = min(ret[1], saturate(dot(dir, IO_texshadowCSM1.xyz)));
	
	return ret;
}

vec3 view2csm2(vec3 vp)
{
	return mul(float4(vp, 1), M_shadowCSM2).xyz;
}

#ifndef DISABLE_SHADOW_HELPERS
float Get9Sample25TapGather(sampler2DShadow shadowmap, vec2 coords, float shadow_comparison)
{
	#if 0
		float shadow_sum = 0.0;
		//float shadow_transition_scale = 0.1;//is there an Egosoft value already something along these lines perhaps?
		//this method is actually NOT intended to be run on a sampler2DShadow bur that a reguler sampler2D
		//how about we just try to manually filter it?
		//for(int i = 5;)
		//shadow_comparison = shadow_comparison * shadow_transition_scale - 1.0;
		vec2 texel_pos = coords.xy * F_shadowmapsize - 0.5;
		vec2 sample_fraction = fract(texel_pos);
		vec2 sample_pos = ceil(texel_pos) / F_shadowmapsize;
		
		vec4 gather00 = textureGatherOffset(shadowmap, sample_pos, shadow_comparison, ivec2(-2, -2));// * shadow_transition_scale - shadow_comparison);
		vec4 gather20 = textureGatherOffset(shadowmap, sample_pos, shadow_comparison, ivec2( 0, -2));// * shadow_transition_scale - shadow_comparison);
		vec4 gather40 = textureGatherOffset(shadowmap, sample_pos, shadow_comparison, ivec2( 2, -2));// * shadow_transition_scale - shadow_comparison);
		vec2 sum0;
		sum0 =  gather00.wx * (1.0 - sample_fraction.x);
		sum0 += gather00.zy;
		sum0 += gather20.wx;
		sum0 += gather20.zy;
		sum0 += gather40.wx;
		sum0 += gather40.zy * sample_fraction.x;
		
		shadow_sum += sum0.x * (1.0 - sample_fraction.y) + sum0.y;
		
		vec4 gather02 = textureGatherOffset(shadowmap, sample_pos, shadow_comparison, ivec2(-2, 0));// * shadow_transition_scale - shadow_comparison);
		vec4 gather22 = textureGatherOffset(shadowmap, sample_pos, shadow_comparison, ivec2(0, 0));// * shadow_transition_scale - shadow_comparison);
		vec4 gather42 = textureGatherOffset(shadowmap, sample_pos, shadow_comparison, ivec2(2, 0));// * shadow_transition_scale - shadow_comparison);
		vec2 sum1;
		sum1 =  gather02.wx * (1.0 - sample_fraction.x);
		sum1 += gather02.zy;
		sum1 += gather22.wx;
		sum1 += gather22.zy;
		sum1 += gather42.wx;
		sum1 += gather42.zy * sample_fraction.x;	
		shadow_sum += sum1.x + sum1.y;
		
		vec4 gather04 = textureGatherOffset(shadowmap, sample_pos, shadow_comparison, ivec2(-2, 2));// * shadow_transition_scale - shadow_comparison);
		vec4 gather24 = textureGatherOffset(shadowmap, sample_pos, shadow_comparison, ivec2(0, 2));// * shadow_transition_scale - shadow_comparison);
		vec4 gather44 = textureGatherOffset(shadowmap, sample_pos, shadow_comparison, ivec2(2, 2));// * shadow_transition_scale - shadow_comparison);
		vec2 sum2;			
		sum2 =  gather04.wx * (1.0 - sample_fraction.x);
		sum2 += gather04.zy;
		sum2 += gather24.wx;
		sum2 += gather24.zy;
		sum2 += gather44.wx;
		sum2 += gather44.zy * sample_fraction.x;		
		shadow_sum += sum2.x + sum2.y * sample_fraction.y;
		return shadow_sum * 0.04;//*(1.0/25.0)
	#else
		return 1.0;
	#endif
}

float GetCustomCSM(in float ndotl, in vec4 coords[5])
{
	#if 0
		// cascade blending weights
		vec4 weights = getCSMWeights(coords, ndotl);
		float w0 = weights.x;
		float w1 = min(1.0 - weights.x, weights.y);
		float w2 = min(1.0 - weights.y, weights.z);
		float w3 = min(1.0 - weights.z, weights.w);
		float w4 = 1.0 - (weights.w + weights.z + weights.y + weights.x); // recheck this one
		w4 = 1.0 - saturate(w0 + w1 + w2 + w3);
		
		float shadow = 0.0;
		if (w0 > 0.0)
			shadow += w0 * Get9Sample25TapGather(T_shadowCSM0, coords[0].xy, shadow_comparison);
		if (w1 > 0.0)
			shadow += w1 * Get9Sample25TapGather(T_shadowCSM1, coords[1].xy, shadow_comparison);
		if (w2 > 0.0)
			shadow += w2 * Get9Sample25TapGather(T_shadowCSM2, coords[2].xy, shadow_comparison);
		if (w3 > 0.0)
			shadow += w3 * Get9Sample25TapGather(T_shadowCSM3, coords[3].xy, shadow_comparison);
		if (w4 > 0.0)
			shadow += w4 * Get9Sample25TapGather(T_shadowCSM4, coords[4].xy, shadow_comparison);
		
		return shadow;
	#else
		return 1.0;
	#endif
}	
float GetCSMShadow(in float ndotl, in vec4 coords[5])
{
#if D_SHADOW_QUALITY == 0
	return 1.0f;
#else

	float Shadow = 0.0f;
	// z = length(IO_worldview_pos)-5;
	
	// cascade blending weights
	vec4 weights = getCSMWeights(coords, ndotl);
	float w0 = weights.x;
	float w1 = min(1.0f-weights.x, weights.y);
	float w2 = min(1.0f-weights.y, weights.z);
	float w3 = min(1.0f-weights.z, weights.w);
	float w4 = 1.0f - (weights.w + weights.z + weights.y + weights.x); // recheck this one
	w4 = 1 - saturate(w0+w1+w2+w3);
	
	float ndotle = max(epsilon, ndotl);

#define USE_BRANCH

#ifdef USE_BRANCH
	if (w0 > 0.0f)
#endif
#ifdef SHADER_BIAS
		Shadow += w0 * GetCSMSample3Taps(T_shadowCSM0, coords[0].xyz + biasCSM[0] / ndotle, F_texturefactorCSM0);
#else
		Shadow += w0 * GetCSMSample3Taps(T_shadowCSM0, coords[0].xyz - GetScaleBias(ScaleBiasCSM[0], ndotl), F_texturefactorCSM0);
#endif
#ifdef D_USE_CSM_C1
#ifdef USE_BRANCH
	if (w1 > 0.0f)
#endif
#ifdef SHADER_BIAS
		Shadow += w1 * GetCSMSample3Taps(T_shadowCSM1, coords[1].xyz + biasCSM[1] / ndotle, F_texturefactorCSM1);
#else
		Shadow += w1 * GetCSMSample3Taps(T_shadowCSM1, coords[1].xyz - GetScaleBias(ScaleBiasCSM[1], ndotl), F_texturefactorCSM1);
#endif
#endif

#ifdef D_USE_CSM_C2
#ifdef USE_BRANCH
	if (w2 > 0.0f)
#endif
#ifdef SHADER_BIAS
		Shadow += w2 * GetCSMSample3Taps(T_shadowCSM2, coords[2].xyz + biasCSM[2] / ndotle, F_texturefactorCSM2);
#else
		Shadow += w2 * GetCSMSample3Taps(T_shadowCSM2, coords[2].xyz - GetScaleBias(ScaleBiasCSM[2], ndotl), F_texturefactorCSM2);
#endif
#endif

#ifdef D_USE_CSM_C3
#ifdef USE_BRANCH
	if (w3 > 0.0f)
#endif
#ifdef SHADER_BIAS
		Shadow += w3 * GetCSMSample2Taps(T_shadowCSM3, coords[3].xyz + biasCSM[3] / ndotle, F_texturefactorCSM3);
#else
		Shadow += w3 * GetCSMSample2Taps(T_shadowCSM3, coords[3].xyz - GetScaleBias(ScaleBiasCSM[3], ndotl), F_texturefactorCSM3);
#endif
#endif

#ifdef D_USE_CSM_C4
#ifdef USE_BRANCH
	if (w4 > 0.0f)
#endif
#ifdef SHADER_BIAS
		Shadow += w4 * GetCSMSampleFast(T_shadowCSM4, coords[4].xyz + biasCSM[4] / ndotle);
#else
		if (B_csmpcfenabled) {
			Shadow += w4 * GetCSMSample2Taps(T_shadowCSM4, coords[4].xyz - GetScaleBias(ScaleBiasCSM[4], ndotl), F_texturefactorCSM4);
		}
		else {
			Shadow += w4 * GetCSMSampleFast(T_shadowCSM4, coords[4].xyz - GetScaleBias(ScaleBiasCSM[4], ndotl));
		}
#endif
#endif

	return Shadow;
#endif // D_SHADOW_QUALITY
}

float GetCSMShadow(in float ndotl, in vec3 view_pos)
{
#if D_SHADOW_QUALITY == 0
	return 1.0f;
#else
	CONST float FADE_STR = 0.1;
	float fade = saturate((view_pos.z - (1.0 - FADE_STR) * F_shadowmaxdistance) / (FADE_STR * F_shadowmaxdistance));
	vec4 coords[5];
	coords[0] = mul(float4(view_pos, 1), M_shadowCSM0);
	coords[1] = mul(float4(view_pos, 1), M_shadowCSM1);
	coords[2] = mul(float4(view_pos, 1), M_shadowCSM2);
	coords[3] = mul(float4(view_pos, 1), M_shadowCSM3);
	coords[4] = mul(float4(view_pos, 1), M_shadowCSM4);
	return saturate(fade + GetCSMShadow(ndotl, coords));
#endif // D_SHADOW_QUALITY
}

#endif //DISABLE_SHADOW_HELPERS
