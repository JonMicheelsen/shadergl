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