# Gaussian Splatting for Quest Multiview — Built-in Render Pipeline

Prempi's source-only fork of [Aras Pranckevičius' UnityGaussianSplatting](https://github.com/aras-p/UnityGaussianSplatting).

[Deutsche Beschreibung / German documentation](README.de.md)

The Unity project stays in **single-pass multiview**. Gaussian splats use a separate draw and composite for each eye, while other compatible scene meshes retain their normal multiview rendering path. This package targets **Meta Quest 3, Vulkan, OpenXR and Unity's Built-in Render Pipeline**.

## Supported configuration only

**This version is specifically for Meta Quest 3, Vulkan/OpenXR, the Built-in Render Pipeline and single-pass multiview. It is not a drop-in replacement for all configurations supported by the original Aras importer. Normal Windows/desktop rendering and other rendering modes are not supported by this release; use the original upstream package for those workflows.** The maintainer reports that those original workflows no longer work with this adapted version. A future revision may restore broader compatibility, but no fix or release date is promised.

## What the fork changes

- Detects stereo texture-array targets in the Built-in camera callback.
- Renders splats into the corresponding eye slice of an intermediate `Texture2DArray`, then composites that slice into the XR camera target.
- Supplies explicit per-eye view and projection data.
- Corrects the projected splat ellipse axes from the CPU projection basis to the GPU projection basis, addressing the rotating-splat artifact seen in the target configuration.

The splat path is similar to multipass; it does **not** turn splats into a native single-draw multiview implementation. It does not switch the project's global XR mode. It still incurs per-eye splat drawing and compositing costs; there is no universal FPS or performance guarantee.

## Requirements and installation

- Unity 6. The source export was checked with **6000.0.80f1**.
- Built-in Render Pipeline. This export deliberately omits URP and HDRP integration files.
- Burst **1.8.29**, Collections **2.6.7** and Mathematics **1.3.2**, declared in `package.json`. Unity Package Manager resolves these separately; they are not bundled.
- An existing Android/OpenXR Quest project configured for Vulkan and single-pass instanced/multiview rendering. XR configuration belongs to the receiving project; this package includes no project settings or XR SDK.

1. Extract this directory outside your project's `Assets` and `Packages` folders. Keep it as a separate source repository if you publish a fork.
2. In Unity, select **Window → Package Manager → + → Add package from disk** and select this directory's `package.json`.
3. Remove an existing Aras Gaussian package before installing this fork to avoid duplicate `GaussianSplatting` assemblies/types. Existing `.meta` GUIDs are retained for the included source files.
4. Provide your own Gaussian PLY or SPZ file. Select **Tools → Gaussian Splats → Create GaussianSplatAsset**, choose compression and an output directory under `Assets`, and create your own data asset.
5. Add `GaussianSplatRenderer` to a GameObject and assign your generated asset. The renderer's Reset method loads the packaged shaders. If necessary, expand **Resources** and use **Fix Resources** after assigning a valid asset.
6. Use **DeviceRadixSort**. The retained FidelityFX compatibility implementation contains stub sorting kernels and is not a functioning alternative sorter in this export.
7. Build and validate on your own Quest 3, including both eyes, head motion, occlusion against meshes and transparent-object interactions.

No example scene, prefab, material, image, scan, PLY, SPZ, generated GaussianSplatAsset, training output, game script, project configuration, login data or signing key is included. All payload files are text source, text metadata or documentation. `RELEASE_CONTENTS.json` lists the files and their SHA-256 hashes.

## Validation and limitations

The source project's existing Quest test record reports correct stereo depth, stable composition and elimination of rotating splat ellipses for this approach. That is a historical observation, **not a new test of this isolated package**.

This release receives a source-content audit and separate C# compilation checks against the installed Unity assemblies. Packaging removes the game's fog/far-clip component and its hooks, project-specific shader paths, optional SRP integrations, demo tools and toolbar images. The rendering fix itself is retained. No new Unity import, shader compilation, playmode run, APK build or headset test is performed during packaging. Validate the isolated package in the receiving project before production use. Built-in debug rendering and untested XR configurations may have different limitations from the main splat path.

There are related public Quest multiview implementations for URP, including [Aras PR #225](https://github.com/aras-p/UnityGaussianSplatting/pull/225). This fork claims a specific Built-in integration, not the invention of per-eye rendering or the first Gaussian multiview renderer.

## Apple SHARP PLY compatibility

The importer retains Prempi's adaptation for binary little-endian Gaussian PLY files without higher-order spherical-harmonic properties. Missing attributes are zero-filled; when `f_rest_0` is absent, the importer applies the SHARP coordinate and quaternion conversion. This is a format heuristic, so other degree-zero PLY exporters may need a different coordinate conversion. No new SHARP-file import or visual test is claimed for this isolated release.

This is file-format compatibility only. No Apple implementation, model weights, inference code, generated PLY, images or accompanying scene JSON is distributed or downloaded. Package JSON contains only package metadata/dependencies; the release manifest contains only package-relative filenames, sizes and hashes. Import compatibility does not grant rights to SHARP models or their outputs. Apple's [model license](https://github.com/apple-aiml-research/ml-sharp/blob/main/LICENSE_MODEL) restricts model use to non-commercial scientific research and excludes commercial product development. Check applicable model, output and image rights separately. This project is independent and is not endorsed by Apple.

## Attribution and license

Original Unity implementation: **Aras Pranckevičius**. Built-in Quest multiview modifications and this source release: **Prempi**. Existing upstream VR work by **ninjamode** is acknowledged. See [LICENSE.md](LICENSE.md) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

The renderer code is MIT licensed. A model's data rights and the license of the software used to train or capture it are separate from the renderer license. This repository distributes no models or training software.
