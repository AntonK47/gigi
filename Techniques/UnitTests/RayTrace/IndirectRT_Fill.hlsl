// Unnamed technique, shader IndirectRT_Fill
/*$(ShaderResources)*/

struct Rectangle
{
	uint x;
	uint y;
	uint w;
	uint h;
};

struct IndirectData
{
	Rectangle rect;
	float4 color;
};

struct GpuVirtualAddressRange
{
	uint64_t startAddress;
	uint64_t sizeInBytes;
};

struct GpuVirtualAddressRangeAndStride
{
	uint64_t startAddress;
	uint64_t sizeInBytes;
	uint64_t strideInBytes;
};

struct DispatchRaysArgs
{
	GpuVirtualAddressRange rayGenerationRecord;
	GpuVirtualAddressRangeAndStride missShaderTable;
	GpuVirtualAddressRangeAndStride hitGroupTable;
	GpuVirtualAddressRangeAndStride callableShaderTable;
	uint width;
	uint height;
	uint depth;
};

/*$(_compute:IndirectRT_Fill)*/(uint3 DTid : SV_DispatchThreadID)
{
	if(DTid.x == 0)
	{
		const uint tileSize = 32;
		const uint outputSize = 256;
		uint outputTilesInX = outputSize /tileSize;
		uint outputDataIndex = 0;

		for(uint x = 0; x < outputTilesInX; x++)
		{
			for(uint y = 0; y < outputTilesInX; y++)
			{
				if((x + y) % 2 == 0)
				{
					DispatchRaysArgs arg = (DispatchRaysArgs)0;
					arg.rayGenerationRecord.startAddress = /*$(Variable:IndirectRtRayGen_RayGen_GpuAddress)*/;
					arg.rayGenerationRecord.sizeInBytes = 64;
					arg.missShaderTable.startAddress = /*$(Variable:IndirectRtRayGen_Miss_GpuAddress)*/;
					arg.missShaderTable.sizeInBytes = 32;
					arg.missShaderTable.strideInBytes = 32;
					arg.hitGroupTable.startAddress = /*$(Variable:IndirectRtRayGen_HitGroup_GpuAddress)*/;
					arg.hitGroupTable.sizeInBytes = 64;
					arg.hitGroupTable.strideInBytes = 32;
					arg.width = tileSize;
					arg.height = tileSize;
					arg.depth = 1;

					Rectangle rect;
					rect.w = tileSize;
					rect.h = tileSize;
					rect.x = x * tileSize;
					rect.y = y * tileSize;

					IndirectData indirectData;
					indirectData.rect = rect;
					indirectData.color = float4(0.0f, 1.0f / outputTilesInX * x, 1.0f / outputTilesInX * y, 1.0f);

					IndirectRtData.Store(outputDataIndex * sizeof(IndirectData), indirectData);
					IndirectBuffer.Store<DispatchRaysArgs>(outputDataIndex * sizeof(DispatchRaysArgs), arg);

					outputDataIndex++;
				}
			}
		}

		IndirectCount.Store<uint>(0,  outputDataIndex);
	}
}

/*
Shader Resources:
	Buffer IndirectRtData (as UAV)
	Buffer IndirectBuffer (as UAV)
	Buffer IndirectCount (as UAV)
*/
