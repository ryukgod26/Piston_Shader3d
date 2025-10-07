
float piston(vec2 p, float width , float height){
p.x = abs(p.x) - width;
p.y -= height;
return length(max(p,0.0)) + min(0.0,max(p.x,p.y));

}

float piston3d(vec3 p, float width, float height){

vec2 p2 = vec2(length(p.xy),p.z);
return piston(p2,width,height);


}

vec3 erot(vec3 p, vec3 ax, float ro){
return mix(dot(p,ax)*ax,p,cos(ro))+sin(ro)*cross(ax,p);

}

vec3 palette( in float t )
{

    vec3 a = vec3(0.520, 0.608, 0.608);
    vec3 b = vec3(0.219, 0.478, 0.480);
    vec3 c = vec3(0.750, 0.539, -1.929);
    vec3 d = vec3(-1.372, -1.038, -0.705);


    return a + b*tan( 6.283185*(c*t-d) );
}

vec2 edge(vec2 p){
vec2 p2 = abs(p);
if(p2.x > p2.y) return vec2((p.x < 0.) ? -1. : 1. , 0.);
else return vec2(0.,(p.y < 0.) ? -1. : 1.);

}

float scene(vec3 p){

vec2 center = floor(p.xy) + .5;
vec2 neighbour = center + edge(p.xy - center);
float height = sin(center.y + center.x + iTime) * 2.;
float width = .3;
float cur = piston3d(p - vec3(center,0),width,height) - .03;
float next = piston3d(p- vec3(neighbour,0), width,2.) - .03;

return min(cur,next);

}

vec3 norm(vec3 p){
mat3 k = mat3(p,p,p) - mat3(0.01);
return normalize(scene(p) - vec3(scene(k[0]),scene(k[1]),scene(k[2])));


}




void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord - .5*iResolution.xy) / iResolution.y;
    vec2 mouse = (iMouse.xy - .5 * iResolution.xy) / iResolution.y;
    vec3 cam = normalize(vec3(1.5,uv));
    vec3 init = vec3(-7,0,0);
    vec3 col = vec3(0);
    
    float yrot = .5;
    float zrot = iTime * .2;
    if( iMouse.z > 0.){
    yrot = clamp(1.-4.*mouse.y,-0.,3.14/2.);
    zrot = 4.*mouse.x;
    }
    
    cam = erot(cam,vec3(0,1,0),yrot);
    init = erot(init,vec3(0,1,0),yrot);
    cam = erot(cam,vec3(0,0,1),zrot);
    init = erot(init,vec3(0,0,1),zrot);
    init.z += 1.;
    
    vec3 p = init;
    bool hit = false;
    for(int i = 0 ; i < 200 && !hit; i ++){
        float dist = scene(p);
        hit = dist*dist < 1e-6;
        p += dist*cam;
        if(distance(p,init)>50.)break;
        }
       
       
    vec3 n = norm(p);
    vec3 r = reflect(cam,n);
    float colf = length(sin(r*2.)*.5+.5)/sqrt(3.);
    colf = colf * .1 + pow(colf,6.);
    col = palette(colf);
    fragColor = hit ? vec4(col,1) : vec4(palette(0.03),1);
    fragColor = sqrt(fragColor);
    //fragColor = vec4(col,1.0);
}
