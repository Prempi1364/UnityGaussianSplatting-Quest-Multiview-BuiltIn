# Gaussian Splatting for Quest Multiview — Built-in Render Pipeline

I adapted [Aras Pranckevičius' UnityGaussianSplatting](https://github.com/aras-p/UnityGaussianSplatting) for **Meta Quest 3 with Vulkan, OpenXR and Unity's Built-in Render Pipeline**.

[Deutsche Beschreibung / German documentation](README.de.md)

The Unity project stays in **single-pass multiview**. Gaussian splats are drawn and composited separately for each eye, while other compatible meshes retain their normal multiview rendering path.

## Supported configuration

**My adapted version is exclusively for Quest 3 with the Built-in Render Pipeline, Vulkan/OpenXR and single-pass multiview. The original Windows/desktop workflows and other rendering modes no longer work with this version.** Please use the original Aras package for those configurations. URP and HDRP integrations are also not included here.

I may revise this later to support more configurations again. There is currently no schedule for that work.

## How it works

The renderer draws splats into the corresponding eye slice of a `Texture2DArray`, then composites the result into that eye's XR camera image. View and projection data are calculated separately for each eye. I also corrected the projected splat ellipse axes to address the observed artifact where splats rotated with head movement.

This splat rendering path resembles multipass and still requires draw and composite calls for both eyes. The global XR setting stays at single-pass multiview. Any performance improvement depends on the scene.

## Installation

You need a Unity 6 Quest/OpenXR project configured for **Built-in**, **Vulkan** and **Single Pass Instanced/Multiview**. I used assemblies from **Unity 6000.0.80f1** for the C# compilation checks.

1. Remove an existing Aras Gaussian package to avoid duplicate classes and assemblies.
2. Extract the package folder outside `Assets` and `Packages`. Select **Window → Package Manager → + → Add package from disk** and choose its `package.json`.
3. Package Manager resolves **Burst 1.8.29**, **Collections 2.6.7** and **Mathematics 1.3.2**. Your project must already have its XR SDKs and XR settings configured.
4. Import your own PLY/SPZ data through **Tools → Gaussian Splats → Create GaussianSplatAsset**. Save the generated files under `Assets` in your project.
5. Add `GaussianSplatRenderer` to a GameObject and assign the generated asset. **Reset** loads the packaged shaders. If needed, assign a valid asset and use **Resources → Fix Resources** to repair the shader assignments.
6. Use **DeviceRadixSort**. The included FidelityFX sorting kernels are placeholders and do not work as an alternative sorter.
7. Test on your Quest: both eyes, head movement, depth and occlusion against meshes, and interactions with transparent objects.

## Apple SHARP PLY files

I adapted the PLY importer to read binary little-endian Gaussian PLY files from [Apple SHARP](https://github.com/apple-aiml-research/ml-sharp) without higher-order SH coefficients (`f_rest_*`). Missing optional attributes, such as normals or higher-order SH coefficients, are filled with zeros. Position, color, opacity, scale and rotation are still required.

When the float attribute `f_rest_0` is absent, the importer applies the coordinate and rotation conversion intended for SHARP. It uses this attribute to identify the format, so files from other PLY exporters without higher-order SH coefficients may need a different conversion. I have not yet performed a new SHARP import or visual test with the separately published package.

The package contains only my adaptation for reading these files. It includes no Apple code, model weights, inference software or sample data. Apple's [model license](https://github.com/apple-aiml-research/ml-sharp/blob/main/LICENSE_MODEL) applies separately from this importer's MIT license: it permits model use for non-commercial scientific research and excludes commercial product development. The import feature does not change those terms. This project is independent of Apple.

## Package contents

The package contains the renderer, shaders, importer, editor tools, Unity metadata, package description and license notices — all text files. It includes no sample data, models, scans, PLY/SPZ files, generated GaussianSplatAssets, scenes, prefabs, materials, images, game scripts, credentials, keys or project settings.

`package.json` contains only public package metadata and Unity dependencies. `RELEASE_CONTENTS.json` contains the package identifier, version, content description and package-relative filenames with sizes and SHA-256 hashes. Neither file contains information from my game project. Accompanying SHARP scene JSON files are also not included.

## What I checked

In my earlier Quest tests with this renderer adaptation, both eyes rendered correctly and the splats remained stable during head movement. For the separately published package, I checked the file contents and successfully compiled the C# assemblies with warnings.

I have not yet imported the separately published package into Unity again or tested it on a headset. Shader compilation and playmode have also not been checked again for this package. Please test it in your own target project; its debug views have not been fully checked there either.

Related Quest multiview implementations for URP already exist, including [Aras PR #225](https://github.com/aras-p/UnityGaussianSplatting/pull/225). My adaptation focuses on the Built-in Render Pipeline.

## Credits and license

The original Unity renderer is by **Aras Pranckevičius**. The included earlier VR work also comes from **Constantin Kleinbeck**, whose GitHub username is **ninjamode**. This is a contributor credit, not a rendering mode. I publish my Built-in Quest multiview and importer adaptations as **Prempi**.

The code is **MIT licensed**. Original copyright and license notices are retained; see [LICENSE.md](LICENSE.md) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

I provide this experimental package as-is, without warranty. I make no promises about freedom from errors, performance or suitability for a particular purpose. The MIT license contains the warranty and liability disclaimer to the extent permitted by applicable law. Rights to models and images you import are separate.
