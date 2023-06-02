#include <common.fh>


#define kernelSize 32
#define noiseSize 4

CONST float3 noise[] = float3[](
	float3(-0.0347764, -0.999395, 0),
	float3(0.827435, 0.561562, 0),
	float3(0.808026, -0.589147, 0),
	float3(-0.372927, -0.92786, 0),
	float3(0.394819, 0.918759, 0),
	float3(0.997709, 0.0676573, 0),
	float3(0.78889, 0.614535, 0),
	float3(0.584352, 0.8115, 0),
	float3(0.438643, 0.898661, 0),
	float3(-0.00520357, 0.999986, 0),
	float3(-0.587648, -0.809116, 0),
	float3(-0.950485, 0.31077, 0),
	float3(0.742757, -0.669561, 0),
	float3(0.785835, -0.618436, 0),
	float3(-0.873283, 0.487214, 0),
	float3(0.811581, -0.58424, 0)
	);
/*
//Kernel 64 Samples
CONST float3 Kernel[] = float3[](
	float3(0.00553397, -0.00138349, 0.00255414),
	float3(-0.00427619, -0.00147455, 0.00431305),
	float3(-0.00315949, 0.0025276, 0.00476355),
	float3(-0.00342681, -0.00221927, 0.00473226),
	float3(0.00398588, -0.00312407, 0.0036627),
	float3(0.00689553, -0.00719534, 0.00754511),
	float3(-0.00488669, 0.0108593, 0.00380076),
	float3(0.0155269, -0.00637002, 0.00836065),
	float3(0.0117596, 0.0220493, 0.000734976),
	float3(0.00117166, 0.00527247, 0.0244096),
	float3(0.00919276, -0.0247642, 0.0166971),
	float3(-0.00677409, 0.0297307, 0.0218276),
	float3(-0.024869, 0.0296515, 0.0204054),
	float3(-0.034275, -0.00524617, 0.0360237),
	float3(-0.0431596, 0.0141099, 0.0331997),
	float3(0.0336005, -0.0495165, 0.0180381),
	float3(-0.0417474, 0.0622272, 0.00315075),
	float3(0.0107147, -0.0455375, 0.0664311),
	float3(-0.057395, -0.0542064, 0.0505623),
	float3(-0.064513, -0.064513, 0.0409409),
	float3(0.08231, 0.0224482, 0.0733307),
	float3(0.0606342, -0.035207, 0.0958412),
	float3(0.10537, -0.0470651, 0.0625193),
	float3(-0.0916899, 0.082455, 0.0738796),
	float3(-0.00227587, 0.139966, 0.0694142),
	float3(0.160261, 0.0526405, 0.00467916),
	float3(0.0421965, 0.0226053, 0.174814),
	float3(-0.1128, 0.0596097, 0.145815),
	float3(-0.00803284, 0.172706, 0.11246),
	float3(0.141539, 0.111035, 0.124457),
	float3(-0.04648, 0.123947, 0.197188),
	float3(-0.0773175, 0.181579, 0.153464),
	float3(0.208167, 0.0169136, 0.169136),
	float3(-0.13774, -0.168013, 0.178608),
	float3(-0.267164, -0.133582, 0.0279127),
	float3(0.246377, 0.171038, 0.107917),
	float3(-0.10071, 0.289924, 0.140384),
	float3(-0.0466947, 0.286005, 0.207208),
	float3(-0.245406, -0.256782, 0.120265),
	float3(0.0923541, 0.247898, 0.291644),
	float3(-0.0641562, 0.340028, 0.224547),
	float3(-0.217869, 0.275834, 0.24985),
	float3(0.389356, -0.223735, 0.0290565),
	float3(0.326067, -0.316661, 0.137952),
	float3(0.485133, 0.0911903, 0.0109428),
	float3(-0.0580089, -0.400261, 0.32485),
	float3(0.29161, -0.161615, 0.421605),
	float3(0.264961, 0.463681, 0.17664),
	float3(0.494022, -0.316681, 0.0285012),
	float3(-0.337298, 0.0224865, 0.510765),
	float3(0.489663, -0.100246, 0.385561),
	float3(-0.134755, -0.373946, 0.522177),
	float3(0.232828, -0.633811, 0.129349),
	float3(0.275142, 0.449938, 0.479071),
	float3(-0.453339, -0.0701595, 0.577467),
	float3(0.532448, -0.0536022, 0.543169),
	float3(0.734755, 0.0103487, 0.300111),
	float3(-0.354065, -0.228042, 0.70213),
	float3(-0.532494, -0.514744, 0.41712),
	float3(0.212251, -0.616344, 0.58369),
	float3(0.790812, 0.325629, 0.299785),
	float3(0.44054, 0.565866, 0.603843),
	float3(-0.602414, -0.243079, 0.71867),
	float3(0.672058, -0.62473, 0.397555)
	);
*/
//Kernel 32 Samples
CONST float3 Kernel[] = float3[](
	float3(-0.000338665, -0.00222014, 0.00583256),
	float3(0.000747583, -0.00399795, 0.00474553),
	float3(-0.00112216, -0.0124458, 0.000306043),
	float3(0.0126174, -0.0120953, 0.00678729),
	float3(-0.0141535, -0.0198148, 0.00566138),
	float3(-0.00856573, 0.0175394, 0.0320195),
	float3(0.0395274, 0.00790549, 0.0295818),
	float3(0.046976, 0.02205, 0.0348325),
	float3(0.0590314, 0.0060545, 0.0554996),
	float3(0.0471025, 0.0841494, 0.0264621),
	float3(0.0478339, -0.0661887, 0.0862122),
	float3(0.0537673, -0.0701312, 0.113379),
	float3(-0.0990694, -0.088979, 0.103656),
	float3(-0.0629529, 0.140595, 0.117512),
	float3(-0.0284788, 0.199352, 0.0854365),
	float3(0.190873, 0.116021, 0.112278),
	float3(-0.215463, -0.0882209, 0.15778),
	float3(-0.0225137, 0.317443, 0.018011),
	float3(-0.0593876, 0.23755, 0.25876),
	float3(0.27374, 0.171668, 0.225024),
	float3(-0.251198, 0.348252, 0.0399633),
	float3(0.08359, -0.465715, 0.041795),
	float3(0.346686, 0.28446, 0.260755),
	float3(0.28503, -0.256239, 0.41171),
	float3(0.463272, 0.286629, 0.279963),
	float3(-0.373131, 0.539849, 0.0),
	float3(-0.614384, -0.272085, 0.236977),
	float3(-0.557678, 0.213777, 0.474026),
	float3(-0.16247, 0.597075, 0.536149),
	float3(-0.695881, 0.457973, 0.267647),
	float3(0.686225, -0.251616, 0.587104),
	float3(0.343937, -0.927587, 0.145913)
);

float rnd(vec2 x)
{
	int n = int(x.x * 40.0 + x.y * 6400.0);
	n = (n << 13) ^ n;
	return 1.0 - float((n * (n * n * 15731 + 789221) + \
		1376312589) & 0x7fffffff) / 1073741824.0;
}

float random(in float min, in float max)
{
	return lerp(min,max, rnd(gl_FragCoord.xy*F_time)); //
}
/*
void CreateKernel(out float3 kernel[kernelSize])
{
	for (int i = 0; i < kernelSize; ++i) {
		kernel[i] = vec3(
			random(-1.0f, 1.0f),
			random(-1.0f, 1.0f),
			random(0.0f, 1.0f));
			kernel[i] = normalize(kernel[i]);

			//accelerating interpolation function for scale 
			float scale = float(i) / float(kernelSize);
			scale = lerp(0.1f, 1.0f, scale * scale);
			kernel[i] *= scale;
	}
}
*/
/*
void CreateNoiseTex(out float3 noise[noiseSize*noiseSize])
{
	for (int i = 0; i < noiseSize*noiseSize; ++i) {
		noise[i] = vec3(
			random(-1.0f, 1.0f),
			random(-1.0f, 1.0f),
			0.0f
		);
		noise[i] = normalize(noise[i]);
	}
}*/

#define DEPTH_SCALE 0.001
float3 GetPosition(in float2 inVPos, out float3 normal)
{
	float2 screenuv = inVPos / V_viewportpixelsize.xy;

	RetrieveGBufferNormal(normal.xyz, screenuv);
	vec3 p;
	RetrieveZBufferViewPos(p, screenuv);
	p *= DEPTH_SCALE;
	return p;
}

void main()
{	
	
	float2 inVPos = gl_FragCoord.xy;

	/*float3 Kernel[kernelSize];
	CreateKernel(Kernel);
	float3 noise[noiseSize*noiseSize];
	CreateNoiseTex(noise);
	*/

	//get View Space Position & Normal
	float3 normal;
	CONST float3 origin = GetPosition(inVPos, normal);
	if (origin.z > U_ssao_clipfar*DEPTH_SCALE) {
		OUT_Color.r = 1;
		return;
	}
	//create Random Rotation around Normal
	//int nc = ((int)(gl_FragCoord.x / V_viewportpixelsize.x) % 4) * 4 + (gl_FragCoord.y / V_viewportpixelsize.y) % 4;
	//int nc = (int(gl_FragCoord.x / V_viewportpixelsize.x) % 4) * 4 + int(gl_FragCoord.y / V_viewportpixelsize.y) % 4;
	int nc = (int(gl_FragCoord.x) % 4)  + (int(gl_FragCoord.y) % 4) * 4;
	vec3 rvec = noise[nc]; // texture(uTexRandom, vTexcoord * uNoiseScale).xyz * 2.0 - 1.0;
	vec3 tangent = normalize(rvec - normal * dot(rvec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 tbn = mat3(tangent, bitangent, normal);
	
	//params
	//float uRadius = (1.0f / V_viewportpixelsize.x);//0.025f;
	float uRadius = (U_ssao_sampleradius / V_viewportpixelsize.x)*0.0125f;//0.025f;
	uRadius *= max(origin.z/(5.0f*DEPTH_SCALE),1.0f);
	//do the actual occluseion checks
	float occlusion = 0.0;
	for (int i = 0; i < kernelSize; ++i) {
		// get sample position:
		vec3 newsample = tbn * Kernel[i];
		newsample = newsample * uRadius + origin;

		// project sample position:
		vec3 offset = clip2uv(Project(newsample));

		if (abs(length(offset.xy - inVPos / V_viewportpixelsize.xy)) <= length(1.0f / V_viewportpixelsize.xy)) { // TODO optimize check
			continue; // ignore if we're sampling within the same pixel
		}
		// get sample depth:
		vec3 p2;
		RetrieveZBufferViewPos(p2, offset.xy); /// V_viewportpixelsize.xy
		p2 *= DEPTH_SCALE;
		CONST float sampleDepth = p2.z;// texture(uTexLinearDepth, offset.xy).r;

		CONST float temp = abs(origin.z - sampleDepth);
		CONST float d = temp * U_ssao_scale;
		CONST float3 v = normalize(p2-origin);
		// range check & accumulate:
		CONST float rangeCheck = 1.0f;
		if (temp >= 1.5f * uRadius) {
			// if the occluding surface is "too far in front of or behind where we would expect it", ignore it since it is likely not actually occluding e.g. it is a character running 3m front of us with a station wall 200m away
			rangeCheck = 0.0f;
		}
		rangeCheck *= saturate(dot(normal, v) - U_ssao_bias); // scale depending on sample-normal incidence
		rangeCheck *= 1.0f / (1.0f + d);
		occlusion += (sampleDepth <= newsample.z ? 1.0f : 0.0f) * rangeCheck;
	}

	occlusion = 1.0 - (occlusion / kernelSize)*U_ssao_intensity;

	OUT_Color.r = pow(occlusion,2);// pow(occlusion, 4);//saturate(ao);
}

