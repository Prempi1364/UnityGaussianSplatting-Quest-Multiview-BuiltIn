# Gaussian Splatting for Quest Multiview — Built-in Render Pipeline

An adaptation of [Aras Pranckevičius' UnityGaussianSplatting](https://github.com/aras-p/UnityGaussianSplatting) for **Meta Quest 3, Vulkan, OpenXR and Unity's Built-in Render Pipeline**.

[Deutsche Beschreibung / German documentation](README.de.md)

The project stays in **single-pass multiview**. Gaussian splats are rendered and composited separately for each eye, while other compatible meshes retain their normal multiview rendering path.

## Supported configuration

This version is exclusively for **Quest 3 with the Built-in Render Pipeline, Vulkan/OpenXR and single-pass multiview**. The original Windows/desktop workflows and other rendering modes no longer work with this adaptation. Use the original Aras package for those configurations. URP and HDRP are not included.

Support for additional configurations may be added later; there is currently no timeline.

## How it works

The renderer draws splats into the corresponding eye slice of a `Texture2DArray`, then composites the result into that eye's XR camera image. View and projection data are calculated separately for each eye. A correction to the projected ellipse axes addresses the observed artifact where splats rotate with head movement.

This splat rendering path resembles multipass and requires draw and composite calls for both eyes. The global XR setting stays at single-pass multiview. Any performance improvement depends on the scene.

## Installation

A Unity 6 Quest/OpenXR project configured for **Built-in**, **Vulkan** and **Single Pass Instanced/Multiview** is required.

1. Remove an existing Aras Gaussian package to avoid duplicate classes and assemblies.
2. Extract the package folder outside `Assets` and `Packages`. Select **Window → Package Manager → + → Add package from disk** and choose its `package.json`.
3. Package Manager resolves **Burst 1.8.29**, **Collections 2.6.7** and **Mathematics 1.3.2**. Configure XR SDKs and XR settings in the target project.
4. Import PLY/SPZ data through **Tools → Gaussian Splats → Create GaussianSplatAsset**. Save the generated files under `Assets`.
5. Add `GaussianSplatRenderer` to a GameObject and assign the generated asset. **Reset** loads the packaged shaders. If needed, assign a valid asset and use **Resources → Fix Resources** to repair the shader assignments.
6. Use **DeviceRadixSort**. The included FidelityFX sorting kernels are placeholders and do not work as an alternative sorter.
7. On Quest, check both eyes, head movement, depth and occlusion against meshes, and interactions with transparent objects.

## Apple SHARP PLY compatibility

The importer supports binary little-endian Gaussian PLY files from [Apple SHARP](https://github.com/apple-aiml-research/ml-sharp) without higher-order SH coefficients (`f_rest_*`). Missing optional attributes, such as normals or higher-order SH coefficients, are filled with zeros. Position, color, opacity, scale and rotation are required.

When the float attribute `f_rest_0` is absent, the coordinate and rotation conversion intended for SHARP is applied. Files from other PLY exporters without higher-order SH coefficients may require a different conversion. SHARP compatibility in the standalone package has not yet been confirmed by a fresh import and visual test.

Apple code, model weights, inference software and sample data are not included. Apple's [model license](https://github.com/apple-aiml-research/ml-sharp/blob/main/LICENSE_MODEL) applies independently of the importer's MIT license: it permits model use for non-commercial scientific research and excludes commercial product development. The import feature does not change those terms. This project is independent of Apple.

## Package contents

The package contains the renderer, shaders, importer, editor tools, Unity metadata, package description and license notices. Sample data, models, generated GaussianSplatAssets, scenes, prefabs, materials, images and project-specific game content are not included.

All 77 files are text files. `package.json` contains package metadata and Unity dependencies. `RELEASE_CONTENTS.json` contains the package identifier, version, content description and complete file list with sizes and SHA-256 hashes. Neither JSON file contains private project information. Credentials, keys, project settings and accompanying SHARP scene JSON files are not included.

## Validation status

- The C# assemblies compiled successfully against **Unity 6000.0.80f1**, with warnings.
- Earlier Quest tests of the renderer adaptation showed correct stereo rendering and stable splats during head movement.
- A fresh integration and headset test of the standalone package is pending. Unity import, shader compilation, playmode and debug views have not been fully checked for this package.

The package is experimental and should be tested in the target project.

Related Quest multiview implementations for URP already exist, including [Aras PR #225](https://github.com/aras-p/UnityGaussianSplatting/pull/225). This adaptation focuses on the Built-in Render Pipeline.

## Credits and license

- Original Unity renderer: **Aras Pranckevičius**.
- Earlier VR contributions: **Constantin Kleinbeck** (GitHub: **ninjamode**).
- Built-in Quest multiview and importer adaptations: **Prempi**.

The code is **MIT licensed**, including the license's warranty and liability disclaimer to the extent permitted by applicable law. The package is provided as-is, without warranty. Original copyright and license notices are retained; see [LICENSE.md](LICENSE.md) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Rights to imported models and images are separate.
