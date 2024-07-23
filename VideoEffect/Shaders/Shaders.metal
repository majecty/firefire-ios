//
//  Shaders.metal
//  VideoEffect
//
//  Created by 이재현 on 2021/09/24.
//

#include <metal_stdlib>
using namespace metal;

constant half3 kRec709LumaCoefficients = half3(0.2126, 0.7152, 0.0722);

constant float PI = 3.14159265;
constant float DEG2RAD = 0.01745329251994329576923690768489;

float3 rotateXY(float3 p, float2 angle) {
    float2 c = cos(angle), s = sin(angle);
    p = float3(p.x, c.x * p.y + s.x * p.z, -s.x * p.y + c.x * p.z);
    return float3(c.y * p.x + s.y * p.z, p.y, -s.y * p.x + c.y * p.z);
}

struct DeviceMotionData {
    float4 quaternion; // Quaternion (x, y, z, w)
    float heading;     // Heading in radians
};

kernel void video360Filter(
    texture2d<half, access::read> inputTexture [[texture(0)]],
    texture2d<half, access::write> outputTexture [[texture(1)]],
    constant float &time [[buffer(0)]],
    constant DeviceMotionData &motionData [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]])
{
    float hfovDegrees = 120.0;
    float vfovDegrees = 60.0;
    
    // uv from -1 ~ 1
    float2 uv = (float2)gid * 2.0 / float2(outputTexture.get_width(), outputTexture.get_height()) - 1.0;
    float2 tanFov = float2(tan(0.5 * hfovDegrees * DEG2RAD), tan(0.5 * vfovDegrees * DEG2RAD));
    float3 camDir = normalize(float3(uv * tanFov, 1.0));
    
    const auto ramp = sin(time / 10.0) * 0.5 + 0.5;
    float2 camRot = ramp * float2(2.0 * PI, PI);
    
    float3 rd = normalize(rotateXY(camDir, camRot.yx));
    float2 texCoord = float2(atan2(rd.z, rd.x) + PI, acos(-rd.y)) / float2(2.0 * PI , PI);
    // uint2 형변환 주의!!!!
    half4 fragColor = inputTexture.read(uint2(texCoord * float2(inputTexture.get_width(), inputTexture.get_height())));
    outputTexture.write(fragColor, gid);
}


kernel void grayscaleAnimationFilter(texture2d<half, access::read> inputTexture [[texture(0)]],
                                     texture2d<half, access::write> outputTexture [[texture(1)]],
                                     constant float &time [[buffer(0)]],
                                     uint2 gid [[thread_position_in_grid]])
{
    const half4 inputColor = inputTexture.read(gid);
    
    // Luminance
    const half luminanceColor = dot(inputColor.rgb, kRec709LumaCoefficients);
    
    const auto ramp = sin(time * 2.0) * 0.5 + 0.5;
    
    const half4 outputColor = mix(inputColor, luminanceColor, ramp);
    
    outputTexture.write(outputColor, gid);
}

kernel void pixellateAnimationFilter(texture2d<half, access::read> inputTexture [[texture(0)]],
                                     texture2d<half, access::write> outputTexture [[texture(1)]],
                                     constant float &time [[buffer(0)]],
                                     uint2 gid [[thread_position_in_grid]])
{
    const auto ramp = sin(time * 2.0) * 0.5 + 0.5;
    
    const int pixelSize = max(1, int(ramp * 64.0));
    
    const auto pixelGid = uint2((gid.x / pixelSize) * pixelSize, (gid.y / pixelSize) * pixelSize);
    
    const half4 pixelColor = inputTexture.read(pixelGid);
    
    outputTexture.write(pixelColor, gid);
}
