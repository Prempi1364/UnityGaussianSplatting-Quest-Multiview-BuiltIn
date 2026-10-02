// SPDX-License-Identifier: MIT
// Stub implementation of AMD FidelityFX Parallel Sort for GaussianSplatting.
// This file provides minimal kernel bodies so that SplatUtilities_FidelityFX.compute compiles.
// The project uses DeviceRadixSort at runtime; these FidelityFX kernels are not dispatched.

// ---- Buffers expected by FidelityFX Parallel Sort ----
RWStructuredBuffer<uint> rw_source_keys;
RWStructuredBuffer<uint> rw_dest_keys;
RWStructuredBuffer<uint> rw_source_payloads;
RWStructuredBuffer<uint> rw_dest_payloads;
RWStructuredBuffer<uint> rw_sum_table;
RWStructuredBuffer<uint> rw_reduce_table;

cbuffer FFX_ParallelSortCB : register(b1)
{
    uint NumKeys;
    int NumBlocksPerThreadGroup;
    uint NumThreadGroups;
    uint NumThreadGroupsWithAdditionalBlocks;
    uint NumReduceThreadgroupPerBin;
    uint NumScanValues;
    uint ShiftBit;
    uint Padding;
};

// ---- Kernel implementations (stubs) ----

[numthreads(GROUP_SIZE, 1, 1)]
void FfxParallelSortCount(uint3 id : SV_DispatchThreadID)
{
    // Stub: not used at runtime
}

[numthreads(GROUP_SIZE, 1, 1)]
void FfxParallelSortReduce(uint3 id : SV_DispatchThreadID)
{
    // Stub: not used at runtime
}

[numthreads(GROUP_SIZE, 1, 1)]
void FfxParallelSortScan(uint3 id : SV_DispatchThreadID)
{
    // Stub: not used at runtime
}

[numthreads(GROUP_SIZE, 1, 1)]
void FfxParallelSortScanAdd(uint3 id : SV_DispatchThreadID)
{
    // Stub: not used at runtime
}

[numthreads(GROUP_SIZE, 1, 1)]
void FfxParallelSortScatter(uint3 id : SV_DispatchThreadID)
{
    // Stub: not used at runtime
}
