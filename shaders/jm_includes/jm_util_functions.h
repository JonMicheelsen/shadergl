/////////////////////////// JON MOD UTIL FUNCTIONS //////////////////////
//Included in the very end of common.h, that is included most anywhere
//safeguard for double includes. #pragma once is not always safe to use, so let's do it manually
#ifndef _JM_UTILS_FUNCTIONS_
	/*
	Egosoft already got this one! and we inject after it's defined!
	float pow2(float x)
	{
		return x*x;
	}
	*/
	float pow4(float x)
	{
		return pow2(pow2(x));
	}
	vec2 pow4(vec2 x)
	{
		return pow2(pow2(x));
	}
	vec3 pow4(vec3 x)
	{
		return pow2(pow2(x));
	}
	vec4 pow4(vec4 x)
	{
		return pow2(pow2(x));
	}
	float pow5(float x)
	{
		return pow4(x)*x;
	}
	vec2 pow5(vec2 x)
	{
		return pow4(x)*x;
	}
	vec3 pow5(vec3 x)
	{
		return pow4(x)*x;
	}
	vec4 pow5(vec4 x)
	{
		return pow4(x)*x;
	}
	// from https://blog.selfshadow.com/publications/blending-in-detail/
	//nice angle corrected blend
	vec3 blend_reoriented_normals(vec3 n1, vec3 n2)
	{

		n1 = vec3(n1.xy, n1.z + 1.0);
		n2 = vec3(-n2.xy, n2.z);

		return normalize(n1 * dot(n1, n2) - n2 * n1.z);
	}

	// Hash without Sine
	// MIT License...
	/* Copyright (c)2014 David Hoskins.

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.*/

	//----------------------------------------------------------------------------------------
	// https://www.shadertoy.com/view/4djSRW
	//  1 out, 1 in...
	float hash11(float p)
	{
		p = fract(p * .1031);
		p *= p + 33.33;
		p *= p + p;
		return fract(p);
	}

	//----------------------------------------------------------------------------------------
	//  1 out, 2 in...
	float hash12(vec2 p)
	{
		vec3 p3  = fract(vec3(p.xyx) * .1031);
		p3 += dot(p3, p3.yzx + 33.33);
		return fract((p3.x + p3.y) * p3.z);
	}

	//----------------------------------------------------------------------------------------
	//  1 out, 3 in...
	float hash13(vec3 p3)
	{
		p3  = fract(p3 * .1031);
		p3 += dot(p3, p3.zyx + 31.32);
		return fract((p3.x + p3.y) * p3.z);
	}
	//----------------------------------------------------------------------------------------
	// 1 out 4 in...
	float hash14(vec4 p4)
	{
		p4 = fract(p4  * vec4(.1031, .1030, .0973, .1099));
		p4 += dot(p4, p4.wzxy+33.33);
		return fract((p4.x + p4.y) * (p4.z + p4.w));
	}

	//----------------------------------------------------------------------------------------
	//  2 out, 1 in...
	vec2 hash21(float p)
	{
		vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
		p3 += dot(p3, p3.yzx + 33.33);
		return fract((p3.xx+p3.yz)*p3.zy);

	}

	//----------------------------------------------------------------------------------------
	///  2 out, 2 in...
	vec2 hash22(vec2 p)
	{
		vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
		p3 += dot(p3, p3.yzx+33.33);
		return fract((p3.xx+p3.yz)*p3.zy);

	}

	//----------------------------------------------------------------------------------------
	///  2 out, 3 in...
	vec2 hash23(vec3 p3)
	{
		p3 = fract(p3 * vec3(.1031, .1030, .0973));
		p3 += dot(p3, p3.yzx+33.33);
		return fract((p3.xx+p3.yz)*p3.zy);
	}

	//----------------------------------------------------------------------------------------
	//  3 out, 1 in...
	vec3 hash31(float p)
	{
	   vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
	   p3 += dot(p3, p3.yzx+33.33);
	   return fract((p3.xxy+p3.yzz)*p3.zyx); 
	}


	//----------------------------------------------------------------------------------------
	///  3 out, 2 in...
	vec3 hash32(vec2 p)
	{
		vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
		p3 += dot(p3, p3.yxz+33.33);
		return fract((p3.xxy+p3.yzz)*p3.zyx);
	}

	//----------------------------------------------------------------------------------------
	///  3 out, 3 in...
	vec3 hash33(vec3 p3)
	{
		p3 = fract(p3 * vec3(.1031, .1030, .0973));
		p3 += dot(p3, p3.yxz+33.33);
		return fract((p3.xxy + p3.yxx)*p3.zyx);

	}

	//----------------------------------------------------------------------------------------
	// 4 out, 1 in...
	vec4 hash41(float p)
	{
		vec4 p4 = fract(vec4(p) * vec4(.1031, .1030, .0973, .1099));
		p4 += dot(p4, p4.wzxy+33.33);
		return fract((p4.xxyz+p4.yzzw)*p4.zywx);
		
	}

	//----------------------------------------------------------------------------------------
	// 4 out, 2 in...
	vec4 hash42(vec2 p)
	{
		vec4 p4 = fract(vec4(p.xyxy) * vec4(.1031, .1030, .0973, .1099));
		p4 += dot(p4, p4.wzxy+33.33);
		return fract((p4.xxyz+p4.yzzw)*p4.zywx);

	}

	//----------------------------------------------------------------------------------------
	// 4 out, 3 in...
	vec4 hash43(vec3 p)
	{
		vec4 p4 = fract(vec4(p.xyzx)  * vec4(.1031, .1030, .0973, .1099));
		p4 += dot(p4, p4.wzxy+33.33);
		return fract((p4.xxyz+p4.yzzw)*p4.zywx);
	}

	//----------------------------------------------------------------------------------------
	// 4 out, 4 in...
	vec4 hash44(vec4 p4)
	{
		p4 = fract(p4  * vec4(.1031, .1030, .0973, .1099));
		p4 += dot(p4, p4.wzxy+33.33);
		return fract((p4.xxyz+p4.yzzw)*p4.zywx);
	}
	#define _JM_UTILS_FUNCTIONS_
#endif