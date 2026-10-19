# Videos

Los videos del feed se reproducen desde Google Drive y no se empaquetan con
la aplicación. Los siete IDs y sus títulos se configuran en
`lib/infrastructure/datasources/google_drive_video_datasource.dart`.

Cada archivo de Drive debe tener el acceso general configurado como
**Cualquier persona con el enlace**. El reproductor utiliza el endpoint de
descarga de Drive; si Google muestra una pantalla de confirmación en lugar de
entregar el MP4, ese archivo no podrá reproducirse desde la app.

Los videos locales `1.mp4` a `5.mp4` que permanezcan en esta carpeta no se
incluyen en el paquete mientras `assets/videos/` no esté declarado en
`pubspec.yaml`.
