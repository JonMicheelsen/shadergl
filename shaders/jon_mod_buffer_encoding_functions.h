/////////////////////////// JON MOD UTIL FUNCTIONS //////////////////////
//Included in the start of gbuffer_access.h, that is included most anywhere
void PackMetalSubsurface(inout float Metal, in float Subsurface)
{
	#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
		if(GetFragUV().x > 0.5)
		{		
	#endif
			//Metal and Subsurface are natureally mutually exclusice, so we can pack both in metal
		//	Subsurface *= (1.0 - saturate(Metal * 256.0 - 4.0));//DDS compression could mess worst case 4 rbg scale steps, so makes sure to nix very low metal!
			const float dds_bias = -4.0/256.0;
			const float dds_boost = 1.0 / dds_bias;
			Metal = saturate(Metal * dds_boost + dds_bias);
			Metal = (Metal * 0.5) + (0.5 - Subsurface * 0.5);
	#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
		}
	#endif

}
void PackMetal(inout float Metal)
{
	#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
		//Metal and Subsurface are natureally mutually exclusice, so we can pack both in metal
		#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
			if(GetFragUV().x > 0.5)
		#endif
			Metal = (Metal * 0.5) + 0.5;		
	#endif
}

void UnpackMetalSubsurface(inout float Metal, inout float Subsurface)
{
	#ifdef JON_MOD_ENABLE_SUBSURFACE_GBUFFER_PACKING
		#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
			if(GetFragUV().x > 0.5)
			{		
		#endif
			//Metal and Subsurface are natureally mutually exclusice, so we can pack both in metal
			Subsurface = max(0.0, 1.0 - Metal * 2.0);
			Metal = max(0.0, Metal * 2.0 - 1.0);
		#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
			}
		#endif
	#endif
}
void MetalStrict(inout float Metal)
{
	#ifdef JON_MOD_ENFORCE_STRICT_METALLIC
		#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
			if(GetFragUV().x > 0.5)
			{		
				Metal = smoothstep(0.25, 0.75, Metal);
			}
			else
			{
				Metal = Metal;
			}
		#else
			Metal = smoothstep(0.25, 0.75, Metal);
		#endif
	#endif
}
void RoughnessRemapSmoothVersion(inout float Smooth)
{
	#ifdef JON_MOD_ROUGHNESS_REMAP
		#ifdef JON_MOD_COMPARE_VANILLA_SPLIT_SCREEN
			if(GetFragUV().x > 0.5)
			{		
				Smooth = 1.0 - pow2((1.0 - Smooth) * (1.0 - JON_MOD_ROUGHNESS_REMAP_PRE_SQUARE_RANGE) + JON_MOD_ROUGHNESS_REMAP_PRE_SQUARE_RANGE);
			}
			else
			{
				Smooth = Smooth;
			}
		#else
			Smooth = 1.0 - pow2((1.0 - Smooth) * (1.0 - JON_MOD_ROUGHNESS_REMAP_PRE_SQUARE_RANGE) + JON_MOD_ROUGHNESS_REMAP_PRE_SQUARE_RANGE);
		#endif
	#endif
}
void get_subdermal_roughness(	inout vec3 cspec, 
								inout float roughness, 
								out float roughness_epidermal, 
								in float subsurface_mask)
{
	roughness_epidermal = clamp(roughness + JON_MOD_SUBSURFACE_EPIDERMAL_ROUGHNESS, 0.04, 1.0);
//	cspec *= ((1.0 - subsurface_mask) + subsurface_mask);
	roughness = clamp(roughness + JON_MOD_SUBSURFACE_SUBDERMAL_ROUGHNESS * subsurface_mask, 0.04, 1.0);//we're baking the subdermal roughness into the regular one
}
void get_colors(in vec3 albedo, 
				in float metalness, 
				in float roughness, 
				out vec3 cspec, 
				out vec3 cdiff, 
				out vec3 csub, 
				out float subsurface, 
				out float roughness_epidermal, 
				out float subsurface_mask)
{
	UnpackMetalSubsurface(metalness, subsurface);
	subsurface_mask = ceil(max(0.0, subsurface - 0.001));
	#ifdef JON_MOD_DEBUG_GREY_WORLD
		albedo = vec3(0.5);
	#endif
    cdiff = albedo * (1.0 - metalness);
	csub = (sqrt(cdiff) * JON_MOD_SUBSURFACE_EPIDERMAL_TINT) * subsurface_mask;//we could bitpack different races and etniceties 
//	cdiff *= (1.0 - subsurface);
    cspec = mix(vec3(mix(0.04, JON_MOD_SUBSURFACE_EPIDERMAL_F0, subsurface_mask)), albedo, metalness);
	get_subdermal_roughness(cspec, 
							roughness, 
							roughness_epidermal, 
							subsurface_mask);
	

	//cdiff = cdiff * saturate(1.0f - dot(LUM_ITU601, cspec)); // cheap luminance energy conservation why though!?
}