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
		Rectangle r1;
		r1.x = 32;
		r1.y = 32;
		r1.w = 32;
		r1.h = 64;

		IndirectData d1;
		d1.rect = r1;
		d1.color = float4(1.0f, 0.0f, 0.0f, 1.0f);

		Rectangle r2;
		r2.x = 64;
		r2.y = 96;
		r2.w = 128;
		r2.h = 64;

		IndirectData d2;
		d2.rect = r2;
		d2.color = float4(0.0f, 1.0f, 0.0f, 1.0f);

		IndirectRtData.Store(0, d1);
		IndirectRtData.Store(sizeof(IndirectData), d2);

		DispatchRaysArgs arg1 = (DispatchRaysArgs)0;
		arg1.rayGenerationRecord.startAddress = /*$(Variable:IndirectRtRayGen_GpuAddress)*/;
		arg1.rayGenerationRecord.sizeInBytes = 64;
		arg1.width = 64;
		arg1.height = 64;
		arg1.depth = 1;

		DispatchRaysArgs arg2 = (DispatchRaysArgs)0;
		arg2.rayGenerationRecord.startAddress = /*$(Variable:IndirectRtRayGen_GpuAddress)*/;
		arg2.rayGenerationRecord.sizeInBytes = 64;
		arg2.width = 128;
		arg2.height = 128;
		arg2.depth = 1;


		IndirectBufferAndCount.Store<uint>(0, 2);
		IndirectBufferAndCount.Store<DispatchRaysArgs>(sizeof(uint), arg1);
		IndirectBufferAndCount.Store<DispatchRaysArgs>(sizeof(uint) + sizeof(DispatchRaysArgs), arg2);
	}
}

/*
Shader Resources:
	Buffer IndirectRtData (as UAV)
	Buffer IndirectBufferAndCount (as UAV)
*/
