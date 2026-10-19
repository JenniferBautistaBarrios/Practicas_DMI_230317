# Integración de YouTube

## Revisión del proyecto

- El proyecto declara Dart `^3.13.2`; `youtube_player_iframe 6.0.2` requiere Dart 3.10 o superior, por lo que la restricción declarada del proyecto es compatible.
- `youtube_player_iframe` usa el reproductor oficial YouTube IFrame API y no necesita una API key para reproducir.
- Discovery usa YouTube Data API v3. `videos.list` con `chart=mostPopular`, `videoCategoryId=10` y región MX alimenta Tendencias musicales. La búsqueda del feed consulta videos musicales y carga snippet/estadísticas; paginación continúa cuando se acerca al final.
- Las tarjetas muestran la miniatura que devuelve YouTube con un botón de reproducción. El toque del botón abre los detalles e inicia el reproductor IFrame; el toque del título abre los detalles pausado. Una miniatura por sí sola nunca se muestra como si fuera el video.
- El paquete anuncia soporte Android, iOS, macOS y Web. En Windows/Linux se informa la limitación y se ofrece abrir el video en YouTube mediante el navegador del sistema.

## Configurar la API key para desarrollo

1. En Google Cloud crea o selecciona un proyecto y habilita **YouTube Data API v3**.
2. Crea una API key. No pongas el valor en Dart, en un archivo versionado, en capturas ni en mensajes.
3. Guarda localmente un archivo ignorado por Git llamado `api_credentials.json`, con este formato:

   ```json
   { "YOUTUBE_API_KEY": "PEGA_AQUI_TU_CLAVE_LOCAL" }
   ```

4. Ejecuta la app con:

   ```powershell
   flutter run --dart-define-from-file=api_credentials.json
   ```

La app envía la clave por el encabezado `x-goog-api-key`, no como parámetro de URL. `--dart-define-from-file` evita poner el valor literal en el comando, pero la clave sigue incorporada en la app compilada y puede extraerse; no es un almacén secreto para distribuir la app.

## Protección para uso real

- Restringe la API key únicamente a **YouTube Data API v3**.
- Crea claves distintas por tipo de cliente y restríngelas en Google Cloud: Android por nombre de paquete y SHA-1, iOS por Bundle ID y Web por HTTP referrer. Aplica las restricciones disponibles para los destinos que realmente publiques.
- Para una app pública, no distribuyas una key con privilegios de uso directo desde el cliente. Traslada las llamadas de Data API a un backend propio y protege ese servicio con autenticación, límites y controles de cuota.
- No guardes copias locales de videos ni extraigas audio. La reproducción se hace mediante el reproductor oficial, conservando sus controles, marca y anuncios.
- La letra no se obtiene ni se inventa. Solo debe mostrarse si más adelante se integra una fuente autorizada.

Consulta las [políticas de YouTube API](https://developers.google.com/youtube/terms/developer-policies), los [requisitos del reproductor integrado](https://developers.google.com/youtube/terms/required-minimum-functionality) y la [documentación de restricciones de API keys de Google Cloud](https://cloud.google.com/docs/authentication/api-keys).
