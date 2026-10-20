<h1 align="center">📱 Instalación y Configuración de un Entorno de Desarrollo con Flutter</h1>

<p align="center">
  <img src="/images.png" alt="Logo de la Universidad Tecnológica de Xicotepec de Juárez" width="300"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Desarrollo%20móvil-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Android%20Studio-Emulador-3DDC84?logo=androidstudio&logoColor=white" alt="Android Studio">
  <img src="https://img.shields.io/badge/Docker-Contenedores-2496ED?logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Windows-WSL2-0078D4?logo=windows&logoColor=white" alt="Windows y WSL2">
</p>

---

## 📖 Ver man

Consulta el manual de instalación con el procedimiento completo, paso a paso y con capturas, para preparar el entorno de desarrollo.
<p align="center">
  <a href="./Manual_de_Instalacion.pdf">
    <img src="https://img.shields.io/badge/📖_Ver-Manual%20de%20Instalación-FF69B4?style=for-the-badge" alt="Ver manual de instalación">
  </a>
</p>

---

## 👥 Integrantes

| N.º | Nombre del integrante |
|:---:|---|
| 1 | Obed Guzmán Flores |
| 2 | Yazmin Gutierrez Hernandez |
| 3 | Citlalli Perez Dionicio |
| 4 | Michelle Castro Otero |
| 5 | Jennifer Bautista Barrios |

---

## 🎯 Objetivos

### Objetivo general

Instalar, configurar y validar un entorno de desarrollo móvil, asegurando que una aplicación Flutter existente se ejecute en Android y que sus tareas de análisis y pruebas funcionen mediante Docker.

### Objetivos específicos

- 🪟 Configurar Windows, WSL2 con Ubuntu 24.04 y Visual Studio Code con las extensiones necesarias para Flutter y Dart.
- ☕ Instalar JDK 21, Maven, Node.js y npm.
- 🤖 Instalar Android Studio, configurar el SDK y crear un emulador Android.
- 💙 Instalar Flutter y configurar el `PATH`.
- 🩺 Verificar el entorno mediante `flutter doctor` y `flutter devices`.
- ▶️ Validar la aplicación existente con `flutter pub get` y `flutter run`.
- 🐳 Instalar Docker Desktop y dockerizar el proyecto.
- 🔀 Configurar Git y GitHub para el control de versiones.

---

## ✅ Conclusiones

- Validar primero la aplicación existente permite distinguir los problemas del código de los problemas del entorno.
- Android Studio administra el SDK y el emulador, mientras que Visual Studio Code se usa para editar y ejecutar el proyecto.
- WSL2 se configura como soporte de Docker Desktop.
- Docker se usa solo para instalar dependencias, analizar el código y ejecutar pruebas; la aplicación sigue ejecutándose en el emulador.
- Git y GitHub dejan el proyecto versionado y publicado.

---

## 🐳 Docker

La carpeta `yes_no_app` contiene el `Dockerfile` y el `.dockerignore` que permiten analizar y probar el proyecto Flutter dentro de un contenedor.

```text
yes_no_app/
├── Dockerfile
└── .dockerignore
```

Con Docker Desktop abierto, ejecuta desde la carpeta del proyecto:

```bash
docker build -t yes-no-app-flutter .
docker run --name yes-no-app-container yes-no-app-flutter
```

<p align="center">
  <a href="../Practica03/yes_no_app">
    <img src="https://img.shields.io/badge/🐳_Ver-Proyecto%20y%20Docker-2496ED?style=for-the-badge" alt="Ver proyecto y Docker">
  </a>
</p>

---

<p align="center">
  <sub>Universidad Tecnológica de Xicotepec de Juárez</sub>
</p>