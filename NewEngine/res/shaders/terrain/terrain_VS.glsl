#version 430

layout (location = 0) in vec2 position0;

out vec2 mapCoord_TC;

uniform vec3 cameraPosition;
uniform mat4 localMatrix;
uniform mat4 worldMatrix;
uniform float scaleY;

uniform int lod;
uniform vec2 index;
uniform float gap;
uniform vec2 location;
uniform int lod_morphing_area[8];
uniform sampler2D heightmap;

float morphLatitude(vec2 position){
	
	vec2 frac = position - location;
	
	if(index == vec2(0,0)){
		float morph = frac.x - frac.y;
		if(morph > 0){
			return morph;
		}
		
	}
	else if(index == vec2(1,0)){
		float morph = gap - frac.x - frac.y;
		if(morph > 0){
			return morph;
		}
	}
	else if(index == vec2(0,1)){
		float morph = frac.x + frac.y - gap;
		if(morph > 0){
			return -morph;
		}
	}
	else if(index == vec2(1,1)){
		float morph = frac.y - frac.x;
		if(morph > 0){
			return -morph;
		}
	}
	return 0;
}

float morphLongitude(vec2 position){
	
	vec2 frac = position - location;
	
	if(index == vec2(0,0)){
		float morph = frac.y - frac.x;
		if(morph > 0){
			return -morph;
		}
	}
	else if(index == vec2(1,0)){
		float morph = frac.y - (gap - frac.x);
		if(morph > 0){
			return morph;
		}
	}
	else if(index == vec2(0,1)){
		float morph = gap - frac.y - frac.x;
		if(morph > 0){
			return -morph;
		}
	}
	else if(index == vec2(1,1)){
		float morph = frac.x - frac.y;
		if(morph > 0){
			return morph;
		}
	}
	return 0;
}

vec2 morph(vec2 localPosition, float height, int morph_area){
	
	vec2 morphing = vec2(0,0);
	
	vec2 fixPointLatitude = vec2(0,0);
	vec2 fisPointLongitude = vec2(0,0);
	float distLatitude;
	float distLongitude;
	
	if(index == vec2(0,0)){
		fixPointLatitude = location + vec2(gap, 0);
		fisPointLongitude = location + vec2(0, gap);
	}
	else if(index == vec2(1,0)){
		fixPointLatitude = location;
		fisPointLongitude = location + vec2(gap, gap);
	}
	else if(index == vec2(0,1)){
		fixPointLatitude = location + vec2(gap, gap);
		fisPointLongitude = location;
	}
	else if(index == vec2(1,1)){
		fixPointLatitude = location + vec2(0, gap);
		fisPointLongitude = location + vec2(gap, 0);
	}
	
	float planarFactor = height;
	/*
	if(cameraPosition.y > abs(scaleY)){
		planarFactor = 1;
	}else{
		planarFactor = cameraPosition.y / abs(scaleY);
	}
*/
	distLatitude = length(cameraPosition - (worldMatrix * 
					vec4(fixPointLatitude.x, planarFactor, fixPointLatitude.y, 1)).xyz);
					
	distLongitude = length(cameraPosition - (worldMatrix *
					vec4(fisPointLongitude.x, planarFactor, fisPointLongitude.y, 1)).xyz);
					
	if(distLatitude > morph_area){
		morphing.x = morphLatitude(localPosition.xy);
	}
	if(distLongitude > morph_area){
		morphing.y = morphLongitude(localPosition.xy);
	}
	
	return morphing;
}

void main(){
	
	vec2 localPosition = (localMatrix * vec4(position0.x, 0, position0.y, 1)).xz;
	
	float height = texture(heightmap, localPosition).r;
	
	if(lod > 0){
		localPosition += morph(localPosition, height, lod_morphing_area[lod - 1]);
	}
	
	height = texture(heightmap, localPosition).r;
	
	mapCoord_TC = localPosition;
	vec4 worldPosition = worldMatrix * vec4(localPosition.x, height, localPosition.y, 1);
	gl_Position = worldPosition;	
}