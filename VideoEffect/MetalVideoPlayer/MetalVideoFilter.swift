//
//  VideoProcessor+Filters.swift
//  VideoEffect
//
//  Created by 이재현 on 2021/09/04.
//

import AVFoundation
import MetalPerformanceShaders
import CoreImage
import CoreMotion

import simd

struct DeviceMotionData {
    var quaternion: simd_float4
    var heading: Float
}

protocol MetalVideoFilter {
    
    func process(commandBuffer: MTLCommandBuffer,
                 sourceTexture: MTLTexture,
                 destinationTexture: MTLTexture,
                 heading: Double,
                 attitudeQuaternion: CMQuaternion,
                 rollPitchYaw: SIMD3<Float>,
                 at time: CMTime) throws
}

enum MetalVideoFilters {}

extension MetalVideoFilters {
    
    struct Video360Filter: MetalVideoFilter {
        
        // shader code
        var computePipelineState: MTLComputePipelineState
        
        func process(commandBuffer: MTLCommandBuffer,
                     sourceTexture: MTLTexture,
                     destinationTexture: MTLTexture,
                     heading: Double,
                     attitudeQuaternion: CMQuaternion,
                     rollPitchYaw: SIMD3<Float>,
                     at time: CMTime) throws {
            guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
                return
            }
            
            commandEncoder.setComputePipelineState(computePipelineState)
            commandEncoder.setTexture(sourceTexture, index: 0)
            commandEncoder.setTexture(destinationTexture, index: 1)
            
            let width = computePipelineState.threadExecutionWidth
            let height = computePipelineState.maxTotalThreadsPerThreadgroup / width
            let threadsPerThreadgroup = MTLSize(width: width, height: height, depth: 1)
            
            let gridSize = MTLSize(width: sourceTexture.width, height: sourceTexture.height, depth: 1)
//            let gridSize = MTLSize(width: destinationTexture.width, height: destinationTexture.height, depth: 1)

            var time = Float(time.seconds)
            commandEncoder.setBytes(&time, length: MemoryLayout<Float>.stride, index: 0)
//            var motionData = DeviceMotionData(quaternion:
//                                                simd_float4(
//                                                    Float(attitudeQuaternion.x),
//                                                    Float(attitudeQuaternion.y),
//                                                    Float(attitudeQuaternion.z),
//                                                    Float(attitudeQuaternion.w)),
//                                  heading: Float(heading))
            var motionData = [Float](repeating: Float(0), count: 5 * 3);
//            motionData[0] = rollPitchYaw.x;
//            motionData[1] = rollPitchYaw.y;
//            motionData[2] = rollPitchYaw.z;
            motionData[0] = Float(attitudeQuaternion.x);
            motionData[1] = Float(attitudeQuaternion.y);
            motionData[2] = Float(attitudeQuaternion.z);
            motionData[3] = Float(attitudeQuaternion.w);
            motionData[4] = Float(heading);
            commandEncoder.setBytes(&motionData, length: MemoryLayout<Float>.stride * (5 + 3), index: 1)
            commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadsPerThreadgroup)
            commandEncoder.endEncoding()
        }
    }
    
    struct ComputeKernelFilter: MetalVideoFilter {
        
        var computePipelineState: MTLComputePipelineState
        
        func process(commandBuffer: MTLCommandBuffer,
                     sourceTexture: MTLTexture,
                     destinationTexture: MTLTexture,
                     heading: Double,
                     attitudeQuaternion: CMQuaternion,
                                      rollPitchYaw: SIMD3<Float>,

                     at time: CMTime) throws {

            guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
                return
            }
            
            commandEncoder.setComputePipelineState(computePipelineState)
            commandEncoder.setTexture(sourceTexture, index: 0)
            commandEncoder.setTexture(destinationTexture, index: 1)
            
            let width = computePipelineState.threadExecutionWidth
            let height = computePipelineState.maxTotalThreadsPerThreadgroup / width
            let threadsPerThreadgroup = MTLSize(width: width, height: height, depth: 1)
            
            let gridSize = MTLSize(width: sourceTexture.width, height: sourceTexture.height, depth: 1)
            
            var time = Float(time.seconds)
            commandEncoder.setBytes(&time, length: MemoryLayout<Float>.stride, index: 0)
            
            commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadsPerThreadgroup)
            commandEncoder.endEncoding()
        }
    }
    
    struct GaussianBlurFilter: MetalVideoFilter {
        
        var device: MTLDevice
        
        func process(commandBuffer: MTLCommandBuffer,
                     sourceTexture: MTLTexture,
                     destinationTexture: MTLTexture,
                     heading: Double,
                     attitudeQuaternion: CMQuaternion,
                                      rollPitchYaw: SIMD3<Float>,

                     at time: CMTime) throws {
            
            let filter = MPSImageGaussianBlur(device: device, sigma: 10.0)
            filter.edgeMode = .clamp
            
            filter.encode(commandBuffer: commandBuffer,
                          sourceTexture: sourceTexture,
                          destinationTexture: destinationTexture)
        }
    }
}
