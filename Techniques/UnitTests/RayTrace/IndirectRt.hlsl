// Unnamed technique, shader IndirectRtRayGen
/*$(ShaderResources)*/

struct Payload
{
	bool hit;
	float3 color;
};

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


/*$(_raygeneration:IndirectRtRayGen)*/
{
	uint dispatchIndex = /*$(DispatchIndex)*/;

	IndirectData d = IndirectRtData.Load<IndirectData>(dispatchIndex * sizeof(IndirectData));

	uint2 dispatchRaysIndex = DispatchRaysIndex().xy;
	if(dispatchRaysIndex.x > d.rect.w || dispatchRaysIndex.y > d.rect.h)
	{
		return;
	}
	
	uint2 px = uint2(d.rect.x, d.rect.y) + dispatchRaysIndex;
	/*
	uint2 dimensions = DispatchRaysDimensions().xy;

	float2 screenPos = (float2(px)+0.5f) / dimensions * 2.0 - 1.0;
	screenPos.y = -screenPos.y;

	float4 world = mul(float4(screenPos, 0.0f, 1), /*$(Variable:InvViewProjMtx)*/);
	world.xyz /= world.w;

	RayDesc ray;
	ray.Origin = /*$(Variable:CameraPos)*/;
	ray.TMin = 0;
	ray.TMax = 1000.0f;
	ray.Direction = normalize(world.xyz - ray.Origin);

	Payload payload = (Payload)0;

	/*$(RayTraceFn)*/(Scene,
		0,
		0xFF,
		/*$(RTHitGroupIndex:HitGroup)*/,
		1,
		/*$(RTMissIndex:IndirectRtMiss)*/,
		ray,
		payload);
	Output[px] = float4(payload.hit ? payload.color : float3(0.2f, 0.2f, 0.2f), 1.0f);
	*/

	Output[px] = d.color;
}

/*$(_miss:IndirectRtMiss)*/
{
	payload.hit = false;
}

/*$(_closesthit:IndirectRtCloasestHit)*/
{
	payload.hit = true;
}

/*$(_anyhit:IndirectRtAnyHit)*/
{
	float3 hitLocation = ObjectRayOrigin() + ObjectRayDirection() * RayTCurrent();

	float3 normal0 = SceneVertexBuffer[PrimitiveIndex()*3 + 0].Normal;
	float3 normal1 = SceneVertexBuffer[PrimitiveIndex()*3 + 1].Normal;
	float3 normal2 = SceneVertexBuffer[PrimitiveIndex()*3 + 2].Normal;
	float3 normal = normal0 + attr.barycentrics.x * (normal1 - normal0) + attr.barycentrics.y * (normal2 - normal0);
	normal = normalize(normal);
	payload.color = normal * 0.5f + 0.5f;
	payload.hit = true;
}

/*
Shader Resources:
	Count Scene (as RTScene)
	Buffer SceneVertexBuffer (as SRV)
	Texture Output (as UAV)
	Buffer IndirectRtData (as SRV)
*/
