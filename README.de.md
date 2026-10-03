# Gaussian Splatting für Quest Multiview — Built-in Render Pipeline

Anpassung von [UnityGaussianSplatting von Aras Pranckevičius](https://github.com/aras-p/UnityGaussianSplatting) für **Meta Quest 3, Vulkan, OpenXR und die Built-in Render Pipeline**.

[English documentation](README.md)

Das Projekt bleibt in **Single-Pass Multiview**. Nur die Gaussian Splats werden für jedes Auge separat gerendert und zusammengesetzt. Andere dafür geeignete Meshes behalten ihren normalen Multiview-Renderpfad.

## Unterstützte Konfiguration

Diese Version ist ausschließlich für **Quest 3 mit der Built-in Render Pipeline, Vulkan/OpenXR und Single-Pass Multiview** vorgesehen. Die ursprünglichen Windows-/Desktop-Abläufe und andere Rendering-Modi funktionieren mit dieser Anpassung nicht mehr. Für diese Konfigurationen das ursprüngliche Aras-Paket verwenden. URP und HDRP sind nicht enthalten.

Eine spätere Erweiterung auf weitere Konfigurationen ist möglich; dafür gibt es derzeit keinen Zeitplan.

## Funktionsweise

Der Renderer zeichnet die Splats in die jeweilige Augen-Schicht eines `Texture2DArray` und überlagert das Ergebnis auf dem entsprechenden XR-Kamerabild. Ansichts- und Projektionsdaten werden für jedes Auge einzeln berechnet. Eine Korrektur der projizierten Ellipsenachsen behebt den beobachteten Fehler, bei dem sich Splats mit der Kopfbewegung drehen.

Dieser Splat-Renderpfad ähnelt Multipass und benötigt Zeichen- und Composite-Aufrufe für beide Augen. Die globale XR-Einstellung bleibt bei Single-Pass Multiview. Der tatsächliche Leistungsgewinn hängt von der Szene ab.

## Installation

Voraussetzung ist ein Unity-6-Projekt für Quest/OpenXR mit **Built-in**, **Vulkan** und **Single Pass Instanced/Multiview**.

1. Eine bereits installierte Aras-Gaussian-Version entfernen, damit Klassen und Assemblies nicht doppelt vorkommen.
2. Den Paketordner außerhalb von `Assets` und `Packages` entpacken. Über **Window → Package Manager → + → Add package from disk** dessen `package.json` auswählen.
3. Package Manager löst **Burst 1.8.29**, **Collections 2.6.7** und **Mathematics 1.3.2** auf. XR-SDKs und XR-Projekteinstellungen müssen im Zielprojekt eingerichtet sein.
4. Eigene PLY-/SPZ-Daten über **Tools → Gaussian Splats → Create GaussianSplatAsset** importieren. Die erzeugten Dateien unter `Assets` speichern.
5. `GaussianSplatRenderer` auf einem GameObject hinzufügen und das erzeugte Asset zuweisen. **Reset** lädt die Shader aus dem Paket. Falls nötig, nach Zuweisung eines gültigen Assets unter **Resources → Fix Resources** die Shader-Zuordnung reparieren.
6. **DeviceRadixSort** verwenden. Die enthaltenen FidelityFX-Sortierkerne sind Platzhalter und funktionieren nicht als alternativer Sortierer.
7. Auf der Quest beide Augen, Kopfbewegung, Tiefe und Verdeckung durch Meshes sowie das Zusammenspiel mit transparenten Objekten prüfen.

## Apple-SHARP-PLY-Kompatibilität

Der Importer unterstützt binäre Little-Endian-Gaussian-PLY-Dateien aus [Apple SHARP](https://github.com/apple-aiml-research/ml-sharp) ohne höhere SH-Koeffizienten (`f_rest_*`). Fehlende optionale Attribute, etwa Normalen oder höhere SH-Koeffizienten, werden mit null gefüllt. Position, Farbe, Deckkraft, Skalierung und Rotation müssen vorhanden sein.

Fehlt das Float-Attribut `f_rest_0`, wird die für SHARP vorgesehene Koordinaten- und Rotationsumrechnung angewendet. Dateien anderer PLY-Exporter ohne höhere SH-Koeffizienten können eine andere Umrechnung benötigen. Die SHARP-Kompatibilität des eigenständigen Pakets ist noch nicht durch einen erneuten Import- und Sichttest bestätigt.

Apple-Code, Modellgewichte, Inferenzsoftware und Beispieldaten sind nicht enthalten. Apples [Modelllizenz](https://github.com/apple-aiml-research/ml-sharp/blob/main/LICENSE_MODEL) gilt unabhängig von der MIT-Lizenz des Importers: Sie erlaubt die Modellnutzung für nichtkommerzielle wissenschaftliche Forschung und schließt kommerzielle Produktentwicklung aus. Die Importfunktion ändert diese Bedingungen nicht. Das Projekt ist unabhängig von Apple.

## Paketinhalt

Das Paket enthält Renderer, Shader, Importer, Editor-Werkzeuge, Unity-Metadaten, Paketbeschreibung und Lizenzhinweise. Beispieldaten, Modelle, erzeugte GaussianSplatAssets, Szenen, Prefabs, Materialien, Bilder und projektspezifische Spielinhalte sind nicht enthalten.

Alle 77 Dateien sind Textdateien. `package.json` enthält Paketangaben und Unity-Abhängigkeiten. `RELEASE_CONTENTS.json` enthält die Paketkennung, Version, Inhaltsbeschreibung und die vollständige Dateiliste mit Größen und SHA-256-Prüfsummen. Beide JSON-Dateien enthalten keine privaten Projektinformationen. Zugangsdaten, Schlüssel, Projekteinstellungen und begleitende SHARP-Szenen-JSON-Dateien sind nicht enthalten.

## Prüfstand

- Die C#-Assemblies wurden gegen **Unity 6000.0.80f1** erfolgreich kompiliert; dabei traten Warnungen auf.
- Frühere Quest-Tests der Renderer-Anpassung zeigten korrekte Stereodarstellung und stabile Splats bei Kopfbewegung.
- Ein erneuter Integrations- und Headset-Test des eigenständigen Pakets steht aus. Unity-Import, Shader-Kompilierung, Playmode und Debug-Ansichten wurden für dieses Paket noch nicht vollständig geprüft.

Das Paket ist experimentell und sollte im Zielprojekt getestet werden.

Ähnliche Quest-Multiview-Lösungen für URP gibt es bereits, etwa [Aras PR #225](https://github.com/aras-p/UnityGaussianSplatting/pull/225). Diese Anpassung konzentriert sich auf die Built-in Render Pipeline.

## Urheber und Lizenz

- Ursprünglicher Unity-Renderer: **Aras Pranckevičius**.
- Frühere VR-Beiträge: **Constantin Kleinbeck** (GitHub: **ninjamode**).
- Built-in-Quest-Multiview- und Importer-Anpassungen: **Prempi**.

Der Code steht unter der **MIT-Lizenz**, einschließlich des dort enthaltenen Gewährleistungs- und Haftungsausschlusses im rechtlich zulässigen Umfang. Das Paket wird ohne Gewährleistung bereitgestellt. Ursprüngliche Urheber- und Lizenzhinweise bleiben erhalten; siehe [LICENSE.md](LICENSE.md) und [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Rechte an importierten Modellen und Bildern sind davon unabhängig.
