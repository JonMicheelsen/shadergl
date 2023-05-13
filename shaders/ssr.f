
#include <common.fh>

const int baselvl = 1;

float ambRoughness;

uint ray_axis;
uint ray_other;
float ray_ofact;
float ray_ooff;
float ray_zfact;
float ray_zoff;

// float ray_dfact;	//ray distance for each step

int starti;

float i2lvl(int i)
{
	float sm = saturate(1.0f - ambRoughness);
// 	float dist = ray_dfact * abs(i - starti);
	float dist = abs(i - starti);
// 	float dist = abs(i - starti);
	dist = saturate(dist / (sm * 2000.0f));
// 	dist = pow2(dist);
// 	dist = sqrt(dist);
// 	dist = 0.0f;
	float f = 0;
	f += dist;
	f += 0.2f * ambRoughness;
	f = saturate(f);
	return f * U_size;
}

float getz(int i, int lvl)
{
	ivec2 pix;
	pix[ray_axis] = i;
	pix[ray_other] = int(i * ray_ofact + ray_ooff);
	
	float z = texelFetch(T_maindepth_mips, pix >> lvl, lvl - baselvl).x;
	return z;
}

uint getflags(int i, int lvl)
{
	ivec2 pix;
	pix[ray_axis] = i;
	pix[ray_other] = int(i * ray_ofact + ray_ooff);
	
	uint flags = texelFetch(T_flags, pix >> lvl, lvl).r;
	return flags;
}

vec2 getuv(int i)
{
	vec2 pix;
	pix[ray_axis] = i;
	pix[ray_other] = int(i * ray_ofact + ray_ooff);
	return pix / (V_viewportpixelsize.xy * 2);
}

vec4 TAA_color = vec4(0);
float TAA_mix = 1.0f;
void TAA_OUT(vec3 col, vec2 hit_dist)
{
// 	OUT_Color = col;	return;
// 	OUT_Color = vec4(col, SSR_Encode(hit_dist));	return;
	vec2 ohd = SSR_Decode(TAA_color.a);
	ohd.y = hit_dist.y;//TODO @Timon distance broken by interpolated fetch so ignore
	OUT_Color.rgb = mix(TAA_color.rgb, col.rgb, TAA_mix);
	OUT_Color.a = SSR_Encode(mix(ohd, hit_dist, TAA_mix));
}

void TAA_OUT()
{
	TAA_OUT(vec3(0), vec2(0));
}

void main()
{
	OUT_Color = vec4(0);
// 	OUT_Color.rgb = textureLod(T_maincolor_last, GetFragUV(), 0).rgb;	return;
	
	
	vec2 pix_uv = GetFragUV();
	vec2 pix_ss = uv2clip(pix_uv);
	
	vec2 vpsize = V_viewportpixelsize.xy * 2;	//we're rendering at half-res but we want the full-res to be tha basis
	
	vec3 view_pos;
	RetrieveZBufferViewPos(view_pos, pix_uv);
	if (view_pos.z > BGDIST) {
// 		OUT_Color.r = 1;
		return;
	}
// 	OUT_Color.rgb = view_pos;	OUT_Color.a = 1;	return;
// 	TAA_OUT(vec4(view_pos, 1));	return;
	
	#if 1
	{
		vec4 reproj;
	//	reproj = vec4(uv2clip(pix_uv), gl_FragCoord.z, 1);
		if (IsStationary(GetFlags(pix_uv))) {
			reproj.xy = pix_uv;
			TAA_mix = 0.3;
		}
		else {
			reproj = vec4(Project(view_pos), 1);
			reproj = M_texturematrix0 * reproj;
			reproj /= reproj.w;
			reproj.xy = clip2uv(reproj.xy);
			vec2 dist = abs(reproj.xy - pix_uv);
			TAA_mix = 0.1 + 0.7 * (smoothstep(0, 8.0 / V_viewportpixelsize.x, dist.x + dist.y));
		}
		if (U_pass != 0) {
			TAA_color = textureLod(S_input_rt, reproj.xy, 0);//TODO @Timon interpolated fetch effectively breaks distance info
			if (any(isnan(TAA_color)) || any(isinf(TAA_color))) {
				TAA_color = vec4(0);
			}
		}
		else {
			TAA_mix = 1;
			TAA_color = vec4(0);
		}
// 		TAA_mix = 0.1;
// 		OUT_Color = vec4(vec3(TAA_mix), 0);		return;
		//TODO @Timon don't TAA for stationary objects
	}
	#endif
	
	float constfade = 1;
	vec3 normal;
	float smoothness;
	RETRIEVE_GBUFFER_UV_NORMAL0_SMOOTH(pix_uv, normal, smoothness);
	
	if (any(isnan(normal))) {
		TAA_OUT();
		return;
	}
	else if (any(isinf(normal))) {
		TAA_OUT();
		return;
	}
	
// 	OUT_Color.rgb = normal;		return;
	
	vec3 ray = reflect(normalize(view_pos), normal);
// 	OUT_Color.rgb = ray;		return;
	if (ray.z < -0.4) {//rays facing camera are unlikely to hit something sensible
// 		OUT_Color.g = 1;
		//TODO @Timon many cases where this is too much:/
// 		return;
	}
	if (ray.z < -0.2) {
		constfade = smoothstep(-0.4, -0.2, ray.z);
	}
	float Roughness = smooth2rough(smoothness);
	
	float v_dot_n = saturate(dot(view_pos, normal));
	// smaller cone at edges to highlight fresnel
	#ifdef JON_MOD_DISABLE_EGOSOFT_SMOOTHER_GRAZING_ANGLE
		#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
		if(pix_uv.x > 0.5)
		{	
		#endif
			#ifdef JON_MOD_SSR_ANGLES_SHARPEN_POW5
				ambRoughness = Roughness;			
			#else
				ambRoughness = Roughness * (v_dot_n * 0.5 + 0.5);
			#endif
		#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN	
		}
		else
		{
			ambRoughness = mix(Roughness*0.75, Roughness, pow(v_dot_n, 1.0/3.0));
		}
		#endif
	#else
		ambRoughness = mix(Roughness*0.75, Roughness, pow(v_dot_n, 1.0/3.0));
	#endif
	
// 	if (Roughness >= 0.5) //don't bother for really rough surfaces since it'll have very little impact
// 		return;
	
	{
		vec2 pos;
		{
			switch(int(U_offset + pix_ss.x + pix_ss.y) % 8) {
			case 0:		pos[0] = 0.5000f;	pos[1] = 0.3333f;	break;	//halton
			case 1:		pos[0] = 0.2500f;	pos[1] = 0.6667f;	break;
			case 2:		pos[0] = 0.7500f;	pos[1] = 0.1111f;	break;
			case 3:		pos[0] = 0.1250f;	pos[1] = 0.4444f;	break;
			case 4:		pos[0] = 0.6250f;	pos[1] = 0.7778f;	break;
			case 5:		pos[0] = 0.3750f;	pos[1] = 0.2222f;	break;
			case 6:		pos[0] = 0.8750f;	pos[1] = 0.5555f;	break;
			case 7:		pos[0] = 0.0625f;	pos[1] = 0.8889f;	break;
			}
			pos *= vec2(2);
			pos -= vec2(1);
		}
#ifdef JON_MOD_SSR_WIDER_ROUGH_SCATTER
		float scale;
		#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
			if(pix_uv.x > 0.5)
			{	
		#endif
		scale = 0.01f + 0.4f * (ambRoughness);
		#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN	
			}
			else
			{
				scale = 0.01f + 0.2f * (ambRoughness);
			}
		#endif
#else
		float scale = 0.01f + 0.2f * (ambRoughness);
#endif
		scale *= 0.05f;
		scale *= saturate(1.0f - TAA_mix);
		view_pos.xy += pos * scale;
	}
	vec3 view0_cs = Project(view_pos);
	vec3 view1_cs = Project(view_pos + ray);
	vec3 view0_uv = vec3(clip2uv(view0_cs.xy), view0_cs.z);
	vec3 view1_uv = vec3(clip2uv(view1_cs.xy), view1_cs.z);
// 	vec3 view0_pix = vec3(view0_uv.xy * vpsize.xy, view0_uv.z);
	vec3 view0_pix = vec3(gl_FragCoord.xy * 2, view0_uv.z);
	vec3 view1_pix = vec3(view1_uv.xy * vpsize.xy, view1_uv.z);
// 	vec3 ray_cs = view1_cs - view0_cs;
// 	vec3 ray_uv = view1_uv - view0_uv;
	vec3 ray_pix = view1_pix - view0_pix;
// 	ray_uv.xy = clip2uv(view1_cs.xy) - clip2uv(view0_cs.xy);
// 	vec3 ray_uv = clip2uv(ray_cs);
// 	ray_pix = normalize(ray_pix);
	
// 	OUT_Color.rg = abs(view0_pix.xy - gl_FragCoord.xy * 2);
// 	OUT_Color.rg *= 1000;
// 	OUT_Color.rgb = ray_cs;
// 	OUT_Color.rgb = ray_pix;
// 	return;
	{
		if (abs(ray_pix.y) >= abs(ray_pix.x)) {
			ray_axis = 1;
			ray_other = 0;
		}
		else {
			ray_axis = 0;
			ray_other = 1;
		}
		
// 		ray_dfact = length(ray) / abs(ray_pix[ray_axis]);
		ray_pix /= vec3(abs(ray_pix[ray_axis]));
// 		OUT_Color.rgb = ray_pix; 	return;
		
		ray_ofact = ray_pix[ray_other] / ray_pix[ray_axis];
		ray_ooff = view0_pix[ray_other] - ray_ofact * view0_pix[ray_axis];
		
		ray_zfact = ray_pix[2] / ray_pix[ray_axis];
		ray_zoff = view0_pix[2] - ray_zfact * view0_pix[ray_axis];
		
// 		ray_dfact = length(ray) / abs(ray_pix[ray_axis]);
		//TODO @Timon ray_dfact is clearly 1, for it to really make sense it'd have to be above the first divide, but arguably it looks better this way since you always get a certain amount of it as a percentage of the screensize (except it's steps, so resolution dependent TODO @Timon at least fix that)
	}
/*	if (abs(ray_pix[ray_axis]) < 0.999) {
		OUT_Color.rb = vec2(1);
		return;
	}/**/
	
	starti = int(view0_pix[ray_axis]);
	int i = starti;
	int dir = int(1.1 * ray_pix[ray_axis]);	//often the ray is just barely below 1
	if (IsComplex(getflags(i, 1))) {
		TAA_OUT();
		return;
	}
/*	{
		OUT_Color.rgba = vec4(0);
// 		OUT_Color[ray_axis] = float(abs(dir)) / 2;
		OUT_Color[ray_axis] = abs(ray_ofact);
		if (OUT_Color[ray_axis] > 1) {
			OUT_Color.b = 1;
		}
		return;
	}/**/
	
	int lvl = baselvl;
	
	uint a = 0;
	uint end = 400;
	
	i += dir << lvl;	//otherwise insta-hit when right cheek is against the wall
	uint abort = 0;
	for (; a < end; ++a) {
		int mask = (1 << lvl) - 1;
		int pi = i;
		i += 1 * (dir << lvl);
		int minlvl = baselvl;
// 		minlvl = 4;
// 		minlvl = max(minlvl, int(i2lvl(i)));
		
		float walk_z_near;
		float walk_z_far;
		vec3 walk_pix = vec3(0.0);
		walk_pix[ray_axis] = i;
		walk_pix[ray_other] = i * ray_ofact + ray_ooff;
		{
			int inext = i;
			int iprev = pi;
			if (dir > 0) {
				inext |= mask;
				iprev &= ~mask;
			}
			else {
				inext &= ~mask;
				iprev |= mask;
			}
			if (dir * ray_zfact <= 0) {
				walk_z_far = inext * ray_zfact + ray_zoff;
				walk_z_near = iprev * ray_zfact + ray_zoff;
			}
			else {
				walk_z_near = inext * ray_zfact + ray_zoff;
				walk_z_far = iprev * ray_zfact + ray_zoff;
			}
		}
		float hit_z = texelFetch(T_maindepth_mips, ivec2(walk_pix.xy) >> (lvl - 0), lvl - baselvl).x;
		if (hit_z - walk_z_far >= 0) {
// 			minlvl = clamp(minlvl, baselvl, 4);
			if (lvl <= minlvl)
			{
				if (hit_z < BGZ) {
					TAA_OUT();
					return;//don't reflect background the envmap will do it better
				}
				uint flags = 0;
				flags = getflags(i, lvl);
				if (!IsComplexDepth(flags)) {
					bool reproject = true;
					if ((flags & FLAG_STATIONARY) != 0) {
						reproject = false;
					}
					float threshold = 0;
					float slope_fact = 0;
					{
						float zn = getz(i + (dir << lvl), lvl);
						float zp = getz(i - 2 * (dir << lvl), lvl);
						
						float sn = zn - hit_z;
						float sp = hit_z - zp;
						
						if (abs(sp - sn) < 0.06 * hit_z)
						{
							threshold = abs(sp);
						}/**/
					}/**/
					if (hit_z - walk_z_near <= threshold)
					{
						{
							vec3 n;
							RetrieveGBufferNormal(n, getuv(i));
							if (dot(ray, n) >= 0) {
								TAA_OUT();
								return;
							}
						}
						vec4 reproj;
						if (reproject) {
							reproj = vec4(uv2clip(walk_pix.xy / (vpsize.xy)), hit_z, 1);
							reproj = M_texturematrix0 * reproj;
							reproj /= reproj.w;
							reproj.xy = clip2uv(reproj.xy);
						}
						else {
							reproj.xy = walk_pix.xy / (vpsize.xy);
						}
						float reslvl = 0;
// 						reslvl = minlvl;
// 						reslvl = i2lvl(i);
// 						reslvl = min(reslvl, 6);
						
						float fade = 1;
						{
							int outi = i + 40 * (dir << lvl);
							vec2 out_pix;
							out_pix[ray_axis] = outi;
							out_pix[ray_other] = outi * ray_ofact + ray_ooff;
							
							vec2 tmp = uv2clip(out_pix.xy / vpsize.xy);
							tmp = abs(tmp);
							tmp = 1 - saturate(tmp);
							
							fade = tmp.x * tmp.y;
							fade = smoothstep(0.0, 0.1, fade);
	// 						OUT_Color.rgb = vec3(fade);			return;
						}
	// 					OUT_Color.rg = reproj.xy;
	// 					OUT_Color.b = TO_linearRGB(slope_fact) * 1000000;
	// 					OUT_Color.b = TO_linearRGB(ray_dfact * abs(i - starti) / 1000.0f);
	// 					OUT_Color.b = TO_linearRGB(reslvl / U_size);
						vec3 outcol;
						outcol = textureLod(T_maincolor_last, reproj.xy, reslvl).rgb;
						outcol = min(outcol, vec3(2.0f));	//limit extremely bright reflections a bit
						
						if (any(isnan(outcol)) || any(isinf(outcol))/**/) {//TODO @Timon remove
							TAA_OUT();
							return;
						}
						TAA_OUT(outcol, vec2(fade, float(abs(i - starti)) / 1000));
						return;
					}
 #if defined(QUALITY_MEDIUM) || defined(QUALITY_HIGH)
					if (++abort > 32)	//this will not break if only a few pixels are blocking (it's mostly to handle the damn rail guards around docks:/)	//TODO @Timon maybe use higher mips as heuristic?
 #endif
					{
						TAA_OUT();
						return;
					}
				}
// 				OUT_Color.g = 1;
// 				return;
			}
			else
			{
				i -= dir << lvl;
				--lvl;
			}
		}
		else {
			if (i <= 0 || i >= vpsize[ray_axis] - 1) {
// 				OUT_Color.b = 1;
				TAA_OUT();
				return;
			}
			if (lvl < 6) {
				++lvl;
			}
		}
	}
	TAA_OUT();
}
