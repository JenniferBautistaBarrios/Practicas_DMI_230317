# Cinemapedia · Práctica 06 · 230389

Aplicación Flutter con TMDB, Riverpod y GoRouter.

## Ejecutar

En esta carpeta, configura `.env` con `THE_MOVIEDB_KEY=tu_clave_de_tmdb` y ejecuta:

```sh
flutter pub get
flutter run
```

## Navegación y gestos

- Menú hamburguesa: inicio, en cines, próximos estrenos, populares, mejor calificadas y países.
- Logo propio en la barra y el menú; se conserva la configuración existente de icono y splash.
- Deslizar horizontalmente: recorrer el carrusel o una lista.
- Flechas: avanzar o retroceder. Doble toque: principio o final de las películas cargadas.
- Doble toque en la mitad izquierda/derecha del carrusel: película anterior/siguiente.
- Tocar una película: abrir el detalle.
- Botón de flecha hacia arriba o Inicio: volver al principio de la pantalla.
- Deslizar hacia abajo desde el inicio: recargar las cuatro secciones.
- Las listas cargan más películas al acercarse al final; los errores permiten reintentar.

## Países e idiomas

La bandera de la barra y el selector del menú cambian el mismo estado global:

| Bandera | País | Consulta TMDB | Continente |
| --- | --- | --- | --- |
| 🇲🇽 | México | `es-MX`, región `MX` | América del Norte |
| 🇺🇸 | Estados Unidos | `en-US`, región `US` | América del Norte |
| 🇩🇪 | Alemania | `de-DE`, región `DE` | Europa |
| 🇧🇷 | Brasil | `pt-BR`, región `BR` | América del Sur |
| 🇯🇵 | Japón | `ja-JP`, región `JP` | Asia |
| 🇿🇦 | Sudáfrica | `en-ZA`, región `ZA` | África |
| 🇦🇺 | Australia | `en-AU`, región `AU` | Oceanía |

México es la selección inicial. Cambiar país reinicia las listas y la paginación, y actualiza títulos, sinopsis, géneros del detalle, textos de la interfaz, controles de Flutter y clasificaciones. Una respuesta pendiente del país anterior no se agrega al catálogo nuevo. La selección dura durante la sesión.

`language` solicita las traducciones disponibles; `region` selecciona el mercado de consulta y sus estrenos. No es un filtro por país de producción, y algunos catálogos pueden compartir películas. Si TMDB no tiene una traducción, puede devolver el título original.

## Estrellas y clasificación

El carrusel, las tarjetas y el detalle muestran el título localizado, cinco estrellas y la clasificación del país seleccionado.

- Las estrellas convierten la puntuación **global de TMDB** de 0–10 a 0–5; no representan votos separados por país. Mantén pulsado o pasa el cursor por la puntuación para consultar la nota original y el número de votos.
- Las clasificaciones se obtienen de `/movie/{id}/release_dates`, exclusivamente del código de país seleccionado. Se prioriza el estreno en cines, después el limitado y las demás modalidades.
- Si falta una clasificación local, se muestra «Sin clasificación» en el idioma elegido. Si falla la consulta, se muestra «No disponible» y se puede tocar para reintentar.
- Las consultas de clasificación se comparten entre carrusel, listas y detalle para evitar solicitudes duplicadas del mismo país y película.

Referencias oficiales: [idiomas de TMDB](https://developer.themoviedb.org/docs/languages), [estrenos por región](https://developer.themoviedb.org/reference/movie-now-playing-list) y [clasificaciones por película y país](https://developer.themoviedb.org/reference/movie-release-dates).

## Verificación

```sh
flutter analyze
flutter test
```

Las pruebas usan repositorios y respuestas de API simulados; no necesitan tu clave ni acceso a TMDB. Cubren idiomas y regiones, clasificaciones locales, cambio de cachés, catálogos pequeños o vacíos, errores, paginación, navegación, gestos y pantallas pequeñas con texto ampliado.
