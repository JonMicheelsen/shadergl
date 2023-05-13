#include <blur_common.h>

float TexelSize;

uint getflags(vec2 uv, int dir)
{
	uint flags = 0;
// 	flags |= textureLod(T_flags, uv, 2).r;
	flags |= textureLod(T_flags, uv, 1).r;
	vec2 off = vec2(0);
	off[BLUR_AXIS] = (dir * 1) / V_viewportpixelsize[BLUR_AXIS];
	flags |= textureLod(T_flags, uv + off, 1).r;
	/**/
	return flags;
}

void main()
{
/*	{
		uint flags = textureLod(T_flags, IO_uv0, 0).r;
		// uint flags = texelFetch(T_flags, ivec2(gl_FragCoord.xy), 2).r;
	
		OUT_Color = vec4(0);
		if (IsComplex(flags))
			OUT_Color.r = 1;
		if ((flags & FLAG_BACKGROUND) != 0)
			OUT_Color.g = 1;
		return;
	}/**/
	if ((textureLod(T_flags, IO_uv0, 1).r & FLAG_BACKGROUND) != 0) {
		OUT_Color = vec4(0);
		return;
	}
	
	//TODO @Timon great "optimization" (a.k.a. removing stupid) potential here...
	TexelSize = /*g_BlurWidth*/1 / V_viewportpixelsize[BLUR_AXIS];
	int mid = _TAPSIZE2 / 2;
	
	float roughness;
	{
		float s;
		RETRIEVE_GBUFFER_UV_SMOOTH(IO_uv0, s);
		roughness = smooth2rough(s);
	}
	vec4 first = RTResolve(S_input_rt, IO_uv0);
	float hit, dist;
	SSR_GetHitDist(first.a, hit, dist);
	
	if (hit >= 0.7) //apply contact hardening only on fairly certain hits
	{
		#ifdef JON_MOD_SSR_WIDER_ROUGH_SCATTER
			#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
				if(IO_uv0.x > 0.5)
				{	
			#endif
			dist += (0.6 * roughness); // make sure it never goes overly smooth for rough surfaces
			#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN	
				}
				else
				{
					dist += (0.3 * roughness);
				}
			#endif
		#else
			dist += (0.3 * roughness);
		#endif
		dist = saturate(dist);
		roughness *= (dist);
	}
	
	int width = 1 + int(smoothstep(0, 1, roughness) * 30);
	// width = 5;
	vec3 col = first.rgb;
	float wsum = 1.0f;
	
#define GETLINE(ss)			\
	{			\
		uint edge = 0;			\
		vec3 csum = vec3(0);			\
		for (int i = 1; i < width; ++i) {			\
			float fac = float(width - i) / float(2 * width);	\
			vec2 off = vec2(0);			\
			off[BLUR_AXIS] = TexelSize * (0.2 + 2.0 * float(i));	/*TODO @Timon improve interpolated sampling*/		\
			vec2 uv = IO_uv0 ss off;			\
			if (IsComplex(getflags(uv, ss 1)))			\
				break;			\
			if (edge < 1) {			\
				vec4 pix = textureLod(S_input_rt, uv, 0);			\
				csum += pix.rgb * fac;			\
				float h, d;		\
				SSR_GetHitDist(pix.a, h, d);			\
				hit += h * fac;		\
				dist += d * fac;	\
				wsum += fac;	\
			}			\
		}			\
		col += csum;			\
	}
	
	GETLINE(-)
	GETLINE(+)
	col /= wsum;
	hit /= wsum;
	dist /= wsum;

	OUT_Color.rgb = col.rgb;
	OUT_Color.a = SSR_Encode(hit, dist);
}

