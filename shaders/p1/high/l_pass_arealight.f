#include <common.fh>


// HACK TO BOOS LOCAL SPEC!
//#define SPEC_BOOST 2.0
//#define DIFF_BOOST 1.0
//#define SPEC_POWER 1.0 // 15.0

// instance data
in vec3 IO_lightcolor;
in float IO_Intensity;
in vec3 IO_RadiusSizeXY;
in float IO_spotatten;
in float IO_SpecIntensity;
in float IO_Range;

in vec3 IO_Apex;
in vec3 IO_Direction;
in vec3 IO_right;
in vec3 IO_up;

in vec3 IO_view_center;

// currently unused
// in mat4 IO_areaaxis;


//float3 projectOnPlane(float3 p, float3 pc, float3 pn)
//{
//	float distance = dot(pn, p-pc);
//	return p - distance*pn;
//}
//
//int sideOfPlane(float3 p, float3 pc, float3 pn)
//{
//	if (dot(p-pc,pn)>=0.0) return 1; else return 0;
//}
//
//float isInBox (float3 p, float3 Apex, float3 Direction, float3 right, float3 up, float3 RangeSizeXY)
//{
//	if (sideOfPlane(p,Apex,Direction) == 0) return 0;
//	if (sideOfPlane(p,Apex+Direction*RangeSizeXY.x,-Direction) == 0) return 0;
//	if (sideOfPlane(p,Apex+Direction*RangeSizeXY.x*0.5f+right*RangeSizeXY.y*0.5f,-right) == 0) return 0;
//	if (sideOfPlane(p,Apex+Direction*RangeSizeXY.x*0.5f-right*RangeSizeXY.y*0.5f,right) == 0) return 0;
//	if (sideOfPlane(p,Apex+Direction*RangeSizeXY.x*0.5f+up*RangeSizeXY.z*0.5f,-up) == 0) return 0;
//	if (sideOfPlane(p,Apex+Direction*RangeSizeXY.x*0.5f-up*RangeSizeXY.z*0.5f,up) == 0) return 0;
//
//	return 1;
//}


#ifdef LPASS_AREA_PLANE
#if 1
vec3 planeRPM(in vec3 dir, in vec3 L) {
	vec2 lsize = IO_RadiusSizeXY.yz;

	// vec3 planeNormal = IO_Direction;
	float t = dot( L, IO_Direction ) / dot( dir, IO_Direction );
	vec3 p0 = t * dir;

	vec3 r = p0 - L;
	vec2 uv = vec2( dot(r,IO_right), dot(r,IO_up) );

	bool onSurface = abs(uv.x) < lsize.x && abs(uv.y) < lsize.y;
	if( !onSurface ) {
		vec3 bestP = L;
		float bestDot = 0.0;

		for( int i=0; i<4; ++i ) { // todo: simplify/vectorize?

			// axis and size
			vec3 ld = i>1 ? IO_right : IO_up;
			vec2 sz = i>1 ? lsize.xy : lsize.yx;

			// vector to edge center
			vec3 l0 = L + sz.y * (i>1 ? IO_up : IO_right) * ((i%2)!=0 ? -1.0 : 1.0);
			// vec3 l0 = L + IO_areaaxis[i].xyz;
				
			float dirL0 = dot(dir,l0);
			float dirld = dot(dir,ld);
			float l0ld = dot(l0,ld);
			float t = (l0ld*dirL0 - dot(l0,l0)*dirld) / (l0ld*dirld - dot(ld,ld)*dirL0); // magic
			t = clamp( t, -sz.x, sz.x );
			vec3 P = l0 + t*ld;

			// test point
			float dp = dot( normalize(P), dir );
			if( dp > bestDot ) {
				bestP = P;
				bestDot = dp;
			}
		}
		return bestP;
		// L = bestP;
	}
	else {
		return p0;
		// L = p0;
	}
}
#else
// potentially slightly faster version
vec3 planeRPM(in vec3 dir, in vec3 L) {
	vec2 lsize = IO_RadiusSizeXY.yz;
	float t = dot(L, IO_Direction) / dot(dir, IO_Direction);
	vec3 p0 = t * dir;

	vec3 r = p0 - L;
	vec2 uv = vec2(dot(r, IO_right), dot(r, IO_up));

	bool onSurface = abs(uv.x) < lsize.x && abs(uv.y) < lsize.y;
	if (!onSurface) {
		vec3 bestP = L;
		float bestDot = 0.0;

		vec3 lda[4] = vec3[](IO_up, IO_up, IO_right, IO_right);
		vec2 sza[4] = vec2[](lsize.yx, lsize.yx, lsize.xy, lsize.xy);

		for (int i = 0; i<4; ++i) { // todo: simplify/vectorize?

			vec3 ld = lda[i];
			vec2 sz = sza[i];

			// vector to edge center
			vec3 l0 = L + IO_areaaxis[i].xyz;

			float dirL0 = dot(dir, l0);
			float dirld = dot(dir, ld);
			float l0ld = dot(l0, ld);
			float t = (l0ld*dirL0 - dot(l0, l0)*dirld) / (l0ld*dirld - dot(ld, ld)*dirL0);
			t = clamp(t, -sz.x, sz.x);
			vec3 P = l0 + t*ld;

			// test point
			float dp = dot(normalize(P), dir);
			if (dp > bestDot) {
				bestP = P;
				bestDot = dp;
			}
		}

		return bestP;
	}
	else {
		return p0;
	}
}
#endif
#endif

#ifdef LPASS_AREA_TUBE
vec3 tubeRPM(in vec3 dir, in vec3 L) {
	vec2 lsize = IO_RadiusSizeXY.yz;
	float tubeLength = (IO_RadiusSizeXY.y > IO_RadiusSizeXY.z) ? IO_RadiusSizeXY.y : IO_RadiusSizeXY.z;
	vec3 tubeDir = (IO_RadiusSizeXY.y > IO_RadiusSizeXY.z) ? IO_right : IO_up;

	float dirL0 = dot(dir, L);
	float dirLd = dot(dir, tubeDir);
	float l0ld = dot(L, tubeDir);
	float t = (l0ld*dirL0 - dot(L, L)*dirLd) / (l0ld*dirLd - dot(tubeDir, tubeDir)*dirL0);
	t = clamp(t, -tubeLength, tubeLength);
	vec3 P = L + t*tubeDir;
	return P;
}
#endif

#ifndef LPASS_AREA_POINT
vec3 sphereRPM(in vec3 dir, in vec3 L, float lradius) {
	//closest point on sphere to ray
	vec3 closestPoint = dot(L, dir) * dir;
	vec3 centerToRay = closestPoint - L;
	float t = lradius / sqrt( dot(centerToRay, centerToRay) );
	// L = L + centerToRay * saturate(t);
	return L + centerToRay * saturate(t);
}
#endif

float getPhysicalAtt(in vec3 lraw) {
	// CONST float invSqScale = 1.0/5.0; // better color behavior over large distances
	CONST float invSqScale = 1.0; // no scaling
	// return 1.0 / ( 1 + dot(lraw, lraw)); // "inverse square" attenuation
	float dst = max(0.0f, length(lraw) - IO_RadiusSizeXY.x) * invSqScale;
	//float dstFromSurfaceSq = max(0.0f, dot(invSqScale*lraw, invSqScale*lraw));
	//float dstFromSurfaceSq = dot(invSqScale*lraw, invSqScale*lraw);
	//dstFromSurfaceSq = 
	return 1.0 / (1 + dst*dst); // "inverse square" attenuation
	//return 1.0 / (1 + dstFromSurfaceSq); // "inverse square" attenuation
}

// unused
// float getFillAtt(in vec3 lraw) {
// 	float cutoff = F_arealightcutoff; // 5%
// 	float atten_factor = sqrt(1.0/cutoff -1);
// 	vec3 t = (lraw/(IO_Range/2))*atten_factor;

// 	vec3 tt = lraw/(IO_Range/2);
// 	// return 1-dot(tt, tt);

// 	float scale_dst2 = dot(t, t);
// 	return saturate(1.0/(1+scale_dst2)-cutoff) * 1.0/(1.0-cutoff);
// }

void main()
{
	vec3 view_pos; // needed
	RetrieveZBufferViewPos(view_pos);

	// light stuff
	CONST vec3 tolight = IO_view_center - view_pos;
	vec3 L = tolight; // L vector, gets modified
	float distance = sqrt(dot(tolight,tolight));
	float invDistance = 1.0 / distance;
	// vec3 direction = tolight * invDistance; // light direction
	// mainly readability
	float lradius = IO_RadiusSizeXY.x;
	vec2 lsize = IO_RadiusSizeXY.yz;

	if (length(tolight) >  IO_RadiusSizeXY.x+ length(IO_RadiusSizeXY.yz) + IO_Range*2.0f) {
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}
	
	// attenuation
	// plane RPM (just clamped) for diffuse + attenuation
	float atten = 1.0f;
	vec3 ldiff = tolight;
	vec3 lraw = tolight; // from patch to closest point on ray/plane
	#if defined(LPASS_AREA_TUBE) || defined(LPASS_AREA_PLANE)
// 	if( lsize.x + lsize.y > 0.0 )
	{
		vec3 toSource = ldiff;
		vec2 uv = vec2( dot(-toSource,IO_right), dot(-toSource,IO_up) );
		uv = clamp( uv, -lsize.xy, lsize.xy );
		toSource += uv.x*IO_right + uv.y*IO_up;
		lraw = toSource;
		// distance_atten = 1.0 / ( 1 + 0.01*dot(toSource, toSource));
	}
	#endif
	ldiff = normalize(lraw);
	float dstFromSurface = max(0.0f, length(lraw) - lradius);
	float dstNorm = (IO_Range);// / 2.0;
	float linattenA = saturate(1.0 - dstFromSurface/ dstNorm);

	atten *= getPhysicalAtt(lraw) * linattenA;
	
	// spot attenuation, derived from single angle
	float sp0 = saturate(IO_spotatten)*0.99;

	float diratten = 1;
	if(sp0 > 0)
	{
		diratten = 0.5*dot(-ldiff, IO_Direction)+0.5; // 0-1
		diratten = (diratten-sp0)/(1-sp0); // remap
		diratten = saturate(diratten);
		diratten *= diratten;
	}
	atten *= diratten;

	

	float sizeMin = min(lsize.x, lsize.y);
	float sizeMax = max(lsize.x, lsize.y);
	float sizeSum = lsize.x + lsize.y;
	CONST float threshold = 0.001f;

	// accumulation
	float diffuse_occlusion = 1.0f;
	vec4 finalColor = vec4(0);
	if (atten <= 0) {
		LPASS_SHAPE_EARLY_DISCARD()
		discard;
	}
	{
		vec3 Normal;
		RI_GBUFFER_NORMAL0(Normal);
		
		vec3 v = normalize(-view_pos);
		vec3 dir = reflect(-v, Normal);
/*
#define USE_TUBELIGHTMATH
#ifdef USE_TUBELIGHTMATH
		if (sizeMin > threshold) {
			 L = planeRPM(dir, L);
			// L = planeRPMb(dir, L);
		}
		else if (sizeMax > threshold) {
			 L = tubeRPM(dir, L);
		}
#else
		if (sizeSum > threshold) {
			L = planeRPM(dir, L);
		}
#endif
		if (lradius > 0.0) {
			L = sphereRPM(dir, L, lradius);
		}
*/
#ifdef LPASS_AREA_PLANE
// 		if (sizeMin > threshold) {
			 L = planeRPM(dir, L);
			// L = planeRPMb(dir, L);
// 		}
		if (lradius > 0.0) {
			L = sphereRPM(dir, L, lradius);
		}
#endif
#ifdef LPASS_AREA_TUBE
// 		if (sizeMax > threshold) {
			 L = tubeRPM(dir, L);
// 		}
		if (lradius > 0.0) {
			L = sphereRPM(dir, L, lradius);
		}
#endif
#ifdef LPASS_AREA_SPHERE
		L = sphereRPM(dir, L, lradius);
#endif
		vec3 Lnorm = normalize(L);
		
		// wrt to plane RPM
		float n_dot_l = saturate(dot(Lnorm, Normal));
//		if (n_dot_l <= 0) {
//			discard;
//		}
		
		vec3 Albedo;
		float Metalness;
		float Smoothness;
		RI_GBUFFER(Normal, Albedo, Metalness, Smoothness);

		float diffndotl = saturate(dot(Normal, ldiff));
		vec3 cspec = vec3(0);
		vec3 cdiff = vec3(0);

		#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
			float Subsurface = 0.0;
			UnpackMetalSubsurface(Metalness, Subsurface);
		#endif

		get_colors(Albedo, Metalness, cspec, cdiff);
	
		talness, cspec, cdiff);

		float Roughness = smooth2rough(Smoothness);//was Smoothness*Smoothness - changed for consistency

		Roughness = max(Roughness, 0.05f); // avoid nans after squared divisions
		// float a = max(Roughness*Roughness, 0.0001f);
		float a = Roughness*Roughness;
		float a2 = a*a;
		float norm = 1.0 / (PI * a2); // factor used for spec mod

		// AO used to attenuate diffuse component
		
		if (B_ssao_enabled) {
			float ambient_occlusion = GetSSAO();
			// weight strength over distance
			float ssao_weight = 0.5*(linattenA*linattenA);
			diffuse_occlusion = saturate(ambient_occlusion);
		}
		else /**/{//TODO @Timon without this the attenuation breaks with vulkan nvidia-381.22 geforce 650ti on linux
			//looks like either glslang or nvidia-driver bug, or I'm not aware of some detail of the spec
			diffuse_occlusion = 1.0f;
		}
		#ifdef JON_MOD_DEBUG_DEBUG_LIGHT_TYPES
			vec3 lightcolor = vec3(1.0, 1.0, 0.0);
		#else	
			vec3 lightcolor = IO_lightcolor.rgb;
		#endif
		
		// diffuse contribution
		vec3 Idiff = lightcolor * diffndotl * diffuse_occlusion;
		finalColor.rgb += Idiff * cdiff/PI ;


		// energy convservation using spec D mod
		float sizeGuess = lsize.x + lsize.y + lradius;
		float solidAngleGuess = saturate( sizeGuess * invDistance );
		float specatten = 1.0 / ( 1.0 + norm * solidAngleGuess );
		
		// horizon mod
		float horizon = 1.0 - n_dot_l;
		horizon *= horizon;
		horizon *= horizon;
		specatten = specatten - specatten * horizon;
		
		// specular contribution
		vec3 Ispec = IO_SpecIntensity * lightcolor * specatten * n_dot_l;
		// vec3 Ispec = IO_SpecIntensity * IO_Intensity * IO_lightcolor.rgb * specatten * diffndotl;
		finalColor.rgb += Ispec * EvalBRDF(cspec, cdiff, Roughness, Lnorm, v, Normal, vec2(0,1));
	}
	finalColor.rgb *= atten;

/*	if (B_render_arealightshape) {
		// draw influence outline
		if(abs(linattenA - 0.01) < 0.01 || abs(sqrt(diratten) - 0.01) < 0.01)
			finalColor.rgb = IO_lightcolor.rgb;
		if(linattenA < 0.01 || sqrt(diratten) < 0.01) {
				finalColor.rgb = vec3(0,1,0);
			if(sizeMin > threshold) { // its a plane
				finalColor.rgb = vec3(1,0,0);
			} 
			else if (sizeMax > threshold) { // a tube
				finalColor.rgb = vec3(1,1,0);
			}
		}
	}*/

	finalColor.rgb = clamp(finalColor.rgb, 0, 10); // safety
	finalColor.rgb = clamp(finalColor.rgb, 0, 2); // reduce flares
	finalColor.rgb *= diffuse_occlusion;
	
	OUT_Color.rgb = finalColor.rgb;
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
