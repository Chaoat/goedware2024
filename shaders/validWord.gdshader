shader_type canvas_item;

uniform float splits = 2.0;

float edgeDist(float edge) {
	return ceil(-abs(edge - 0.4) + 0.02);
}

void fragment() {
	float edgeRatio = (4.0*splits + 4.0)/(4.0*splits);
	
	vec2 stretchedUV = vec2(splits*(UV.x - 0.5), UV.y);
	float dist = 1.0;
	float angle = 0.0;
	for (float i = 0.0; i<splits; i++)
	{
		vec2 tempCenter = vec2((i + 0.5 - 0.5*splits)/(edgeRatio*splits), 0.5);
		tempCenter.x = splits*tempCenter.x;
		float newDist = sqrt((pow(stretchedUV.x - tempCenter.x, 2))/sqrt(splits) + pow(stretchedUV.y - tempCenter.y, 2));
		if (newDist < dist)
		{
			dist = newDist;
			angle = (2.0*mod(i, 2) - 1.0)*atan(stretchedUV.y - tempCenter.y, stretchedUV.x - tempCenter.x);
		}
	}
	
	dist = dist - 0.04*abs(sin(2.0*angle));
	COLOR = edgeDist(dist - 0.06*sin(10.0*(angle + TIME))) * vec4(0.66, 0.33, 1, 1);
	COLOR.a = COLOR.a + 0.2;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
