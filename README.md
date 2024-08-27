## Godot-SMAA
A Godot compositor effect to implement Enhanced Subpixel Morphological Antialiasing (SMAA). Currently this implementation only supports SMAA 1x.  
**Godot compositor effects were added with Godot 4.3, so this project will not work on any prior version.**

This compositor effect uses render pipelines instead of compute pipelines so that adapting [the original SMAA shader](https://github.com/iryoku/smaa) would be simpler.

### Installing
To add Godot-SMAA to your project, copy over the SMAA folder to the root of your project. If you'd like to put it somewhere else in your project folder, then you'll need to change `SMAA_dir` in SMAA.gd.  
You'll then need to add a compositor to your WorldEnvironment node, if you don't have one already. Add an element to your array of compositor effects and change the new element's type to 'New SMAA'.

### Configuration
Basic configuration such as quality level and edge detection method can be changed through the export variables under the SMAA group in the compositor effects panel.  
More advanced configuration will require editing the `_get_smaa_parameters()` function in SMAA.gd. There you can change the associated parameters for each quality level.

**Please note that the depth edge detection method is currently broken/ineffective.** I haven't put much work into it since luma and color edge detection are significantly more capable, but I left it in just in case someone else wanted to tinker with it.

### Roadmap
I'll need to do more research to determine if SMAA S2x is possible. It will depend on if the output passed to compositor effects comes with MSAA already resolved.  
SMAA T2x interests me more though, since it would better remove the aliasing on thin specular highlights. With motion vectors being made available to compositor effects I'm reasonably confident that it's possible. The biggest hurdle is probably going to be jittering the camera correctly, since the alternative is adding a vertex shader to each and every object in your scene, and that's just unreasonable.

Maybe fix depth edge detection. A byproduct of that will be that we can use the depth buffer for predicated thresholding, which may improve performance in indoor scenes.

### License
All of the shader files (\*.glsl) and texture files (\*.dds) belong to the amazing original team that developed SMAA. All I did was modify them for use in Godot. Their MIT license can be found in LICENSE.smaa.  
SMAA.gd falls under the MIT license in LICENSE.godot-smaa. 
