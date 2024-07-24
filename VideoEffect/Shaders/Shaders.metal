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
constant float RAD2DEG = 57.29577951308232;

float3 rotateXY(float3 p, float2 angle) {
    float2 c = cos(angle), s = sin(angle);
    p = float3(p.x, c.x * p.y + s.x * p.z, -s.x * p.y + c.x * p.z);
    return float3(c.y * p.x + s.y * p.z, p.y, -s.y * p.x + c.y * p.z);
}

//float3 rotateByQuaternion(float3 point, float4 q) {
//    float3 u = float3(q.x, q.y, q.z);
//    float s = q.w;
//
//    return 2.0 * dot(u, point) * u
//         + (s*s - dot(u, u)) * point
//         + 2.0 * s * cross(u, point);
//}

float3 rotateByQuaternion(float3 v, float4 q) {
    float3 qv = float3(q.x, q.y, q.z);
    float3 t = 2.0 * cross(qv, v);
    return v + q.w * t + cross(qv, t);
}

// Function to create a rotation matrix for heading
float3x3 createHeadingMatrix(float heading) {
    float cosHeading = cos(heading);
    float sinHeading = sin(heading);

//    return float3x3(float3(cosHeading, sinHeading, 0),
//                    float3(-sinHeading, cosHeading, 0),
//                    float3(0, 0, 1));
    return float3x3(float3(cosHeading, 0, -sinHeading),
                    float3(0, 1, 0),
                    float3(sinHeading, 0, cosHeading));

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
//    float3 rd = camDir;
    
//    const auto ramp = sin(time / 10.0) * 0.5 + 0.5;
//    float2 camRot = ramp * float2(2.0 * PI, PI);
//    float3 rd = normalize(rotateXY(camDir, camRot.yx));
//    float4 invertedQuaternion = float4(motionData.quaternion.x, -motionData.quaternion.y, motionData.quaternion.z, motionData.quaternion.w);

    
    float3 camDir2 = rotateByQuaternion(camDir, motionData.quaternion);
//    float3 camDir2 = rotateByQuaternion(camDir, invertedQuaternion);
    float3 rd = camDir2;
    
//    float4 landscapeLeftQuaternion = float4(0.0, 0.0, sin(PI / 4), cos(PI / 4));
//    float3 camDir3 = rotateByQuaternion(camDir2, landscapeLeftQuaternion);
//        float3 rd = camDir3;

//    float3x3 headingMatrix = createHeadingMatrix(motionData.heading * DEG2RAD);
//    float3 camDir3 = headingMatrix * camDir2;

    
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
