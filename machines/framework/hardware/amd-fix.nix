{

  # The amdgpu.sg_display=0 parameter disables scatter-gather display mode for the AMD GPU driver.
  # Scatter-gather display allows the GPU to assemble framebuffer data from non-contiguous memory
  # pages instead of requiring one large contiguous block. While this is more memory-efficient,
  # it can cause stability issues on some systems, particularly with:
  #  - Resume from suspend/hibernate
  #  - Certain memory pressure scenarios
  #  - Some RDNA2/3 GPUs (like in Framework 13/16 laptops)
  # Setting it to 0 forces the driver to use traditional contiguous memory allocation for display
  # buffers, which is slightly less efficient but more stable. The efficiency loss is purely about
  # memory allocation, not rendering performance.
  # With sg_display=0:
  #  - The driver needs to find/allocate contiguous memory blocks for display buffers
  #  - This can slightly increase memory fragmentation over time
  #  - On systems with limited RAM, it might make allocation failures more likely
  # But the display buffers are just for scanout (sending the final image to your monitor) - they're
  # not involved in the actual 3D rendering pipeline. The "cost" is basically a few extra MB of
  # memory overhead and slightly more work for the kernel's memory allocator. On a modern system
  # with 16GB+ RAM, you'd never notice it.

  # The amdgpu.runpm=0 kernel parameter disables GPU runtime power management, which is the most
  # commonly documented fix for freeze pattern on RDNA 3/3.5 laptops. Downside: slightly higher
  # idle GPU power consumption

  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "amdgpu.runpm=0"
  ];
}
