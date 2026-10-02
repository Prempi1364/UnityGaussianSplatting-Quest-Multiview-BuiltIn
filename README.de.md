# Gaussian Splatting für Quest Multiview — Built-in Render Pipeline

Bereinigter Quellcode-Fork von Prempi, basierend auf [UnityGaussianSplatting von Aras Pranckevičius](https://github.com/aras-p/UnityGaussianSplatting).

[English documentation](README.md)

Das Unity-Projekt bleibt in **Single Pass Multiview**. Nur die Gaussian Splats werden getrennt für beide Augen gezeichnet und zusammengesetzt. Andere dafür geeignete Meshes behalten ihren normalen Multiview-Renderpfad. Zielkonfiguration: **Meta Quest 3, Vulkan, OpenXR und Unity Built-in Render Pipeline**.

## Funktionsweise

Der Renderer erkennt Stereo-Ziele als Texture2DArray. Er berechnet die Ansichten für beide Augen, zeichnet die Splats in die jeweilige Schicht eines Zwischenpuffers und überlagert das Ergebnis auf dem entsprechenden XR-Kamerabild. Eine zusätzliche Korrektur überführt die projizierten Ellipsenachsen der Splats von der CPU- in die GPU-Projektionsbasis. Sie behebt in der Zielkonfiguration den beobachteten Fehler, bei dem sich einzelne Splats mit der Kopfbewegung drehen.

Der Splat-Pfad ähnelt Multipass und benötigt weiterhin Zeichen- und Composite-Aufrufe für beide Augen. Die globale XR-Einstellung wird nicht umgeschaltet. Eine allgemeine FPS- oder Leistungsgarantie ist damit nicht verbunden.

## Installation

1. Unity 6 und ein vorhandenes Quest/OpenXR-Projekt mit **Built-in**, **Vulkan** und **Single Pass Instanced/Multiview** verwenden. Referenz für die Quellcodeprüfung: **6000.0.80f1**. URP-/HDRP-Integrationen sind in diesem Export nicht enthalten.
2. Den Paketordner außerhalb von `Assets` und `Packages` entpacken. Über **Window → Package Manager → + → Add package from disk** dessen `package.json` auswählen. Als eigenen Fork nur diesen separaten Ordner veröffentlichen.
3. Eine bereits installierte Aras-Gaussian-Version zuvor entfernen, damit Klassen und Assemblies nicht doppelt vorkommen. Die Metadaten-GUIDs der enthaltenen Originaldateien bleiben erhalten.
4. Package Manager löst **Burst 1.8.29**, **Collections 2.6.7** und **Mathematics 1.3.2** auf. Diese Unity-Abhängigkeiten sind nicht mitgeliefert. Auch XR-SDKs und Projekteinstellungen gehören zum empfangenden Projekt.
5. Eigene PLY-/SPZ-Daten über **Tools → Gaussian Splats → Create GaussianSplatAsset** importieren. Die erzeugten Dateien im eigenen Projekt unter `Assets` speichern.
6. `GaussianSplatRenderer` auf einem GameObject hinzufügen und das selbst erzeugte Asset zuweisen. Reset lädt die Shader aus dem Paket; bei Bedarf nach Zuweisung eines gültigen Assets unter **Resources → Fix Resources** reparieren.
7. **DeviceRadixSort** verwenden. Die enthaltenen FidelityFX-Sortierkerne sind Kompatibilitäts-Platzhalter und kein funktionierender alternativer Sortierer.
8. Das isolierte Paket im eigenen Projekt auf der Quest prüfen: beide Augen, Kopfbewegung, Tiefe/Verdeckung durch Meshes und Verhalten mit transparenten Objekten.

## Umfang und Prüfstand

Enthalten sind ausschließlich Textdateien: Renderer, Shader, Importer, Editor-Werkzeuge, Unity-Quellcode-Metadaten, Paketbeschreibung und Lizenzhinweise. Keine Beispieldaten, Modelle, Scans, PLY-/SPZ-Dateien, erzeugten GaussianSplatAssets, Szenen, Prefabs, Materialien, Bilder, Spielskripte, Projektschlüssel oder Projekteinstellungen. Die vollständige Dateiliste mit SHA-256-Prüfsummen steht in `RELEASE_CONTENTS.json`.

Für den Export wurden die spielbezogene Nebel-/Sichtweitenkomponente und deren Anbindungen, feste Projektpfade, optionale SRP-Integrationen, Demo-Hilfen und Toolbar-Bilder entfernt. Die Multiview- und Achsenkorrektur bleibt erhalten. Das ursprüngliche Spielprojekt wird dabei nicht verändert.

Das vorhandene Testprotokoll des Quellprojekts berichtet für diesen Ansatz eine korrekte Darstellung auf Quest. Das ist ein früheres Ergebnis und kein neuer Lauf des isolierten Pakets. Beim Verpacken erfolgen eine Inhaltsprüfung und separate C#-Kompilierungsprüfungen gegen die installierten Unity-Assemblies. Es erfolgen kein neuer Unity-Import, keine Shader-Kompilierung, kein Playmode-Test, kein APK-Build und kein Headset-Test. Vor dem produktiven Einsatz im Zielprojekt prüfen; Debug-Ansichten und andere XR-Konfigurationen sind nicht als vollständig getestet zugesichert.

Ähnliche Quest-Multiview-Lösungen für URP existieren bereits, etwa [Aras PR #225](https://github.com/aras-p/UnityGaussianSplatting/pull/225). Dieser Fork dokumentiert die konkrete Built-in-Integration und beansprucht keine weltweite Erstimplementierung.

## Apple-SHARP-PLY-Kompatibilität

Der Importer enthält Prempis Anpassung für binäre Little-Endian-Gaussian-PLY-Dateien ohne höhere Kugelflächenfunktionen. Fehlende Attribute werden mit null gefüllt; fehlt `f_rest_0`, erfolgt die SHARP-Koordinaten- und Quaternionumrechnung. Diese Formaterkennung ist eine Heuristik: Andere PLY-Exporter mit Grad null können eine andere Koordinatenumrechnung brauchen. Ein neuer SHARP-Import oder Sichttest des isolierten Pakets wird nicht behauptet.

Enthalten ist ausschließlich die Dateiformat-Anpassung. Keine Apple-Implementierung, Modellgewichte, Inferenzsoftware, erzeugten PLY-Dateien, Bilder oder begleitenden Szenen-JSON-Dateien werden mitgeliefert oder heruntergeladen. Die Paket-JSON enthält nur Paketbeschreibung und Abhängigkeiten; das Dateimanifest enthält ausschließlich paketrelative Dateinamen, Größen und Prüfsummen. Importkompatibilität erteilt keine Rechte an SHARP-Modellen oder deren Ergebnissen. Apples [Modelllizenz](https://github.com/apple-aiml-research/ml-sharp/blob/main/LICENSE_MODEL) beschränkt die Modellnutzung auf nichtkommerzielle wissenschaftliche Forschung und schließt kommerzielle Produktentwicklung aus. Modell-, Ergebnis- und Bildrechte getrennt prüfen. Dieses Projekt ist unabhängig und wird nicht von Apple unterstützt.

## Urheber und Lizenz

Ursprünglicher Unity-Renderer: **Aras Pranckevičius**. Built-in-Quest-Multiview-Anpassungen und dieser Export: **Prempi**. Vorhandene VR-Arbeit von **ninjamode** wird ebenfalls genannt. Die MIT-Lizenz und eingebettete Hinweise anderer Mitwirkender bleiben erhalten; siehe [LICENSE.md](LICENSE.md) und [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Die MIT-Lizenz des Renderers erteilt keine Rechte an fremden Modellen oder Trainingsprogrammen. Dieses Paket enthält weder Modelle noch Trainingssoftware.
