# Gaussian Splatting für Quest Multiview — Built-in Render Pipeline

Ich habe [UnityGaussianSplatting von Aras Pranckevičius](https://github.com/aras-p/UnityGaussianSplatting) für **Meta Quest 3 mit Vulkan, OpenXR und der Built-in Render Pipeline** angepasst.

[English documentation](README.md)

Das Unity-Projekt bleibt in **Single-Pass Multiview**. Nur die Gaussian Splats werden für jedes Auge separat gezeichnet und zusammengesetzt. Andere dafür geeignete Meshes behalten ihren normalen Multiview-Renderpfad.

## Unterstützte Konfiguration

**Meine angepasste Version ist ausschließlich für Quest 3 mit der Built-in Render Pipeline, Vulkan/OpenXR und Single-Pass Multiview gedacht. Die ursprünglichen Windows-/Desktop-Abläufe und andere Rendering-Modi funktionieren mit dieser Version nicht mehr.** Für diese Konfigurationen bitte das ursprüngliche Aras-Paket verwenden. URP und HDRP sind hier ebenfalls nicht enthalten.

Möglicherweise überarbeite ich das später, um weitere Konfigurationen wieder zu unterstützen. Einen Termin dafür gibt es derzeit nicht.

## Funktionsweise

Der Renderer zeichnet die Splats in die jeweilige Augen-Schicht eines `Texture2DArray` und überlagert das Ergebnis auf dem entsprechenden XR-Kamerabild. Ansichts- und Projektionsdaten werden für jedes Auge einzeln berechnet. Außerdem habe ich die projizierten Ellipsenachsen der Splats korrigiert, um den beobachteten Fehler zu beheben, bei dem sich Splats mit der Kopfbewegung drehen.

Dieser Splat-Renderpfad ähnelt Multipass und benötigt weiterhin Zeichen- und Composite-Aufrufe für beide Augen. Die globale XR-Einstellung bleibt bei Single-Pass Multiview. Der tatsächliche Leistungsgewinn hängt von der Szene ab.

## Installation

Voraussetzung ist ein Unity-6-Projekt für Quest/OpenXR mit **Built-in**, **Vulkan** und **Single Pass Instanced/Multiview**. Für die C#-Kompilierungsprüfung habe ich die Assemblies von **Unity 6000.0.80f1** verwendet.

1. Eine bereits installierte Aras-Gaussian-Version entfernen, damit Klassen und Assemblies nicht doppelt vorkommen.
2. Den Paketordner außerhalb von `Assets` und `Packages` entpacken. Über **Window → Package Manager → + → Add package from disk** dessen `package.json` auswählen.
3. Package Manager löst **Burst 1.8.29**, **Collections 2.6.7** und **Mathematics 1.3.2** auf. Die XR-SDKs und XR-Projekteinstellungen müssen bereits im eigenen Projekt eingerichtet sein.
4. Eigene PLY-/SPZ-Daten über **Tools → Gaussian Splats → Create GaussianSplatAsset** importieren. Die erzeugten Dateien im eigenen Projekt unter `Assets` speichern.
5. `GaussianSplatRenderer` auf einem GameObject hinzufügen und das erzeugte Asset zuweisen. **Reset** lädt die Shader aus dem Paket. Falls nötig, nach Zuweisung eines gültigen Assets unter **Resources → Fix Resources** die Shader-Zuordnung reparieren.
6. **DeviceRadixSort** verwenden. Die enthaltenen FidelityFX-Sortierkerne sind Platzhalter und funktionieren nicht als alternativer Sortierer.
7. Im eigenen Projekt auf der Quest prüfen: beide Augen, Kopfbewegung, Tiefe und Verdeckung durch Meshes sowie das Zusammenspiel mit transparenten Objekten.

## Apple-SHARP-PLY-Dateien

Ich habe den PLY-Importer angepasst, damit er auch binäre Little-Endian-Gaussian-PLY-Dateien aus [Apple SHARP](https://github.com/apple-aiml-research/ml-sharp) ohne höhere SH-Koeffizienten (`f_rest_*`) einlesen kann. Fehlende optionale Attribute, etwa Normalen oder höhere SH-Koeffizienten, werden mit null gefüllt. Position, Farbe, Deckkraft, Skalierung und Rotation müssen weiterhin vorhanden sein.

Wenn das Float-Attribut `f_rest_0` fehlt, wendet der Importer die für SHARP vorgesehene Koordinaten- und Rotationsumrechnung an. Daran erkennt er den Dateityp; bei Dateien anderer PLY-Exporter ohne höhere SH-Koeffizienten kann deshalb eine andere Umrechnung nötig sein. Einen neuen SHARP-Import oder Sichttest mit dem separat veröffentlichten Paket habe ich noch nicht durchgeführt.

Das Paket enthält nur meine Anpassung zum Einlesen dieser Dateien. Apple-Code, Modellgewichte, Inferenzsoftware und Beispieldaten sind nicht enthalten. Apples [Modelllizenz](https://github.com/apple-aiml-research/ml-sharp/blob/main/LICENSE_MODEL) gilt getrennt von der MIT-Lizenz dieses Importers: Sie erlaubt die Modellnutzung für nichtkommerzielle wissenschaftliche Forschung und schließt kommerzielle Produktentwicklung aus. Die Importfunktion ändert diese Bedingungen nicht. Dieses Projekt ist unabhängig von Apple.

## Inhalt des Pakets

Enthalten sind Renderer, Shader, Importer, Editor-Werkzeuge, Unity-Metadaten, Paketbeschreibung und Lizenzhinweise — ausschließlich Textdateien. Beispieldaten, Modelle, Scans, PLY-/SPZ-Dateien, erzeugte GaussianSplatAssets, Szenen, Prefabs, Materialien, Bilder, Spielskripte, Zugangsdaten, Schlüssel und Projekteinstellungen sind nicht enthalten.

`package.json` enthält ausschließlich öffentliche Paketangaben und Unity-Abhängigkeiten. `RELEASE_CONTENTS.json` enthält die Paketkennung, Version, Inhaltsbeschreibung und paketrelative Dateinamen mit Größen und SHA-256-Prüfsummen. Keine der beiden Dateien enthält Informationen aus meinem Spielprojekt. Begleitende SHARP-Szenen-JSON-Dateien sind ebenfalls nicht enthalten.

## Was ich geprüft habe

Bei meinen früheren Quest-Tests mit dieser Renderer-Anpassung wurden beide Augen korrekt dargestellt und die Splats blieben bei Kopfbewegung stabil. Für das separat veröffentlichte Paket habe ich die Dateiinhalte kontrolliert und die C#-Assemblies erfolgreich mit Warnungen kompiliert.

Das separat veröffentlichte Paket habe ich noch nicht erneut in Unity importiert oder auf einem Headset getestet. Auch Shader-Kompilierung und Playmode wurden dafür nicht erneut geprüft. Bitte das Paket im eigenen Zielprojekt testen; die Debug-Ansichten habe ich dort ebenfalls noch nicht vollständig geprüft.

Ähnliche Quest-Multiview-Lösungen für URP gibt es bereits, etwa [Aras PR #225](https://github.com/aras-p/UnityGaussianSplatting/pull/225). Meine Anpassung konzentriert sich auf die Built-in Render Pipeline.

## Urheber und Lizenz

Der ursprüngliche Unity-Renderer stammt von **Aras Pranckevičius**. Die enthaltene frühere VR-Arbeit stammt auch von **Constantin Kleinbeck**, dessen GitHub-Nutzername **ninjamode** ist. Das ist ein Urheberhinweis, kein Rendering-Modus. Meine Built-in-Quest-Multiview- und Importer-Anpassungen veröffentliche ich als **Prempi**.

Der Code steht unter der **MIT-Lizenz**. Die ursprünglichen Urheber- und Lizenzhinweise bleiben erhalten; siehe [LICENSE.md](LICENSE.md) und [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Ich stelle dieses experimentelle Paket ohne Gewährleistung bereit. Ich gebe keine Zusage zur Fehlerfreiheit, Leistung oder Eignung für einen bestimmten Zweck. Die MIT-Lizenz enthält den Gewährleistungs- und Haftungsausschluss im rechtlich zulässigen Umfang. Die Rechte an selbst importierten Modellen und Bildern sind davon unabhängig.
