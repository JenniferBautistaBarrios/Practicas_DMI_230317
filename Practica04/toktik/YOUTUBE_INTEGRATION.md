# Integración de YouTube

## Revisión del proyecto

- El proyecto declara Dart `^3.13.2`; `youtube_player_iframe 6.0.2` requiere Dart 3.10 o superior, por lo que la restricción declarada del proyecto es compatible.
- `youtube_player_iframe` usa el reproductor oficial YouTube IFrame API y no necesita una API key para reproducir.
- El feed vertical busca videos horizontales de letras, con consultas como `One and Only Adele letra en español`. El backend fija `type=video`, `videoEmbeddable=true` y `videoSyndicated=true`, luego confirma en `videos.list` que el video permite inserción y está disponible en México.
- El reproductor oficial IFrame inicia automáticamente el video actual. Los videos se muestran completos en proporción 16:9 dentro de una página vertical; si falla la reproducción, se quitan del feed y se guardan en SharedPreferences para no volver a sugerirlos.
- El paquete anuncia soporte Android, iOS, macOS y Web. En Windows/Linux se informa la limitación y se ofrece abrir el video en YouTube mediante el navegador del sistema.

## Configurar el backend para desarrollo

1. En Google Cloud crea o selecciona un proyecto y habilita **YouTube Data API v3**.
2. Crea una API key. No pongas el valor en Dart, en un archivo versionado, en capturas ni en mensajes.
3. Inicia el backend con la clave solo en su entorno:

   ```powershell
   $env:YOUTUBE_API_KEY = 'tu-clave-restringida'
   node backend/server.mjs
   ```

4. Ejecuta Flutter. Android emulador usa `http://10.0.2.2:3000`; Web usa `http://127.0.0.1:3000`. Para otra dirección configura solo la URL pública del backend con `--dart-define=YOUTUBE_API_BASE_URL=https://tu-servidor`.

## Protección para uso real

- Restringe la API key únicamente a **YouTube Data API v3**.
- Crea claves distintas por tipo de cliente y restríngelas en Google Cloud: Android por nombre de paquete y SHA-1, iOS por Bundle ID y Web por HTTP referrer. Aplica las restricciones disponibles para los destinos que realmente publiques.
- La clave permanece en el backend y nunca se compila en Flutter. En producción, limita el acceso al backend con autenticación, cuotas y controles de abuso.
- No guardes copias locales de videos ni extraigas audio. La reproducción se hace mediante el reproductor oficial, conservando sus controles, marca y anuncios.
- La letra no se obtiene ni se inventa. Solo debe mostrarse si más adelante se integra una fuente autorizada.

Consulta las [políticas de YouTube API](https://developers.google.com/youtube/terms/developer-policies), los [requisitos del reproductor integrado](https://developers.google.com/youtube/terms/required-minimum-functionality) y la [documentación de restricciones de API keys de Google Cloud](https://cloud.google.com/docs/authentication/api-keys).
