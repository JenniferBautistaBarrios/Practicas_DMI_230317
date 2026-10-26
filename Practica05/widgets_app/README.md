# Práctica 05 — Widgets App 🚀

<p align="center">
  <img src="/images.png" alt="Logo de la Universidad Tecnológica de Xicotepec de Juárez" width="180"/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="/flutter.png" alt="Logo de Flutter" width="180"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=Dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Material_3-7B1FA2?style=for-the-badge&logo=materialdesign&logoColor=white" alt="Material 3" />
  <img src="https://img.shields.io/badge/Riverpod-008080?style=for-the-badge&logo=flutter&logoColor=white" alt="Riverpod" />
  <img src="https://img.shields.io/badge/GoRouter-388E3C?style=for-the-badge&logo=flutter&logoColor=white" alt="GoRouter" />
</p>

---

📱 Evidencia de Funcionamiento

<p align="center">
<i>Pruebas ejecutadas en un dispositivo móvil Android físico.</i>
</p>

<table>
<tr>
<th align="center">Inicio y Navegación</th>
<th align="center">Demostraciones de Widgets</th>
<th align="center">Tema y Estado Global</th>
</tr>
<tr>
<td align="center">
<img src="../images/cap1.jpeg" alt="Menú principal" width="230"/>
</td>
<td align="center">
<img src="../images/cap2.jpeg" alt="Progress Indicators" width="230"/>
</td>
<td align="center">
<img src="../images/cap3.jpeg" alt="Cambio de tema" width="230"/>
</td>
</tr>
<tr>
<td align="center"><b>Menú principal con GoRouter</b></td>
<td align="center"><b>Demostración de componentes</b></td>
<td align="center"><b>Selector de color (Riverpod)</b></td>
</tr>
</table>

📸 Capturas adicionales

<table>
<tr>
<th align="center">Captura 4</th>
<th align="center">Captura 5</th>
</tr>
<tr>
<td align="center">
<img src="../images/cap4.jpeg" alt="Captura 4" width="230"/>
</td>
<td align="center">
<img src="../images/cap5.jpeg" alt="Captura 5" width="230"/>
</td>
</tr>
<tr>
<td align="center"><b>Evidencia adicional de funcionamiento</b></td>
<td align="center"><b>Demostración adicional de widgets</b></td>
</tr>
</table>

## 📌 Objetivo
Desarrollar una aplicación interactiva en **Flutter** para explorar la biblioteca de componentes de **Material 3**, implementar patrones de navegación avanzada con `GoRouter` y gestionar el estado global mediante **Riverpod**. Cada sección del proyecto demuestra interacciones, animaciones y componentes específicos dentro de un flujo unificado.

---

## 🏗️ Diagrama de Arquitectura

> 🔗 **[Ver el Diagrama Interactivo en GitHub Pages](http://127.0.0.1:5500/Practica05/arquitectura/arquitectura-practica05.html)**

<p align="center">
  <img src="../images/Diagrama de Arquitectura.png" alt="Diagrama de Arquitectura" width="90%"/>
</p>
---

## ✨ Funcionalidades

| Componente / Módulo | Descripción |
| :--- | :--- |
| **🪟 Navegación** | Menú lateral (*Drawer*) y rutas declarativas gestionadas con `GoRouter`. |
| **🔘 Botones y Tarjetas** | Variantes completas de botones de Material 3 y tarjetas con elevaciones, bordes y multimedia. |
| **⏳ Indicadores de Progreso** | Controles circulares y lineales (controlados de forma reactiva y no controlados). |
| **💬 Mensajes y Diálogos** | Notificaciones con `SnackBar`, diálogos emergentes de confirmación y vista de licencias. |
| **✨ Animaciones** | Contenedor interactivo (`AnimatedContainer`) que altera tamaño, color y radio aleatoriamente. |
| **🎛️ Controles de Interfaz** | Formulario con interruptores (`Switch`), botones de radio (`RadioListTile`) y casillas (`Checkbox`). |
| **📖 Tutorial Onboarding** | Carrusel guiado de 3 pantallas con ilustraciones locales y botones de navegación rápida. |
| **🔄 Lista Infinita** | Carga dinámica de imágenes con `picsum.photos`, recarga por deslizamiento (*Pull-to-refresh*) y *scroll infinito*. |
| **🎨 Estado con Riverpod** | Contador reactivo y selector global de tema (modo claro/oscuro y paletas de color personalizadas). |

---

## 💡 Descripción de la Solución

1. **Punto de Entrada (`main.dart`):** Envuelve la aplicación dentro de un `ProviderScope` e inicializa `MaterialApp.router`.
2. **Navegación:** `GoRouter` registra la pantalla principal y las 10 demostraciones accesibles desde el menú lateral.
3. **Gestión de Tema:** Diseñado con **Material 3**. El estado es controlado por `ThemeNotifier`, permitiendo alternar el modo oscuro y cambiar el color de acento dinámicamente en toda la aplicación.
4. **Recursos y APIs:** Las imágenes locales del tutorial se alojan en `assets/images/`, mientras que las tarjetas y la lista infinita consumen contenido remoto desde `picsum.photos`.

---

## 🛠️Tecnologías Utilizadas

- **Framework:** Flutter & Dart
- **Diseño:** Material 3
- **Gestión de Estado:** `flutter_riverpod`
- **Enrutamiento:** `go_router`
- **Animaciones:** `animate_do`
- **Fuentes de Datos:** API de `picsum.photos`

---

## 🚀 Cómo Ejecutar el Proyecto

Navega a la carpeta del proyecto ejecutable (`widgets_app`) y ejecuta los siguientes comandos:

# Ejecutar la aplicación 
flutter run
