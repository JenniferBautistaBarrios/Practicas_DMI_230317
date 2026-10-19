# 🎬 KittyTokTik

<p align="center">
  <img src="assets/icons/Kittytoktik.png" alt="Icono de KittyTokTik" width="190">
  <br>
  <strong>Desliza · Reproduce · Explora</strong>
  <br>
  Aplicación móvil de videos verticales desarrollada con Flutter y Dart.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Material_3-E91E83?logo=materialdesign&logoColor=white" alt="Material 3">
  <img src="https://img.shields.io/badge/Temas-por_temporada-C62828" alt="Temas por temporada">
</p>

---

## 🏗️ Diagramas de arquitectura

**Arquitectura inicial — proveedor local:** muestra la pantalla conectada al estado y a la lista local de videos.

<p align="center">
  <img src="arquitectura/capturas/Arquitectura%20Inicial.png" alt="Diagrama de arquitectura inicial de KittyTokTik: proveedor local" width="100%">
</p>

[Abrir diagrama inicial interactivo](https://jenniferbautistabarrios.github.io/Practicas_DMI_230317/inicial/arquitectura.html)

**Arquitectura final — proveedor, repositorio y fuentes de datos:** muestra las capas de la aplicación y el flujo hacia las fuentes de datos y la persistencia.

<p align="center">
  <img src="arquitectura/capturas/ArquitecturaFinal.png" alt="Diagrama de arquitectura final de KittyTokTik: proveedor, repositorio y fuentes de datos" width="100%">
</p>

[Abrir diagrama final interactivo](https://jenniferbautistabarrios.github.io/Practicas_DMI_230317/final/arquitectura.html)

---

## 🎨 Identidad visual e iconos

La interfaz usa una base clara y rosada. El color de acento y la tipografía cambian con la temporada. Los cuatro iconos que ya están en `assets/icons/` se muestran aquí:

| Tema | Icono de la aplicación |
| --- | --- |
| Normal · rosa | <img src="assets/icons/Kittytoktik.png" alt="Icono KittyTokTik normal" width="120"> |
| Halloween · naranja | <img src="assets/icons/Hallowen.png" alt="Icono KittyTokTik de Halloween" width="120"> |
| Navidad · rojo | <img src="assets/icons/Navidad.png" alt="Icono KittyTokTik de Navidad" width="120"> |
| San Valentín · rojo y rosa | <img src="assets/icons/Sanvalentin.png" alt="Icono KittyTokTik de San Valentín" width="120"> |

---

## 📑 Índice

1. [Descripción del proyecto](#-descripción-del-proyecto)
2. [Objetivos](#-objetivos)
3. [Funcionalidades](#-funcionalidades)
4. [Pantalla principal e iconos](#-pantalla-principal-e-iconos)
5. [Evidencias de la aplicación](#-evidencias-de-la-aplicación)
6. [Diseño e identidad visual](#-diseño-e-identidad-visual)
7. [Tecnologías utilizadas](#-tecnologías-utilizadas)
8. [Arquitectura del proyecto](#️-arquitectura-del-proyecto)
9. [Instalación y ejecución](#️-instalación-y-ejecución)
10. [Validación y pruebas](#-validación-y-pruebas)
11. [Alcance y mejoras futuras](#-alcance-y-mejoras-futuras)
12. [Datos académicos](#-datos-académicos)

---

## 📖 Descripción del proyecto

**KittyTokTik** es una aplicación móvil desarrollada con Flutter y Dart que permite visualizar videos en formato vertical mediante una interfaz dinámica e intuitiva.

Su diseño está inspirado en las plataformas de videos cortos, donde el contenido multimedia ocupa la mayor parte de la pantalla y el usuario puede desplazarse verticalmente para cambiar de video.

La aplicación integra un catálogo de videos locales, descripciones sobre el contenido, indicadores laterales y un reproductor multimedia. También utiliza Provider para administrar el estado y componentes reutilizables para mantener una estructura organizada.

El proyecto permite poner en práctica conocimientos de desarrollo móvil, programación asíncrona, reproducción multimedia, administración de estado y diseño de interfaces.

### 💡 Propósito

Desarrollar una aplicación móvil que permita explorar y reproducir videos verticales, aplicando herramientas de Flutter y una organización del código que facilite su mantenimiento y evolución.

## 🎯 Objetivos

### Objetivo general

Construir una aplicación de videos verticales con Flutter y Dart, implementando navegación mediante gestos, reproducción multimedia y administración del estado.

### Objetivos específicos

- Implementar un feed vertical mediante `PageView.builder`.
- Administrar el estado utilizando `Provider` y `ChangeNotifier`.
- Representar los videos mediante modelos y entidades.
- Reproducir archivos multimedia con `video_player`.
- Controlar la inicialización, pausa y reproducción de los videos.
- Presentar descripciones e indicadores visuales sobre el contenido.
- Aplicar degradados para mejorar la legibilidad del texto.
- Utilizar componentes reutilizables para organizar la interfaz.
- Formatear cantidades de manera compacta.
- Facilitar futuras ampliaciones de la aplicación.

## ✨ Funcionalidades

| Funcionalidad | Descripción |
|---|---|
| 🎞️ Feed vertical | Permite cambiar de video mediante desplazamientos verticales. |
| ▶️ Reproducción multimedia | Inicializa y reproduce los archivos de video. |
| ⏸️ Pausa y reanudación | Permite pausar o reanudar el video al tocarlo. |
| 🔊 Sonido | Configura el reproductor con sonido activado. |
| 📝 Descripciones | Muestra información relacionada con cada video. |
| ❤️ Indicador de Me gusta | Presenta un icono y una cantidad del catálogo. |
| 👁️ Visualizaciones | Muestra cantidades de reproducciones. |
| ⚠️ Manejo de errores | Permite presentar fallos de inicialización. |
| 🎨 Temas estacionales | Contempla variaciones visuales según la temporada. |
| 📱 Interfaz vertical | Aprovecha el espacio de la pantalla móvil. |

Los Me gusta se guardan en las preferencias locales. Los comentarios se consultan para los videos compatibles; el marcador de Guardar es temporal y se reinicia al cerrar la pantalla.

## 📱 Pantalla principal e iconos

La pantalla principal muestra un video vertical acompañado por su descripción y una columna de acciones.

Estos son los iconos que utiliza la interfaz:

| Icono | Función | Referencia Flutter |
|---|---|---|
| ♡ / ❤️ | Me gusta y Me gusta activo | `Icons.favorite_border` / `Icons.favorite` |
| 💬 | Abrir comentarios | `Icons.mode_comment_outlined` |
| ▣ | Guardar en la pantalla actual | `Icons.bookmark_border_rounded` / `Icons.bookmark_rounded` |
| ◉ | Visualizaciones | `Icons.visibility_outlined` |
| 🔊 / 🔇 | Activar o silenciar | `Icons.volume_up` / `Icons.volume_off` |
| ▶ | Reanudar un video pausado | `Icons.play_arrow` |
| 🏠 / 🔎 / ♥ | Inicio, Discovery y Me gusta | `Icons.home_rounded`, `Icons.explore_rounded`, `Icons.favorite_rounded` |

## 🎃 Evidencias de Halloween

Capturas de la aplicación con el tema de Halloween:

| Inicio | Discovery |
|---|---|
| <img src="evidencias/evidencia1hallowen.jpeg" alt="Pantalla inicial de KittyTokTik con el tema de Halloween" width="240"> | <img src="evidencias/evidencia2hallowen.jpeg" alt="Feed de Discovery con el tema de Halloween" width="240"> |

| Me gusta | Ajustes de temporada |
|---|---|
| <img src="evidencias/evidencia3hallowen.jpeg" alt="Pantalla Me gusta con el tema de Halloween" width="240"> | <img src="evidencias/evidencia4hallowen.jpeg" alt="Selector de temas con Halloween seleccionado" width="240"> |

## 💝 Evidencias de San Valentín

Capturas de la aplicación con el tema de San Valentín:

| Inicio | Discovery |
|---|---|
| <img src="evidencias/evidencia1%20sanvalentin.jpeg" alt="Pantalla inicial de KittyTokTik con el tema de San Valentín" width="240"> | <img src="evidencias/evidencia2sanvalentin.jpeg" alt="Feed de Discovery con el tema de San Valentín" width="240"> |

| Inicio · reproducción | Me gusta |
|---|---|
| <img src="evidencias/evidencia3sanvalentin.jpeg" alt="Video reproduciéndose en Inicio con el tema de San Valentín" width="240"> | <img src="evidencias/evidencia4sanvalentin.jpeg" alt="Video guardado en Me gusta con el tema de San Valentín" width="240"> |

## 🎄 Evidencias de Navidad

Capturas de KittyTokTik con el tema navideño:

| Inicio | Discovery |
|---|---|
| <img src="evidencias/navidad1.jpeg" alt="Pantalla inicial con el tema de Navidad" width="240"> | <img src="evidencias/navidad2.jpeg" alt="Feed de Discovery durante la temporada navideña" width="240"> |

| Inicio · video | Selector de temporada |
|---|---|
| <img src="evidencias/navidad3.jpeg" alt="Video en Inicio con el tema de Navidad" width="240"> | <img src="evidencias/navidad4.jpeg" alt="Selector de temas con Navidad seleccionada" width="240"> |

## ✨ Evidencias del tema normal

Capturas de KittyTokTik con el tema normal:

| Inicio | Discovery |
|---|---|
| <img src="evidencias/normal1.jpeg" alt="Pantalla inicial de KittyTokTik con el tema normal" width="240"> | <img src="evidencias/normal2.jpeg" alt="Feed de Discovery con el tema normal" width="240"> |

| Para ti | Me gusta y selector de temporada |
|---|---|
| <img src="evidencias/normal3%20.jpeg" alt="Feed Para ti con el tema normal" width="240"> | <img src="evidencias/normal4.jpeg" alt="Sección Me gusta y selector con el tema normal activo" width="240"> |


## 🎨 Diseño e identidad visual

KittyTokTik usa superficies claras en tonos rosados. El video ocupa el área principal y usa un degradado oscuro detrás de los textos y controles para que sigan siendo legibles.

### Características del diseño

- Fondo rosa muy claro en las pantallas de navegación.
- Acentos de color que cambian según la temporada.
- Tipografía Nunito durante la temporada normal.
- Tipografías temáticas para Halloween, Navidad y San Valentín.
- Degradado oscuro sobre la parte inferior del video.
- Iconos de acciones y navegación de Material.
- Icono de aplicación propio para cada temporada.

### Paleta de colores

| Tema | Color primario | Acento secundario | Fondo | Superficie |
|---|---|---|---|---|
| Normal | `#E91E83` | `#FF4FA0` | `#FFF7FB` | `#FFEFF6` |
| Halloween | `#F57C00` | `#FFA726` | `#FFE0B2` | `#FFD08A` |
| Navidad | `#C62828` | `#E57373` | `#FFCDD2` | `#FFCDD2` |
| San Valentín | `#D32F2F` | `#EF5350` | `#FFCDD2` | `#FFBFC2` |

### Tematización estacional

La aplicación contempla cambios visuales según la fecha local del dispositivo.

| Periodo | Tema | Apariencia |
|---|---|---|
| Octubre | Halloween | Naranja sobre fondo durazno; tipografía Creepster. |
| Diciembre | Navidad | Rojo y rosa claro; tipografía Mountains of Christmas. |
| Del 1 al 14 de febrero | San Valentín | Rojo y rosa; tipografía Great Vibes. |
| Resto del año | Normal | Rosa y fondo casi blanco; tipografía Nunito. |

La tematización se debe comprobar ejecutando la aplicación o mediante las pruebas correspondientes.

## 🛠️ Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Flutter | Desarrollo de la interfaz multiplataforma. |
| Dart | Lenguaje de programación. |
| Provider | Administración y observación del estado. |
| `video_player` | Reproducción de archivos multimedia. |
| `intl` | Formato compacto de cantidades. |
| Git | Control de versiones. |
| GitHub | Alojamiento del repositorio. |
| Git LFS | Gestión de videos grandes, si está configurado. |

---

## Práctica: publicación de KittyTokTik en Appetize.io

### Objetivo

Preparar la aplicación Flutter KittyTokTik como APK Android de release, cargarla en Appetize.io, probarla en dos dispositivos Android y documentar evidencias verificables.

### Preparación y compilación

Desde la raíz del proyecto, con Flutter y Android SDK instalados:

```bash
flutter pub get
flutter build apk --release
```

El APK generado se encuentra en `build/app/outputs/flutter-apk/app-release.apk`. Appetize necesita el archivo `.apk` para Android; no se debe seleccionar un `.aab`.

### Publicación en Appetize.io

<p align="center">
  <a href="https://appetize.io/app/b_ehay32xnml7zxhkpfmrge5v4nq?device=pixel7&amp;osVersion=13.0&amp;toolbar=true" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/Entrar%20a%20KittyTokTik-Appetize.io-ec4899?style=for-the-badge&amp;logo=android&amp;logoColor=white" alt="Entrar a KittyTokTik en Appetize.io">
  </a>
</p>

Pulsa el botón **Entrar a KittyTokTik en Appetize.io** para abrir la aplicación en el navegador. El enlace configura un Pixel 7 con Android 13.

Para publicar una nueva versión, selecciona `build/app/outputs/flutter-apk/app-release.apk` en la página de carga de Appetize y espera a que termine el procesamiento. Después puedes abrirla desde el panel y comprobar el feed, el video y sus controles.




### Plan y resultados de pruebas

Completa el modelo, versión de Android y resultado después de ejecutar cada prueba en Appetize. Se requieren dos dispositivos Android distintos; Appetize puede permitir seleccionar perfiles de dispositivo, pero los resultados deben anotarse únicamente después de observar la ejecución.



## 🏗️ Arquitectura del proyecto

La aplicación organiza sus componentes en carpetas que separan la presentación, los datos, los modelos, las entidades y la configuración.

### Estructura de directorios

```text
toktik/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── helpers/
│   │   │   └── human_formats.dart
│   │   └── theme/
│   │       └── app_theme.dart
│   ├── domain/
│   │   └── entities/
│   │       └── video_post.dart
│   ├── infraestructure/
│   │   └── models/
│   │       └── local_video_model.dart
│   ├── shared/
│   │   └── data/
│   │       └── local_video_post.dart
│   └── presentation/
│       ├── providers/
│       │   └── discover_provider.dart
│       ├── screen/
│       │   └── discover/
│       │       └── discover_screen.dart
│       └── widgets/
│           ├── shared/
│           └── video/
├── assets/
│   ├── videos/
│   ├── screenshots/
│   ├── icon/
│   └── fonts/
├── pubspec.yaml
└── README.md

