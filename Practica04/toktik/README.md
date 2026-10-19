# 🎬 KittyTokTik — Videos verticales con Flutter

<p align="center">
  <img src="/images.png" alt="Logo de la Universidad Tecnológica de Xicotepec de Juárez" width="200"/>

<h1 align="center">KittyTokTik</h1>

<h3 align="center">Desliza · Reproduce · Explora</h3>

<p align="center">
  Aplicación móvil de videos verticales desarrollada con Flutter y Dart.
  <br>
  Una experiencia multimedia inspirada en las plataformas de videos cortos.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-Lenguaje-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Material%203-Interfaz-6750A4" alt="Material 3">
  <img src="https://img.shields.io/badge/Plataforma-Multiplataforma-22C55E" alt="Multiplataforma">
</p>

---

## 🎨 Identidad visual de KittyTokTik

KittyTokTik cuenta con una identidad visual basada en un logotipo que combina la letra T con un símbolo de reproducción. Se contemplan diferentes versiones para representar la aplicación durante distintas temporadas del año.


## Iconos de la aplicación

Los iconos están guardados en `assets/icons/`. Puedes abrir cada imagen desde el repositorio:

| Temporada | Icono |
| --- | --- |
| Normal | ![Icono de KittyTokTik](assets/icons/normal.png) |
| Navidad | ![Icono navideño de KittyTokTik](assets/icons/navidad.png) |
| Halloween | ![Icono de Halloween de KittyTokTik](assets/icons/halloween.png) |
| San Valentín | ![Icono de San Valentín de KittyTokTik](assets/icons/san-valentin.png) |

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
| 🔁 Reproducción en bucle | Repite el contenido al finalizar. |
| 🔊 Sonido | Configura el reproductor con sonido activado. |
| 📝 Descripciones | Muestra información relacionada con cada video. |
| 🌑 Degradado inferior | Ayuda a mejorar el contraste del texto. |
| ❤️ Indicador de Me gusta | Presenta un icono y una cantidad del catálogo. |
| 👁️ Visualizaciones | Muestra cantidades de reproducciones. |
| ⏳ Estado de carga | Indica la inicialización del reproductor. |
| ⚠️ Manejo de errores | Permite presentar fallos de inicialización. |
| 🎨 Temas estacionales | Contempla variaciones visuales según la temporada. |
| 📱 Interfaz vertical | Aprovecha el espacio de la pantalla móvil. |

**Estado de las interacciones:** los iconos laterales de Me gusta y otras acciones se describen en la versión actual como elementos visuales. No se debe asumir que los botones actualizan datos o guardan interacciones si esa lógica todavía no está implementada.

## 📱 Pantalla principal e iconos

La pantalla principal muestra un video vertical acompañado por su descripción y una columna de indicadores visuales.

Los iconos que pueden formar parte de esta interfaz son:

| Icono | Función | Referencia Flutter |
|---|---|---|
| 👤 Perfil | Identifica al creador del contenido. | `Icons.account_circle` |
| ♡ Me gusta | Representa la opción de indicar que un video gusta. | `Icons.favorite_border` |
| ❤️ Me gusta activo | Representa el estado seleccionado, si está implementado. | `Icons.favorite` |
| 💬 Comentarios | Representa el acceso a comentarios. | `Icons.comment` |
| ↗ Compartir | Representa la opción de compartir contenido. | `Icons.share` |
| ▶ Reproducir | Representa el inicio de la reproducción. | `Icons.play_arrow` |
| ⏸ Pausar | Representa la pausa del video. | `Icons.pause` |

La tabla muestra referencias habituales. Las evidencias deben corresponder a los iconos que realmente aparezcan en la aplicación.

## 📸 Evidencias de la aplicación

En esta sección se muestran capturas tomadas durante la ejecución de KittyTokTik. Las imágenes permiten documentar la interfaz, los indicadores y el comportamiento del reproductor.

Guarda las capturas en `assets/screenshots/`.

### 1. 🎬 Capturas de aplicacion

Muestra el video vertical, la descripción y la distribución general de la interfaz.

<p align="center">
  <img src="assets/screenshots/01-pantalla-principal.png" alt="Pantalla principal de KittyTokTik" width="270">
</p>

<p align="center">
  <em>Figura 1. Pantalla principal del feed vertical.</em>
</p>

### 2. 🎬 Iconos laterales del video

Muestra la columna de iconos, las cantidades y su ubicación sobre el contenido.

<p align="center">
  <img src="assets/screenshots/02-iconos-video.png" alt="Iconos e indicadores laterales de KittyTokTik" width="270">
</p>

<p align="center">
  <em>Figura 2. Iconos e indicadores visuales del video.</em>
</p>

### 3. ❤️ Botón Me gusta: antes y después

Esta evidencia permite comparar el estado inicial del icono con el estado posterior al clic, siempre que la interacción esté implementada.

<table>
  <tr>
    <td align="center">
      <img src="assets/screenshots/03-me-gusta-inicial.png" alt="Me gusta sin seleccionar" width="220">
      <br>
      <strong>Estado inicial</strong>
      <br>
      <sub>Icono sin seleccionar</sub>
    </td>
    <td align="center">
      <img src="assets/screenshots/04-me-gusta-activo.png" alt="Me gusta seleccionado" width="220">
      <br>
      <strong>Estado activo</strong>
      <br>
      <sub>Después de pulsar el icono</sub>
    </td>
  </tr>
</table>

<p align="center">
  <em>Figura 3. Comparación del botón Me gusta.</em>
</p>

Si el corazón no cambia al pulsarlo, utiliza esta sección para mostrar únicamente el icono visual y señala que la interacción está pendiente. No presentes un estado activo simulado como si fuera una función comprobada.

### 4. ⏯️ Reproducción y pausa

Muestra el video cuando se encuentra pausado. Puedes añadir otra captura para representar la reproducción activa.

<p align="center">
  <img src="assets/screenshots/05-video-pausado.png" alt="Video pausado en KittyTokTik" width="270">
</p>

<p align="center">
  <em>Figura 4. Estado de pausa del reproductor.</em>
</p>

### 5. 🌑 Descripción y degradado

Esta captura permite observar la descripción y el degradado inferior que ayuda a mantener el texto legible.

<p align="center">
  <img src="assets/screenshots/06-descripcion-gradiente.png" alt="Descripción y degradado inferior del video" width="270">
</p>

<p align="center">
  <em>Figura 5. Descripción del contenido y degradado.</em>
</p>

> **Importante:** los nombres de las capturas son una propuesta. Debes guardar las imágenes reales con esos nombres o cambiar las rutas para que coincidan con tus archivos. GitHub no crea las imágenes automáticamente.

## 🎨 Diseño e identidad visual

KittyTokTik utiliza una apariencia tecnológica y minimalista para mantener el contenido multimedia como elemento principal de la interfaz.

### Características del diseño

- Fondo oscuro que destaca el contenido.
- Texto claro para facilitar la lectura.
- Acentos cian y violeta.
- Tipografía Montserrat.
- Degradados sobre los videos.
- Iconos e indicadores integrados en la interfaz.
- Variaciones gráficas para temporadas específicas.

### Paleta de colores

| Elemento | Color |
|---|---|
| Fondo principal | `#09090F` |
| Color primario | `#22D3EE` |
| Color secundario | `#A78BFA` |
| Texto principal | `#FFFFFF` |
| Tipografía | Montserrat |

### Tematización estacional

La aplicación contempla cambios visuales según la fecha local del dispositivo.

| Periodo | Tema | Apariencia |
|---|---|---|
| Octubre | Halloween | Naranja, violeta y fondo oscuro. |
| Diciembre | Navidad | Verde, rojo y fondo oscuro. |
| Resto del año | Tecnología | Negro, cian y violeta. |

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

1. Abre [Appetize.io](https://appetize.io/) e inicia sesión.
2. Elige la opción para subir una aplicación Android y selecciona `build/app/outputs/flutter-apk/app-release.apk`.
3. Espera el procesamiento y abre la aplicación desde el panel.
4. Comprueba que el feed se inicie y que el video y controles visibles respondan.
5. Copia el enlace de prueba generado por Appetize y reemplaza el marcador siguiente. El enlace aún no se ha proporcionado ni se ha subido la aplicación desde este entorno.

**Enlace real de Appetize:** `PENDIENTE: pegar aquí el enlace generado por Appetize.io`.

### Evidencias

Agrega capturas reales a [`evidencias/`](evidencias/README.md), siguiendo la lista de nombres y contenido descrita allí. La carpeta está preparada, pero todavía no contiene capturas de pruebas. No se muestran resultados ni enlaces inventados.

### Plan y resultados de pruebas

Completa el modelo, versión de Android y resultado después de ejecutar cada prueba en Appetize. Se requieren dos dispositivos Android distintos; Appetize puede permitir seleccionar perfiles de dispositivo, pero los resultados deben anotarse únicamente después de observar la ejecución.

| Dispositivo Android | Modelo / perfil | Prueba | Resultado observado | Evidencia |
|---|---|---|---|---|
| 1 | Pendiente de probar | Abrir KittyTokTik y cargar el primer video | Pendiente | `evidencias/02-prueba-dispositivo-1.png` |
| 1 | Pendiente de probar | Deslizar al siguiente video y comprobar reproducción | Pendiente | `evidencias/04-navegacion-feed.png` |
| 2 | Pendiente de probar | Abrir KittyTokTik y cargar el primer video | Pendiente | `evidencias/03-prueba-dispositivo-2.png` |
| 2 | Pendiente de probar | Deslizar al siguiente video y comprobar reproducción | Pendiente | `evidencias/04-navegacion-feed.png` |

### Resultado de compilación local

| Comprobación | Resultado |
|---|---|
| `flutter pub get` | Correcto: dependencias resueltas |
| `flutter analyze` | Correcto: sin incidencias tras retirar un import innecesario |
| `flutter build apk --release` | Correcto: compilación release finalizada |
| `flutter test` | 39 pasaron, 4 fallaron y 1 se omitió; detalles abajo |
| Archivo APK | `build/app/outputs/flutter-apk/app-release.apk` (232.8 MB) |

Fallos observados en `flutter test`:

- `features_test.dart`: una prueba espera 13 videos locales, pero actualmente el proyecto contiene 5 archivos MP4.
- `widget_test.dart`: la prueba de “Para ti” no encuentra esa pestaña en el árbol durante la prueba.
- `widget_test.dart`: la prueba del selector toca “Navidad” fuera del área visible del dispositivo de prueba y no aplica la temporada.
- `widget_test.dart`: la prueba del splash espera el texto “Vdry · San Valentín”, mientras que el splash implementado muestra el nombre “KittyTokTik”.

Estos resultados requieren revisión antes de declarar toda la suite correcta. No se agregaron videos ni se alteró la interfaz para forzar el pase de pruebas.
| Carga en Appetize | Pendiente de realizar desde una cuenta Appetize |

### Conclusiones

La compilación Android release está lista y el análisis estático no reporta incidencias. La publicación todavía no está completa: falta subir el APK desde una cuenta Appetize, comprobar el enlace y ejecutar las pruebas en dos perfiles Android distintos. Completa la tabla y agrega las capturas reales antes de entregar.

### Git: guardar y subir los cambios

El repositorio ya tiene cambios locales anteriores a esta práctica. Antes de confirmar, revisa `git status` y conserva esos cambios. No uses `git reset --hard`, `git clean` ni agregues todo con `git add .` sin revisar, porque podrías descartar o subir archivos ajenos a esta práctica.

```bash
git status --short --branch
git switch -c practica/publicacion-appetize
git add README.md evidencias/README.md
git diff --cached --stat
git diff --cached
git commit -m "docs: documentar publicación de KittyTokTik en Appetize"
git push -u origin practica/publicacion-appetize
```

Si `git switch -c` indica que la rama ya existe, usa `git switch practica/publicacion-appetize`. Antes de confirmar, agrega de forma explícita solo los archivos que quieras incluir; por ejemplo, después de tomar capturas revisadas, agrega `evidencias/01-appetize-enlace.png` y las demás imágenes necesarias. El APK dentro de `build/` no se agrega a Git.

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
