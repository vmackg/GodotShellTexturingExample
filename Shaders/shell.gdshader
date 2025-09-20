shader_type spatial;

//But acerola! those tutorials are too good!

uniform uint uLayerIndex;
uniform uint uTotalLayers;

uniform float uDensity = 150.0f;
uniform float uShellLength = 0.05f;
uniform float uSpreadPow = 1.1f;
uniform vec3 uColor :source_color = vec3(0, 1, 0);

varying float vHeight;

void vertex() {
	vHeight = float(uLayerIndex) / float(uTotalLayers);

	float h = pow(vHeight, uSpreadPow);
	//what is happening here -> we don't want to linearly spread our meshes.
	//so, we take their pow. if spread pow > 1 -> numbers smaller than one decrease
	//thus the closer you get to the outer most layer, the further away from 1 you get,
	//thus the greater the dist betwixt layers become. and vice versa if spread pow < 1

	VERTEX += NORMAL * h * uShellLength;
}

float hash11( uint n )
{
	// integer hash copied from Hugo Elias
	n = (n << 13U) ^ n;
	n = n * (n * n * 15731U + 789221U) + 1376312589U;
	return float( n & uint(0x7fffffffU))/float(0x7fffffff);
}

void fragment() {
	vec2 uv0 = UV * uDensity;
	uvec2 uuv = uvec2(floor(uv0));

	uint seed = uuv.x + 100u * uuv.y + 1000u; //pack x & y into a single uint seed without collisions
	//formula used -> seed = x + stride * y + offset

	float v = hash11(seed);

	vec2 loc_uv = fract(uv0) * 2.0f - 1.0f;
	float loc_dist = length(loc_uv);

	bool o = loc_dist > (1.5f * (v - vHeight));

	if (o && uLayerIndex > 0u)
	{
		discard;
	}

	ALBEDO = uColor;

}

void light()
{
	float ndot = clamp(dot(NORMAL, LIGHT), 0.0f, 1.0f) * 0.5f + 0.5f;
	ndot = ndot * ndot;
	DIFFUSE_LIGHT = vHeight * ndot * uColor;
}