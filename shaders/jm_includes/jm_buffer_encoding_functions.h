/////////////////////////// JON MOD UTIL FUNCTIONS //////////////////////
//Included in the start of gbuffer_access.h, that is included most anywhere
void PackMetalSubsurface(inout float Metal, in float Subsurface)
{
	#ifdef JM_COMPARE_VANILLA_SPLIT_SCREEN
		if(GetFragUV().x > 0.5)
		{		
	#endif
			//Metal and Subsurface are natureally mutually exclusice, so we can pack both in metal
		//	Subsurface *= (1.0 - saturate(Metal * 256.0 - 4.0));//DDS compression could mess worst case 4 rbg scale steps, so makes sure to nix very low metal!
			const float dds_bias = -4.0/256.0;
			const float dds_boost = 1.0 / dds_bias;
			Metal = saturate(Metal * dds_boost + dds_bias);
			Metal = (Metal * 0.5) + (0.5 - Subsurface * 0.5);
	#ifdef JM_COMPARE_VANILLA_SPLIT_SCREEN
		}
	#endif

}
void PackMetal(inout float Metal)
{
	#ifdef JM_ENABLE_SUBSURFACE_GBUFFER_PACKING
		//Metal and Subsurface are natureally mutually exclusice, so we can pack both in metal
		#ifdef JM_COMPARE_VANILLA_SPLIT_SCREEN
			if(GetFragUV().x > 0.5)
		#endif
			Metal = (Metal * 0.5) + 0.5;		
	#endif
}

void UnpackMetalSubsurface(inout float Metal, inout float Subsurface)
{
	#ifdef JM_ENABLE_SUBSURFACE_GBUFFER_PACKING
		#ifdef JM_COMPARE_VANILLA_SPLIT_SCREEN
			if(GetFragUV().x > 0.5)
			{		
		#endif
			//Metal and Subsurface are natureally mutually exclusice, so we can pack both in metal
			Subsurface = saturate(1.0 - Metal * 2.0);
			Metal = saturate(Metal * 2.0 - 1.0);
		#ifdef JM_COMPARE_VANILLA_SPLIT_SCREEN
			}
		#endif
	#endif
}
void MetalStrict(inout float Metal)
{
	#ifdef JM_ENFORCE_STRICT_METALLIC
		#ifdef JM_COMPARE_VANILLA_SPLIT_SCREEN
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
	#ifdef JM_ROUGHNESS_REMAP
		#ifdef JM_COMPARE_VANILLA_SPLIT_SCREEN
			if(GetFragUV().x > 0.5)
			{		
				Smooth = 1.0 - pow2((1.0 - Smooth) * (1.0 - JM_ROUGHNESS_REMAP_PRE_SQUARE_RANGE) + JM_ROUGHNESS_REMAP_PRE_SQUARE_RANGE);
			}
			else
			{
				Smooth = Smooth;
			}
		#else
			Smooth = 1.0 - pow2((1.0 - Smooth) * (1.0 - JM_ROUGHNESS_REMAP_PRE_SQUARE_RANGE) + JM_ROUGHNESS_REMAP_PRE_SQUARE_RANGE);
		#endif
	#endif
}
void get_subdermal_roughness(	inout vec3 cspec, 
								inout float roughness, 
								out float roughness_epidermal, 
								in float subsurface_mask)
{
	roughness_epidermal = clamp(roughness + JM_SUBSURFACE_EPIDERMAL_ROUGHNESS, 0.04, 1.0);
//	cspec *= ((1.0 - subsurface_mask) + subsurface_mask);
	roughness = clamp(roughness + JM_SUBSURFACE_SUBDERMAL_ROUGHNESS * subsurface_mask, 0.04, 1.0);//we're baking the subdermal roughness into the regular one
}

//buffers is 16161616, game's "decals" never blends on subsurface surfaces, we should be safe :P
vec3 bit_pack_albedo_normal(in vec3 albedo, in vec3 normal, in float subsurface)
{
	const float scale = 128.0;
	const float scale_bit_pack = 1.0 / scale;
	
	//assumes the normal to be normalized!
	return subsurface > 0.0 ? (floor(albedo * scale) + (normal * 0.5 + 0.5) * (1.0 - scale_bit_pack)) * scale_bit_pack : albedo;
}
void bit_unpack_albedo_normal(inout vec3 albedo, inout vec3 subsurface_normal, in float subsurface_mask, in float subsurface)
{
	const float scale = 128.0;
	const float scale_bit_pack = 1.0 / scale;
	const float scale_normal = 1.0 / (1.0 - scale_bit_pack);

	//assumes subsurface_normal is passed in defined as the regular normal, to avoid NaN's, if it was 0!
	if(subsurface_mask > 0)
	{
		subsurface_normal = normalize(mix(subsurface_normal, (albedo * scale - floor(albedo * scale)) * scale_normal * 2.0 - 1.0, subsurface));
		albedo = floor(albedo * scale) * scale_bit_pack;
	}
}

void get_colors(in vec3 albedo, 
				in float metalness, 
				in float roughness,
				out vec3 cspec, 
				out vec3 cdiff, 
				out vec3 csub,
				inout vec3 nsub,
				inout float subsurface, 
				inout float roughness_epidermal, 
				inout float subsurface_mask)
{
	UnpackMetalSubsurface(metalness, subsurface);
	subsurface_mask = min(1.0, ceil(max(0.0, subsurface - 0.001)));
	bit_unpack_albedo_normal(albedo, nsub, subsurface_mask, subsurface);
	#ifdef JM_DEBUG_GREY_WORLD
		albedo = vec3(0.5);
	#endif
    //subsurface *= 1.0;
	cdiff = albedo * (1.0 - metalness);
	csub = JM_SUBSURFACE_SCATTER_RADIUS_HUMAN * subsurface;//TODO we could bitpack different things?
//	cdiff *= (1.0 - subsurface * subsurface_mask);
    cspec = mix(vec3(mix(0.04, JM_SUBSURFACE_EPIDERMAL_F0, subsurface_mask)), albedo, metalness);
	get_subdermal_roughness(cspec, 
							roughness, 
							roughness_epidermal, 
							subsurface_mask);
	

	//cdiff = cdiff * saturate(1.0f - dot(LUM_ITU601, cspec)); // cheap luminance energy conservation why though!?
}