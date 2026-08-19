// Unnamed technique, shader IndirectRt_Clear
/*$(ShaderResources)*/

/*$(_compute:IndirectRt_Clear)*/(uint3 DTid : SV_DispatchThreadID)
{
	RenderTarget[DTid.xy] = float4(0.8f, 0.8f, 0.8f, 1.0f);
}

/*
Shader Resources:
	Texture RenderTarget (as UAV)
*/
